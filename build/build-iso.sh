#!/usr/bin/env bash
set -Eeuo pipefail
umask 022

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

SNAPSHOT="${NEXORA_SNAPSHOT:-}"
[[ "$SNAPSHOT" =~ ^[0-9]{8}T[0-9]{6}Z$ ]] || fail "Set NEXORA_SNAPSHOT in YYYYMMDDTHHMMSSZ format."
command -v date >/dev/null 2>&1 || fail "GNU date is required."
SNAPSHOT_ISO="${SNAPSHOT:0:4}-${SNAPSHOT:4:2}-${SNAPSHOT:6:2}T${SNAPSHOT:9:2}:${SNAPSHOT:11:2}:${SNAPSHOT:13:2}Z"
SNAPSHOT_EPOCH="$(date -u -d "$SNAPSHOT_ISO" +%s 2>/dev/null)" || fail "Invalid snapshot timestamp."
NORMALIZED_SNAPSHOT="$(date -u -d "@$SNAPSHOT_EPOCH" +%Y%m%dT%H%M%SZ)"
[[ "$NORMALIZED_SNAPSHOT" == "$SNAPSHOT" ]] || fail "Invalid snapshot timestamp."
NOW_EPOCH="$(date -u +%s)"
(( SNAPSHOT_EPOCH <= NOW_EPOCH )) || fail "The selected Ubuntu snapshot timestamp is in the future."

[[ "$EUID" -eq 0 ]] || fail "Run with sudo: sudo env NEXORA_SNAPSHOT=$SNAPSHOT bash build/build-iso.sh"

source /etc/os-release
[[ "${ID:-}" == "ubuntu" && "${VERSION_ID:-}" == "26.04" && "${VERSION_CODENAME:-}" == "resolute" ]] || \
  fail "Build host must be Ubuntu 26.04 LTS (resolute). Detected: ${PRETTY_NAME:-unknown}."

HOST_ARCH="$(dpkg --print-architecture)"
[[ "$HOST_ARCH" == "amd64" ]] || fail "Build host must be amd64; detected: $HOST_ARCH."

for command_name in lb debootstrap mksquashfs unsquashfs xorriso grub-mkrescue grub-mkstandalone mkfs.vfat mmd mcopy sha256sum df awk find grep sort wget python3; do
  command -v "$command_name" >/dev/null 2>&1 || fail "Missing build tool: $command_name. Install the packages listed in build/README.md."
done

bash "$ROOT_DIR/build/validate-config.sh"

MEM_KB="$(awk '/MemTotal:/ {print $2}' /proc/meminfo)"
(( MEM_KB >= 8 * 1024 * 1024 )) || fail "At least 8 GiB RAM is required."

check_free_space() {
  local location="$1"
  local description="$2"
  local free_kb
  free_kb="$(df -Pk "$location" | awk 'END {print $4}')"
  [[ "$free_kb" =~ ^[0-9]+$ ]] || fail "Could not determine free disk space for $description ($location)."
  (( free_kb >= 25 * 1024 * 1024 )) || fail "At least 25 GiB free space is required for $description ($location)."
}

TMP_ROOT="${TMPDIR:-/var/tmp}"
[[ -d "$TMP_ROOT" && -w "$TMP_ROOT" ]] || fail "Temporary workspace location is not writable: $TMP_ROOT"
OUTPUT_DIR="${NEXORA_OUTPUT_DIR:-$ROOT_DIR/dist}"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd -- "$OUTPUT_DIR" && pwd)"

check_free_space "$ROOT_DIR" "the repository filesystem"
check_free_space "$TMP_ROOT" "the build workspace filesystem"
check_free_space "$OUTPUT_DIR" "the ISO output filesystem"

ISO_NAME="NEXORA-26.04-amd64-$SNAPSHOT.iso"
ISO_PATH="$OUTPUT_DIR/$ISO_NAME"
CHECKSUM_PATH="$ISO_PATH.sha256"
INFO_PATH="$OUTPUT_DIR/$ISO_NAME.build-info.txt"

for target in "$ISO_PATH" "$CHECKSUM_PATH" "$INFO_PATH"; do
  [[ ! -e "$target" ]] || fail "Refusing to overwrite existing output: $target"
done

WORK_DIR="$(mktemp -d "$TMP_ROOT/nexora-os-build.XXXXXX")"
printf 'Build workspace: %s\n' "$WORK_DIR"
printf 'Build log: %s\n' "$WORK_DIR/build.log"
RETRY_BIN="$WORK_DIR/retry-bin"
SNAPSHOT_MIRROR="https://snapshot.ubuntu.com/ubuntu/$SNAPSHOT"
ARCHIVE_MIRROR="https://archive.ubuntu.com/ubuntu"
DOWNLOAD_LOG="${NEXORA_DOWNLOAD_LOG:-${RUNNER_TEMP:-$WORK_DIR}/nexora-download-fallback.log}"
mkdir -p "$(dirname -- "$DOWNLOAD_LOG")"
: > "$DOWNLOAD_LOG"
bash "$ROOT_DIR/build/patch-debootstrap-download-retries.sh" "$RETRY_BIN"
LIVE_BUILD_OVERLAY="$WORK_DIR/live-build-overlay"
bash "$ROOT_DIR/build/prepare-casper-syslinux-overlay.sh" "$LIVE_BUILD_OVERLAY"
export LIVE_BUILD="$LIVE_BUILD_OVERLAY"

# Preserve signed package metadata from the dated snapshot. The private
# downloader permits only checksum-pinned, exact-relative-path package/index
# transport fallback; debootstrap validates downloaded content before use.
export NEXORA_SNAPSHOT_MIRROR="$SNAPSHOT_MIRROR"
export NEXORA_ARCHIVE_MIRROR="$ARCHIVE_MIRROR"
export NEXORA_DOWNLOAD_LOG="$DOWNLOAD_LOG"
export PATH="$RETRY_BIN:$PATH"
printf 'Pinned metadata mirror: %s\n' "$NEXORA_SNAPSHOT_MIRROR"
printf 'Exact-path package/index transport fallback: %s\n' "$NEXORA_ARCHIVE_MIRROR"
printf 'Private downloader: %s\n' "$(command -v wget)"

cd "$WORK_DIR"
mkdir -p config/package-lists config/includes.chroot config/archives
cp "$ROOT_DIR/build/packages/nexora-base.list.chroot" config/package-lists/nexora-base.list.chroot
cp -a "$ROOT_DIR/installer/includes.chroot/." config/includes.chroot/
bash "$ROOT_DIR/build/prepare-syslinux-bootloaders.sh" config
bash "$ROOT_DIR/build/configure-ubuntu-archives.sh" config "$SNAPSHOT"

{
  printf 'NEXORA OS engineering ISO build\n'
  printf 'Release: Ubuntu 26.04 (resolute)\n'
  printf 'Architecture: amd64\n'
  printf 'Ubuntu snapshot metadata: %s\n' "$SNAPSHOT"
  printf 'Package/index transport fallback: %s (exact relative path; debootstrap validates pinned checksum and size)\n' "$ARCHIVE_MIRROR"
  printf 'Live-build integration: generic tooling with Ubuntu Resolute suite and Casper explicitly pinned\n'
  printf 'Ubuntu security pocket: resolute-security (signed snapshot metadata)\n'
  printf 'Ubuntu bootstrap keyring: /usr/share/keyrings/ubuntu-archive-keyring.gpg\n'
  printf 'Repository commit: %s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD 2>/dev/null || printf unknown)"
  printf 'Started UTC: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "$WORK_DIR/build-inputs.txt"

# Ubuntu Resolute's packaged live-build Ubuntu mode requests removed legacy
# Oneiric Syslinux/gfxboot packages. Use generic integration while explicitly
# pinning Ubuntu suites, trust roots, archive areas, mirrors and Casper.

# live-build reads updates-pocket enablement from the LB_UPDATES environment variable.
export LB_UPDATES=true
lb config \
  --mode debian \
  --distribution resolute \
  --parent-distribution resolute \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --bootloader syslinux \
  --syslinux-theme live-build \
  --bootstrap-keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg \
  --keyring-packages ubuntu-keyring \
  --initramfs casper \
  --initsystem systemd \
  --memtest none \
  --bootappend-live "boot=casper console=ttyS0,115200n8 console=tty0 systemd.show_status=1 systemd.log_target=console" \
  --system live \
  --archive-areas "main restricted universe multiverse" \
  --parent-archive-areas "main restricted universe multiverse" \
  --mirror-bootstrap "$SNAPSHOT_MIRROR" \
  --parent-mirror-bootstrap "$SNAPSHOT_MIRROR" \
  --mirror-chroot "$SNAPSHOT_MIRROR" \
  --parent-mirror-chroot "$SNAPSHOT_MIRROR" \
  --mirror-binary "https://archive.ubuntu.com/ubuntu" \
  --parent-mirror-binary "https://archive.ubuntu.com/ubuntu" \
  --checksums sha256 \
  --apt-recommends true \
  --apt-secure true \
  --security false \
  --firmware-binary true \
  --firmware-chroot false \
  --debian-installer false \
  --linux-flavours generic \
  --iso-application "NEXORA OS 26.04" \
  --iso-publisher "NEXORA OS Project" \
  --iso-volume "NEXORA_2604" 2>&1 | tee "$WORK_DIR/config.log"

printf 'Starting live-build with Ubuntu Resolute archive metadata and Casper.\n'
lb build 2>&1 | tee "$WORK_DIR/build.log"

# Refuse an image whose actual installed root filesystem is not Ubuntu 26.04
# Resolute. This check runs before the image is copied to the output folder.
mapfile -t ROOTFS_CANDIDATES < <(find "$WORK_DIR/binary" -type f -name filesystem.squashfs -print | sort)
(( ${#ROOTFS_CANDIDATES[@]} == 1 )) || fail "Expected exactly one filesystem.squashfs; found ${#ROOTFS_CANDIDATES[@]}. Workspace retained at $WORK_DIR."
ROOTFS_IMAGE="${ROOTFS_CANDIDATES[0]}"
ROOTFS_OS_RELEASE="$WORK_DIR/rootfs-os-release.txt"
unsquashfs -cat "$ROOTFS_IMAGE" usr/lib/os-release > "$ROOTFS_OS_RELEASE" || fail "Could not read target /usr/lib/os-release."
grep -Eq '^ID="?ubuntu"?$' "$ROOTFS_OS_RELEASE" || fail "Refusing non-Ubuntu root filesystem."
grep -Eq '^VERSION_ID="?26\.04"?$' "$ROOTFS_OS_RELEASE" || fail "Refusing root filesystem outside Ubuntu 26.04."
grep -Eq '^VERSION_CODENAME="?resolute"?$' "$ROOTFS_OS_RELEASE" || fail "Refusing root filesystem outside Ubuntu Resolute."
printf 'Verified target root filesystem: Ubuntu 26.04 (resolute).\n'
printf 'Verified target OS: Ubuntu 26.04 (resolute)\n' >> "$WORK_DIR/build-inputs.txt"

mapfile -t ISO_CANDIDATES < <(find "$WORK_DIR" -type f -name '*.iso' -print | sort)
(( ${#ISO_CANDIDATES[@]} == 1 )) || fail "Expected exactly one generated ISO; found ${#ISO_CANDIDATES[@]}. Workspace retained at $WORK_DIR."
CANDIDATE="${ISO_CANDIDATES[0]}"

DUAL_BOOT_CANDIDATE="$WORK_DIR/$ISO_NAME.dualboot.iso"
bash "$ROOT_DIR/build/add-uefi-boot.sh" "$CANDIDATE" "$DUAL_BOOT_CANDIDATE"
CANDIDATE="$DUAL_BOOT_CANDIDATE"

xorriso -indev "$CANDIDATE" -report_el_torito plain > "$WORK_DIR/eltorito-report.txt" 2>&1 || \
  fail "xorriso could not inspect the generated image. Workspace retained at $WORK_DIR."
grep -qi "BIOS" "$WORK_DIR/eltorito-report.txt" || \
  fail "Generated image has no detectable BIOS boot entry. Workspace retained at $WORK_DIR."
grep -qi "UEFI" "$WORK_DIR/eltorito-report.txt" || grep -Eqi '0x0*ef|platform.*ef' "$WORK_DIR/eltorito-report.txt" || \
  fail "Generated image has no detectable UEFI boot entry. Workspace retained at $WORK_DIR."

xorriso -indev "$CANDIDATE" -report_system_area plain > "$WORK_DIR/system-area-report.txt" 2>&1 || \
  fail "xorriso could not inspect the hybrid system area. Workspace retained at $WORK_DIR."
grep -Eqi 'MBR partition[[:space:]]*:[[:space:]]*[0-9]+[[:space:]]+0x[0-9a-f]+[[:space:]]+0xef' "$WORK_DIR/system-area-report.txt" || \
  fail "Generated image has no EFI-marked MBR partition (type 0xEF). Workspace retained at $WORK_DIR."

install -m 0644 "$CANDIDATE" "$ISO_PATH"
(
  cd "$OUTPUT_DIR"
  sha256sum "$ISO_NAME" > "$ISO_NAME.sha256"
)
cp "$WORK_DIR/build-inputs.txt" "$INFO_PATH"
{
  printf 'Completed UTC: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'ISO: %s\n' "$ISO_PATH"
  printf 'SHA-256: '
  sha256sum "$ISO_PATH" | awk '{print $1}'
  printf 'El Torito report: %s\n' "$WORK_DIR/eltorito-report.txt"
  printf 'Hybrid system area report: %s\n' "$WORK_DIR/system-area-report.txt"
  printf 'Config log: %s\n' "$WORK_DIR/config.log"
  printf 'Build log: %s\n' "$WORK_DIR/build.log"
  printf 'Download fallback log: %s\n' "$DOWNLOAD_LOG"
} >> "$INFO_PATH"

printf '\nBuild produced an engineering ISO: %s\n' "$ISO_PATH"
printf 'Checksum: %s\n' "$CHECKSUM_PATH"
printf 'Build workspace retained for inspection: %s\n' "$WORK_DIR"
printf 'IMPORTANT: Boot-test in both UEFI and BIOS virtual machines before treating this image as usable. The included Calamares installer is experimental; do not install on real disks until disposable-VM acceptance tests pass.\n'
