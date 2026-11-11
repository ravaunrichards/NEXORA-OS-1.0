#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HELPER="$ROOT_DIR/build/prepare-syslinux-bootloaders.sh"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nexora-syslinux-stage.XXXXXX")"
trap 'rm -rf -- "$TMP_ROOT"' EXIT

SOURCE="$TMP_ROOT/source"
CONFIG="$TMP_ROOT/config"
mkdir -p "$SOURCE"

printf 'synthetic-isolinux-binary\\n' > "$SOURCE/isolinux.bin"
printf 'synthetic-vesamenu-module\\n' > "$SOURCE/vesamenu.c32"
printf 'synthetic-menu-config\\n' > "$SOURCE/isolinux.cfg"
printf 'synthetic-live-config-template\\n' > "$SOURCE/live.cfg.in"

bash "$HELPER" "$CONFIG" "$SOURCE"
TARGET="$CONFIG/bootloaders/isolinux"

for required in isolinux.bin vesamenu.c32 isolinux.cfg live.cfg.in; do
  [[ -s "$TARGET/$required" ]] || {
    printf 'ERROR: Syslinux staging omitted %s\\n' "$required" >&2
    exit 1
  }
  cmp -s "$SOURCE/$required" "$TARGET/$required" || {
    printf 'ERROR: Staged Syslinux file differs from source: %s\\n' "$required" >&2
    exit 1
  }
done

# A source lacking either binary boot asset must fail closed.
BROKEN_SOURCE="$TMP_ROOT/broken-source"
mkdir -p "$BROKEN_SOURCE"
printf 'only-one-file\\n' > "$BROKEN_SOURCE/isolinux.bin"
if bash "$HELPER" "$TMP_ROOT/broken-config" "$BROKEN_SOURCE" >/dev/null 2>&1; then
  printf 'ERROR: Syslinux staging accepted a missing vesamenu.c32.\\n' >&2
  exit 1
fi

printf 'NEXORA Syslinux bootloader staging test passed.\\n'
