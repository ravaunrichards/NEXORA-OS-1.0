#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nexora-uefi-test.XXXXXX")"
# CI runners are ephemeral; retain temporary files for failed-test diagnosis.

for command_name in xorriso mcopy mdir dd; do
  command -v "$command_name" >/dev/null 2>&1 || {
    printf 'ERROR: Test dependency missing: %s\n' "$command_name" >&2
    exit 1
  }
done

SOURCE_ROOT="$TMP_ROOT/source"
mkdir -p "$SOURCE_ROOT/isolinux" "$SOURCE_ROOT/casper"
ISOLINUX_SOURCE="/usr/lib/ISOLINUX/isolinux.bin"
[[ -s "$ISOLINUX_SOURCE" ]] || {
  printf 'ERROR: Ubuntu isolinux package did not install %s\n' "$ISOLINUX_SOURCE" >&2
  exit 1
}
cp "$ISOLINUX_SOURCE" "$SOURCE_ROOT/isolinux/isolinux.bin"
printf 'synthetic-kernel-for-structure-test\n' > "$SOURCE_ROOT/casper/vmlinuz"
printf 'synthetic-initrd-for-structure-test\n' > "$SOURCE_ROOT/casper/initrd"

BASE_ISO="$TMP_ROOT/base-bios.iso"
xorriso -as mkisofs \
  -o "$BASE_ISO" \
  -r -J -V NEXORA_TEST \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  "$SOURCE_ROOT" > "$TMP_ROOT/mkisofs.log" 2>&1

BASE_REPORT="$TMP_ROOT/base-eltorito.txt"
xorriso -indev "$BASE_ISO" -report_el_torito plain > "$BASE_REPORT" 2>&1
grep -Eqi 'BIOS|platform.*0x00' "$BASE_REPORT" || {
  printf 'ERROR: Synthetic source image lacks a BIOS El Torito entry.\n' >&2
  cat "$BASE_REPORT" >&2
  exit 1
}

DUAL_ISO="$TMP_ROOT/nexora-dualboot-test.iso"
bash "$ROOT_DIR/build/add-uefi-boot.sh" "$BASE_ISO" "$DUAL_ISO" > "$TMP_ROOT/add-uefi.log"

REPORT="$TMP_ROOT/eltorito.txt"
xorriso -indev "$DUAL_ISO" -report_el_torito plain > "$REPORT" 2>&1

SYSTEM_AREA_REPORT="$TMP_ROOT/system-area.txt"
xorriso -indev "$DUAL_ISO" -report_system_area plain > "$SYSTEM_AREA_REPORT" 2>&1
grep -Eqi '0x0*ef|EFI System|EFI partition' "$SYSTEM_AREA_REPORT" || {
  printf 'ERROR: Hybrid system area has no EFI partition entry.\n' >&2
  cat "$SYSTEM_AREA_REPORT" >&2
  exit 1
}
grep -qi "BIOS" "$REPORT" || {
  printf 'ERROR: Synthetic image lost its BIOS boot entry.\n' >&2
  exit 1
}
grep -qi "UEFI" "$REPORT" || grep -Eqi '0x0*ef|platform.*ef' "$REPORT" || {
  printf 'ERROR: Synthetic image did not gain a UEFI boot entry.\n' >&2
  cat "$REPORT" >&2
  exit 1
}

EXTRACTED_ESP="$TMP_ROOT/esp.img"
xorriso -osirrox on -indev "$DUAL_ISO" -extract /boot/nexora-efi.img "$EXTRACTED_ESP" > "$TMP_ROOT/extract-esp.log" 2>&1
mdir -i "$EXTRACTED_ESP" ::/EFI/BOOT > "$TMP_ROOT/esp-listing.txt"
mcopy -i "$EXTRACTED_ESP" ::/EFI/BOOT/BOOTX64.EFI "$TMP_ROOT/BOOTX64.EFI"
[[ -s "$TMP_ROOT/BOOTX64.EFI" ]] || {
  printf 'ERROR: UEFI fallback loader is missing from the EFI system image.\n' >&2
  exit 1
}

printf 'NEXORA hybrid boot construction test passed (BIOS + UEFI El Torito and EFI partition entry).\n'
cat "$REPORT"
printf '\nSystem area report:\n'
cat "$SYSTEM_AREA_REPORT"
