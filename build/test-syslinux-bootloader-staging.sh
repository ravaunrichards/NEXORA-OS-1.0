#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HELPER="$ROOT_DIR/build/prepare-syslinux-bootloaders.sh"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nexora-syslinux-stage.XXXXXX")"
trap 'rm -rf -- "$TMP_ROOT"' EXIT

TEMPLATES="$TMP_ROOT/templates"
ISOLINUX_BIN="$TMP_ROOT/isolinux.bin"
VESAMENU_C32="$TMP_ROOT/vesamenu.c32"
CONFIG="$TMP_ROOT/config"
mkdir -p "$TEMPLATES"

printf 'template-isolinux-config\n' > "$TEMPLATES/isolinux.cfg"
printf 'template-live-config\n' > "$TEMPLATES/live.cfg.in"
printf 'template-menu-config\n' > "$TEMPLATES/menu.cfg"
printf 'package-isolinux-binary\n' > "$ISOLINUX_BIN"
printf 'package-vesamenu-module\n' > "$VESAMENU_C32"

bash "$HELPER" "$CONFIG" "$TEMPLATES" "$ISOLINUX_BIN" "$VESAMENU_C32"
TARGET="$CONFIG/bootloaders/isolinux"

for required in isolinux.bin vesamenu.c32 isolinux.cfg live.cfg.in menu.cfg; do
  [[ -s "$TARGET/$required" ]] || {
    printf 'ERROR: Syslinux staging omitted %s\n' "$required" >&2
    exit 1
  }
done

cmp -s "$ISOLINUX_BIN" "$TARGET/isolinux.bin" || {
  printf 'ERROR: Staged ISOLINUX binary differs from package source.\n' >&2
  exit 1
}
cmp -s "$VESAMENU_C32" "$TARGET/vesamenu.c32" || {
  printf 'ERROR: Staged VESAMENU module differs from package source.\n' >&2
  exit 1
}
cmp -s "$TEMPLATES/isolinux.cfg" "$TARGET/isolinux.cfg" || {
  printf 'ERROR: ISOLINUX config template was not preserved.\n' >&2
  exit 1
}

# A source missing either package-provided binary must fail closed.
BROKEN_CONFIG="$TMP_ROOT/broken-config"
if bash "$HELPER" "$BROKEN_CONFIG" "$TEMPLATES" "$ISOLINUX_BIN" "$TMP_ROOT/missing-vesamenu.c32" >/dev/null 2>&1; then
  printf 'ERROR: Syslinux staging accepted a missing VESAMENU module.\n' >&2
  exit 1
fi

printf 'NEXORA Syslinux bootloader staging test passed.\n'
