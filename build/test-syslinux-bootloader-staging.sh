#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HELPER="$ROOT_DIR/build/prepare-syslinux-bootloaders.sh"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nexora-syslinux-stage.XXXXXX")"
trap 'rm -rf -- "$TMP_ROOT"' EXIT

TEMPLATES="$TMP_ROOT/templates"
MODULES="$TMP_ROOT/modules"
ISOLINUX_BIN="$TMP_ROOT/isolinux.bin"
CONFIG="$TMP_ROOT/config"
mkdir -p "$TEMPLATES" "$MODULES"

printf 'template-isolinux-config\\n' > "$TEMPLATES/isolinux.cfg"
printf 'template-live-config\\n' > "$TEMPLATES/live.cfg.in"
printf 'template-menu-config\\n' > "$TEMPLATES/menu.cfg"
printf 'package-isolinux-binary\\n' > "$ISOLINUX_BIN"

for module in ldlinux.c32 libcom32.c32 libutil.c32 vesamenu.c32; do
  printf 'package-module-%s\\n' "$module" > "$MODULES/$module"
done

bash "$HELPER" "$CONFIG" "$TEMPLATES" "$ISOLINUX_BIN" "$MODULES"
TARGET="$CONFIG/bootloaders/isolinux"

for required in isolinux.bin ldlinux.c32 libcom32.c32 libutil.c32 vesamenu.c32 isolinux.cfg live.cfg.in menu.cfg; do
  [[ -s "$TARGET/$required" ]] || {
    printf 'ERROR: Syslinux staging omitted %s\\n' "$required" >&2
    exit 1
  }
done

cmp -s "$ISOLINUX_BIN" "$TARGET/isolinux.bin" || {
  printf 'ERROR: Staged ISOLINUX binary differs from package source.\\n' >&2
  exit 1
}
for module in ldlinux.c32 libcom32.c32 libutil.c32 vesamenu.c32; do
  cmp -s "$MODULES/$module" "$TARGET/$module" || {
    printf 'ERROR: Staged Syslinux module differs from package source: %s\\n' "$module" >&2
    exit 1
  }
done
cmp -s "$TEMPLATES/isolinux.cfg" "$TARGET/isolinux.cfg" || {
  printf 'ERROR: ISOLINUX config template was not preserved.\\n' >&2
  exit 1
}

BROKEN_MODULES="$TMP_ROOT/broken-modules"
mkdir -p "$BROKEN_MODULES"
for module in ldlinux.c32 libcom32.c32 libutil.c32; do
  cp "$MODULES/$module" "$BROKEN_MODULES/$module"
done
if bash "$HELPER" "$TMP_ROOT/broken-config" "$TEMPLATES" "$ISOLINUX_BIN" "$BROKEN_MODULES" >/dev/null 2>&1; then
  printf 'ERROR: Syslinux staging accepted missing vesamenu.c32.\\n' >&2
  exit 1
fi

printf 'NEXORA Syslinux complete BIOS module staging test passed.\\n'
