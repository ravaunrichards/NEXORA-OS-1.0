#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HELPER="$ROOT_DIR/build/prepare-casper-syslinux-overlay.sh"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nexora-casper-syslinux-test.XXXXXX")"
trap 'rm -rf -- "$TMP_ROOT"' EXIT

SOURCE="$TMP_ROOT/lb_binary_syslinux"
BOOTLOADERS="$TMP_ROOT/bootloaders"
COMMON_LIBRARY="$TMP_ROOT/live-build.sh"
OVERLAY="$TMP_ROOT/live-build-overlay"
mkdir -p "$BOOTLOADERS/isolinux"
printf 'isolinux template fixture\n' > "$BOOTLOADERS/isolinux/isolinux.cfg"
printf '# packaged common-library fixture\n' > "$COMMON_LIBRARY"

cat > "$SOURCE" <<'FIXTURE'
#!/bin/sh
set -e
# Including common functions
. /usr/lib/${LIVE_BUILD}/build.sh
# Configuring files
if [ -e "${_TARGET}/live.cfg.in" ]
then
    mv binary/live/vmlinuz-* binary/live/vmlinuz
    mv binary/live/initrd.img-* binary/live/initrd.img
    sed -e "s|@KERNEL@|/live/vmlinuz|g" \
        -e "s|@INITRD@|/live/initrd.img|g" \
        "${_TARGET}/live.cfg.in" >> "${_TARGET}/live.cfg"
    mv binary/live/vmlinuz-*-${_FLAVOUR} binary/live/vmlinuz${_NUMBER}
    mv binary/live/initrd.img-*-${_FLAVOUR} binary/live/initrd${_NUMBER}.img
    sed -i -e "s|@KERNEL@|/live/vmlinuz${_NUMBER}|g" \
           -e "s|@INITRD@|/live/initrd${_NUMBER}.img|g" \
        "${_TARGET}/live.cfg"
fi
FIXTURE
chmod 0755 "$SOURCE"

bash "$HELPER" "$OVERLAY" "$SOURCE" "$BOOTLOADERS" "$COMMON_LIBRARY"
PATCHED="$OVERLAY/scripts/build/lb_binary_syslinux"

[[ -x "$PATCHED" ]] || {
  printf 'ERROR: Private Syslinux override was not created.\n' >&2
  exit 1
}
bash -n "$PATCHED"
grep -Fq ". \"$COMMON_LIBRARY\"" "$PATCHED"
! grep -Fq '/usr/lib/${LIVE_BUILD}/build.sh' "$PATCHED"
grep -Fq 'casper) _NEXORA_INITRAMFS_DIR="casper"' "$PATCHED"
grep -Fq 'binary/${_NEXORA_INITRAMFS_DIR}/vmlinuz-*' "$PATCHED"
grep -Fq 'binary/${_NEXORA_INITRAMFS_DIR}/initrd.img-*' "$PATCHED"
grep -Fq '/${_NEXORA_INITRAMFS_DIR}/vmlinuz' "$PATCHED"
grep -Fq '/${_NEXORA_INITRAMFS_DIR}/initrd.img' "$PATCHED"
[[ -L "$OVERLAY/bootloaders" ]]
[[ "$(readlink "$OVERLAY/bootloaders")" == "$BOOTLOADERS" ]]

# The original installed/package script is only read and copied; it is never
# changed in place.
grep -Fq 'binary/live/vmlinuz-*' "$SOURCE"
grep -Fq '/live/vmlinuz' "$SOURCE"
grep -Fq '/usr/lib/${LIVE_BUILD}/build.sh' "$SOURCE"

printf 'NEXORA Casper/Syslinux compatibility overlay test passed; common-library bootstrap corrected and source package file preserved.\n'
