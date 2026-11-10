#!/usr/bin/env bash
set -Eeuo pipefail
umask 022

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[[ $# -eq 2 ]] || fail "Usage: bash build/add-uefi-boot.sh input-bios.iso output-uefi.iso"
INPUT_ISO="$1"
OUTPUT_ISO="$2"

[[ -f "$INPUT_ISO" && -s "$INPUT_ISO" ]] || fail "Input ISO is missing or empty: $INPUT_ISO"
[[ ! -e "$OUTPUT_ISO" ]] || fail "Refusing to overwrite existing output: $OUTPUT_ISO"

INPUT_ISO="$(cd -- "$(dirname -- "$INPUT_ISO")" && pwd)/$(basename -- "$INPUT_ISO")"
OUTPUT_PARENT="$(dirname -- "$OUTPUT_ISO")"
mkdir -p "$OUTPUT_PARENT"
OUTPUT_PARENT="$(cd -- "$OUTPUT_PARENT" && pwd)"
OUTPUT_ISO="$OUTPUT_PARENT/$(basename -- "$OUTPUT_ISO")"
[[ "$INPUT_ISO" != "$OUTPUT_ISO" ]] || fail "Input and output ISO paths must differ."

for command_name in xorriso grub-mkstandalone mkfs.vfat mmd mcopy dd find grep; do
  command -v "$command_name" >/dev/null 2>&1 || fail "Missing UEFI image tool: $command_name"
done

WORK_DIR="$(mktemp -d "${TMPDIR:-/var/tmp}/nexora-uefi.XXXXXX")"
# Keep the private build workspace for diagnosis; CI runners are ephemeral.
ISO_ROOT="$WORK_DIR/iso-root"
mkdir -p "$ISO_ROOT"

BIOS_REPORT="$WORK_DIR/input-eltorito.txt"
xorriso -indev "$INPUT_ISO" -report_el_torito plain > "$BIOS_REPORT" 2>&1 || \
  fail "Could not inspect the input ISO boot catalog."
grep -qi "BIOS" "$BIOS_REPORT" || fail "Input ISO does not expose a BIOS El Torito boot entry."

xorriso -osirrox on -indev "$INPUT_ISO" -extract / "$ISO_ROOT" > "$WORK_DIR/extract.log" 2>&1 || \
  fail "Could not extract the input ISO filesystem for UEFI configuration."

KERNEL_PATH=""
INITRD_PATH=""
BOOT_ARGS=""
for layout in casper live; do
  for kernel_name in vmlinuz vmlinuz.efi; do
    candidate="$ISO_ROOT/$layout/$kernel_name"
    if [[ -f "$candidate" ]]; then
      KERNEL_PATH="/$layout/$kernel_name"
      break 2
    fi
  done
done

[[ -n "$KERNEL_PATH" ]] || fail "No supported live kernel found under /casper or /live."

LAYOUT="${KERNEL_PATH#/}"
LAYOUT="${LAYOUT%%/*}"
case "$LAYOUT" in
  casper)
    BOOT_ARGS="boot=casper quiet splash ---"
    ;;
  live)
    BOOT_ARGS="boot=live components quiet splash"
    ;;
  *)
    fail "Unsupported live kernel layout: $KERNEL_PATH"
    ;;
esac

for initrd_name in initrd initrd.img initrd.lz initrd.gz initrd.xz initrd.img.gz; do
  candidate="$ISO_ROOT/$LAYOUT/$initrd_name"
  if [[ -f "$candidate" ]]; then
    INITRD_PATH="/$LAYOUT/$initrd_name"
    break
  fi
done
[[ -n "$INITRD_PATH" ]] || fail "No supported initrd found under /$LAYOUT."

GRUB_CFG="$WORK_DIR/grub.cfg"
cat > "$GRUB_CFG" <<EOF
set default=0
set timeout=10

menuentry "NEXORA OS 26.04 Live" {
    search --no-floppy --file --set=root $KERNEL_PATH
    linux $KERNEL_PATH $BOOT_ARGS
    initrd $INITRD_PATH
}
EOF

BOOTX64="$WORK_DIR/BOOTX64.EFI"
grub-mkstandalone \
  --format=x86_64-efi \
  --output="$BOOTX64" \
  --modules="part_gpt part_msdos fat iso9660 search search_fs_file normal linux" \
  "boot/grub/grub.cfg=$GRUB_CFG" > "$WORK_DIR/grub-build.log" 2>&1 || \
  fail "grub-mkstandalone could not create the x86_64 UEFI loader."

ESP_IMAGE="$WORK_DIR/nexora-efi.img"
dd if=/dev/zero of="$ESP_IMAGE" bs=1M count=31 status=none
mkfs.vfat -F 16 -n NEXORAESP "$ESP_IMAGE" > "$WORK_DIR/mkfs.log" 2>&1
mmd -i "$ESP_IMAGE" ::/EFI
mmd -i "$ESP_IMAGE" ::/EFI/BOOT
mcopy -i "$ESP_IMAGE" "$BOOTX64" ::/EFI/BOOT/BOOTX64.EFI
mdir -i "$ESP_IMAGE" ::/EFI/BOOT > "$WORK_DIR/esp-files.txt" 2>&1

xorriso \
  -indev "$INPUT_ISO" \
  -outdev "$OUTPUT_ISO" \
  -mkdir /boot \
  -map "$ESP_IMAGE" /boot/nexora-efi.img \
  -boot_image any replay \
  -boot_image any next \
  -boot_image any efi_path=/boot/nexora-efi.img \
  -commit -end > "$WORK_DIR/xorriso-remaster.log" 2>&1 || \
  fail "xorriso could not add the UEFI El Torito boot image."

[[ -s "$OUTPUT_ISO" ]] || fail "The remastered ISO is missing or empty."
FINAL_REPORT="$WORK_DIR/final-eltorito.txt"
xorriso -indev "$OUTPUT_ISO" -report_el_torito plain > "$FINAL_REPORT" 2>&1 || \
  fail "Could not inspect the remastered ISO boot catalog."
grep -qi "BIOS" "$FINAL_REPORT" || {
  printf 'Input boot report:\n' >&2
  cat "$BIOS_REPORT" >&2
  printf 'Remaster log:\n' >&2
  cat "$WORK_DIR/xorriso-remaster.log" >&2
  printf 'Final boot report:\n' >&2
  cat "$FINAL_REPORT" >&2
  fail "Remastered ISO lost its BIOS boot entry."
}
grep -qi "UEFI" "$FINAL_REPORT" || grep -Eqi '0x0*ef|platform.*ef' "$FINAL_REPORT" || {
  printf 'Input boot report:\n' >&2
  cat "$BIOS_REPORT" >&2
  printf 'Remaster log:\n' >&2
  cat "$WORK_DIR/xorriso-remaster.log" >&2
  printf 'Final boot report:\n' >&2
  cat "$FINAL_REPORT" >&2
  fail "Remastered ISO has no detected UEFI El Torito entry."
}

printf 'NEXORA UEFI boot image added successfully.\n'
printf 'Kernel: %s\n' "$KERNEL_PATH"
printf 'Initrd: %s\n' "$INITRD_PATH"
printf 'Boot arguments: %s\n' "$BOOT_ARGS"
printf 'Output ISO: %s\n' "$OUTPUT_ISO"
printf '\nFinal El Torito report:\n'
cat "$FINAL_REPORT"
printf '\nNOTE: This adds standard x86_64 UEFI boot support. It does not provide Secure Boot signing.\n'
