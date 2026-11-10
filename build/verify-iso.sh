#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[[ $# -eq 1 ]] || fail "Usage: bash build/verify-iso.sh path/to/image.iso"
ISO_PATH="$1"
[[ -f "$ISO_PATH" ]] || fail "ISO file not found: $ISO_PATH"
[[ -s "$ISO_PATH" ]] || fail "ISO file is empty: $ISO_PATH"
command -v xorriso >/dev/null 2>&1 || fail "xorriso is required."

ISO_PATH="$(cd -- "$(dirname -- "$ISO_PATH")" && pwd)/$(basename -- "$ISO_PATH")"
REPORT="$(mktemp "${TMPDIR:-/tmp}/nexora-iso-report.XXXXXX")"
trap 'rm -f -- "$REPORT"' EXIT

xorriso -indev "$ISO_PATH" -pvd_info > "$REPORT" 2>&1 || fail "Image could not be read as an ISO filesystem."
xorriso -indev "$ISO_PATH" -report_el_torito plain >> "$REPORT" 2>&1 || fail "Could not inspect El Torito boot catalog."
grep -qi "BIOS" "$REPORT" || fail "No BIOS El Torito entry detected."
grep -qi "UEFI" "$REPORT" || grep -Eqi '0x0*ef|platform.*ef' "$REPORT" || fail "No UEFI El Torito entry detected."

SYSTEM_AREA_REPORT="$(mktemp "${TMPDIR:-/tmp}/nexora-system-area-report.XXXXXX")"
trap 'rm -f -- "$REPORT" "$SYSTEM_AREA_REPORT"' EXIT
xorriso -indev "$ISO_PATH" -report_system_area plain > "$SYSTEM_AREA_REPORT" 2>&1 || fail "Could not inspect hybrid system area."
grep -Eqi 'MBR partition[[:space:]]*:[[:space:]]*[0-9]+[[:space:]]+0x[0-9a-f]+[[:space:]]+0xef' "$SYSTEM_AREA_REPORT" || fail "No EFI-marked MBR partition (type 0xEF) detected."

printf 'ISO filesystem, BIOS/UEFI El Torito, and hybrid EFI MBR checks passed.\n'
if [[ -f "$ISO_PATH.sha256" ]]; then
  (
    cd "$(dirname -- "$ISO_PATH")"
    sha256sum -c "$(basename -- "$ISO_PATH").sha256"
  )
else
  printf 'No adjacent SHA-256 manifest found; calculated checksum follows.\n'
  sha256sum "$ISO_PATH"
fi

printf '\nThis check does not prove a successful UEFI/BIOS boot, installer, hardware support, or recovery.\n'
