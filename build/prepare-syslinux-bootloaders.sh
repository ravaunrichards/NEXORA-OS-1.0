#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[[ "$#" -ge 1 && "$#" -le 2 ]] || fail "Usage: $0 CONFIG_DIR [LIVE_BUILD_ISOLINUX_DIR]"
CONFIG_DIR="$1"
SOURCE_DIR="${2:-/usr/share/live/build/bootloaders/isolinux}"
TARGET_DIR="$CONFIG_DIR/bootloaders/isolinux"

[[ -n "$CONFIG_DIR" ]] || fail "Configuration directory must not be empty."
[[ -d "$SOURCE_DIR" ]] || fail "live-build Syslinux source directory not found: $SOURCE_DIR"

for required in isolinux.bin vesamenu.c32; do
  [[ -s "$SOURCE_DIR/$required" ]] || fail "Required Syslinux boot asset is missing: $SOURCE_DIR/$required"
done

mkdir -p "$TARGET_DIR"
cp -a "$SOURCE_DIR/." "$TARGET_DIR/"

for required in isolinux.bin vesamenu.c32; do
  [[ -s "$TARGET_DIR/$required" ]] || fail "Could not stage required Syslinux boot asset: $TARGET_DIR/$required"
done

printf 'Staged live-build ISOLINUX assets into %s\n' "$TARGET_DIR"
