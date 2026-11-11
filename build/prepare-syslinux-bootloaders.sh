#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  printf 'ERROR: %s\\n' "$*" >&2
  exit 1
}

[[ "$#" -ge 1 && "$#" -le 4 ]] || fail "Usage: $0 CONFIG_DIR [LIVE_BUILD_TEMPLATE_DIR] [ISOLINUX_BIN] [SYSlinux_BIOS_MODULE_DIR]"
CONFIG_DIR="$1"
TEMPLATE_DIR="${2:-/usr/share/live/build/bootloaders/isolinux}"
ISOLINUX_BIN="${3:-/usr/lib/ISOLINUX/isolinux.bin}"
MODULE_DIR="${4:-/usr/lib/syslinux/modules/bios}"
TARGET_DIR="$CONFIG_DIR/bootloaders/isolinux"

[[ -n "$CONFIG_DIR" ]] || fail "Configuration directory must not be empty."
[[ -d "$TEMPLATE_DIR" ]] || fail "live-build ISOLINUX template directory not found: $TEMPLATE_DIR"
[[ -s "$ISOLINUX_BIN" ]] || fail "ISOLINUX boot sector not found: $ISOLINUX_BIN"
[[ -d "$MODULE_DIR" ]] || fail "Syslinux BIOS module directory not found: $MODULE_DIR"

MODULES=(ldlinux.c32 libcom32.c32 libutil.c32 vesamenu.c32)
for required in "${MODULES[@]}"; do
  [[ -s "$MODULE_DIR/$required" ]] || fail "Required Syslinux BIOS module is missing: $MODULE_DIR/$required"
done

mkdir -p "$TARGET_DIR"
cp -a "$TEMPLATE_DIR/." "$TARGET_DIR/"

# Ubuntu packages the ISOLINUX boot sector separately from the BIOS .c32
# modules. The vesamenu module directly needs libutil.c32 and libcom32.c32;
# ISOLINUX 6.x also needs ldlinux.c32. Keep all files from matching packages.
rm -f "$TARGET_DIR/isolinux.bin"
cp -a "$ISOLINUX_BIN" "$TARGET_DIR/isolinux.bin"
for module in "${MODULES[@]}"; do
  rm -f "$TARGET_DIR/$module"
  cp -a "$MODULE_DIR/$module" "$TARGET_DIR/$module"
done

for required in isolinux.bin "${MODULES[@]}"; do
  [[ -s "$TARGET_DIR/$required" ]] || fail "Could not stage required Syslinux boot asset: $TARGET_DIR/$required"
done

printf 'Staged ISOLINUX boot sector and all required BIOS modules into %s\\n' "$TARGET_DIR"
