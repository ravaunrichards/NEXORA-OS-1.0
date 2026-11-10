#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_ROOT="$ROOT_DIR/installer/includes.chroot/etc/calamares"
SETTINGS="$CONFIG_ROOT/settings.conf"
PARTITION="$CONFIG_ROOT/modules/partition.conf"
PACKAGES="$CONFIG_ROOT/modules/packages.conf"
BRANDING="$CONFIG_ROOT/branding/nexora/branding.desc"
DESKTOP="$ROOT_DIR/installer/includes.chroot/usr/share/applications/nexora-installer.desktop"

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

for file in \
  "$SETTINGS" \
  "$PARTITION" \
  "$PACKAGES" \
  "$BRANDING" \
  "$DESKTOP" \
  "$CONFIG_ROOT/modules/unpackfs.conf" \
  "$CONFIG_ROOT/modules/users.conf" \
  "$CONFIG_ROOT/modules/displaymanager.conf" \
  "$CONFIG_ROOT/modules/bootloader.conf" \
  "$CONFIG_ROOT/modules/fstab.conf" \
  "$CONFIG_ROOT/modules/welcome.conf" \
  "$CONFIG_ROOT/modules/shellprocess-cleanup-installer.conf"; do
  [[ -s "$file" ]] || fail "Required installer file missing or empty: $file"
done

grep -Eq '^prompt-install:[[:space:]]*true$' "$SETTINGS" || fail "Final confirmation must be enabled."
grep -Eq '^dont-chroot:[[:space:]]*false$' "$SETTINGS" || fail "Installer must use a target chroot."
grep -Eq '^disable-cancel-during-exec:[[:space:]]*true$' "$SETTINGS" || fail "Cancellation must be locked only during disk-write execution."
grep -Eq '^initialPartitioningChoice:[[:space:]]*none$' "$PARTITION" || fail "Partitioning must require an explicit user choice."
grep -Eq '^enableLuksAutomatedPartitioning:[[:space:]]*false$' "$PARTITION" || fail "Unqualified encrypted install must stay disabled."
grep -Eq '^[[:space:]]*-[[:space:]]*calamares$' "$PACKAGES" || fail "Installed target must remove the live-only installer."
grep -Eq '^Exec=pkexec calamares
for module in welcome locale keyboard partition users summary mount unpackfs machineid fstab localecfg displaymanager networkcfg hwclock initramfscfg initramfs grubcfg bootloader packages shellprocess umount finished; do
  grep -Eq "^[[:space:]]*-[[:space:]]*$module$" "$SETTINGS" || fail "Installer sequence is missing module: $module"
done

printf 'NEXORA installer configuration safeguards passed.\n'
 "$DESKTOP" || fail "Installer launcher must request the privileged Calamares process."
grep -Fq "shellprocess@cleanup-live-installer" "$SETTINGS" || fail "Installer target cleanup step is missing."
grep -Fq "/usr/share/applications/nexora-installer.desktop" "$CONFIG_ROOT/modules/shellprocess-cleanup-installer.conf" || fail "Target cleanup must remove the live-only installer launcher."

for module in welcome locale keyboard partition users summary mount unpackfs machineid fstab localecfg displaymanager networkcfg hwclock initramfscfg initramfs grubcfg bootloader packages shellprocess umount finished; do
  grep -Eq "^[[:space:]]*-[[:space:]]*$module$" "$SETTINGS" || fail "Installer sequence is missing module: $module"
done

printf 'NEXORA installer configuration safeguards passed.\n'
