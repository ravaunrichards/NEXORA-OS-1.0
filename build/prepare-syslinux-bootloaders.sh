#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[[ "$#" -ge 1 && "$#" -le 4 ]] || fail "Usage: $0 CONFIG_DIR [LIVE_BUILD_TEMPLATE_DIR] [ISOLINUX_BIN] [VESAMENU_C32]"
CONFIG_DIR="$1"
TEMPLATE_DIR="${2:-/usr/share/live/build/bootloaders/isolinux}"
ISOLINUX_BIN="${3:-/usr/lib/ISOLINUX/isolinux.bin}"
VESAMENU_C32="${4:-/usr/lib/syslinux/modules/bios/vesamenu.c32}"
TARGET_DIR="$CONFIG_DIR/bootloaders/isolinux"

[[ -n "$CONFIG_DIR" ]] || fail "Configuration directory must not be empty."
[[ -d "$TEMPLATE_DIR" ]] || fail "live-build ISOLINUX template directory not found: $TEMPLATE_DIR"
[[ -s "$ISOLINUX_BIN" ]] || fail "ISOLINUX boot sector not found: $ISOLINUX_BIN"
[[ -s "$VESAMENU_C32" ]] || fail "Syslinux BIOS menu module not found: $VESAMENU_C32"

mkdir -p "$TARGET_DIR"
cp -a "$TEMPLATE_DIR/." "$TARGET_DIR/"

# Ubuntu packages these binary assets separately from live-build's templates.
# Replace any dangling/incomplete template entries with the package-owned files.
rm -f "$TARGET_DIR/isolinux.bin" "$TARGET_DIR/vesamenu.c32"
cp -a "$ISOLINUX_BIN" "$TARGET_DIR/isolinux.bin"
cp -a "$VESAMENU_C32" "$TARGET_DIR/vesamenu.c32"

for required in isolinux.bin vesamenu.c32; do
  [[ -s "$TARGET_DIR/$required" ]] || fail "Could not stage required Syslinux boot asset: $TARGET_DIR/$required"
done

printf 'Staged package-provided ISOLINUX assets into %s\n' "$TARGET_DIR"
