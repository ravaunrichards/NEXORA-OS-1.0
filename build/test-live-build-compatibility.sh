#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
BUILD_SCRIPT="$ROOT_DIR/build/build-iso.sh"
ARCHIVE_HELPER="$ROOT_DIR/build/configure-ubuntu-archives.sh"

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_option() {
  local option="$1"
  grep -Eq "^[[:space:]]+$option([[:space:]]|$)" "$BUILD_SCRIPT" || \
    fail "Required live-build option is missing: $option"
}

require_option '--memtest none'
require_option '--mode debian'
require_option '--distribution resolute'
require_option '--parent-distribution resolute'
require_option '--bootstrap-keyring'
require_option '--keyring-packages ubuntu-keyring'
require_option '--initramfs casper'
require_option '--syslinux-theme live-build'
require_option '--security false'
grep -Fq 'export LB_UPDATES=true' "$BUILD_SCRIPT" || \
  fail "The Ubuntu updates pocket must be enabled through the live-build environment."

if grep -Fq -- '--updates ' "$BUILD_SCRIPT"; then
  fail "This live-build version does not accept an --updates command-line option."
fi

if grep -Fq -- '--security true' "$BUILD_SCRIPT"; then
  fail "Generic live-build Debian mode must not generate its invalid Ubuntu security suite."
fi

if grep -Fq -- '--memtest memtest86+' "$BUILD_SCRIPT" || \
   grep -Fq -- '--memtest memtest86 ' "$BUILD_SCRIPT"; then
  fail "The removed legacy memtest entry must not be requested."
fi

if grep -Fq -- '--mode ubuntu' "$BUILD_SCRIPT" || \
   grep -Fq 'ubuntu-oneiric' "$BUILD_SCRIPT" || \
   grep -Fq 'gfxboot-theme-ubuntu' "$BUILD_SCRIPT"; then
  fail "The obsolete Ubuntu-specific live-build boot-theme path was reintroduced."
fi

grep -Fq 'boot=casper console=ttyS0' "$BUILD_SCRIPT" || \
  fail "The live kernel command line must explicitly activate Casper and serial diagnostics."

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
SNAPSHOT="20261109T000000Z"
bash "$ARCHIVE_HELPER" "$TEMP_DIR/config" "$SNAPSHOT"

CHROOT_SECURITY="$TEMP_DIR/config/archives/nexora-security.list.chroot"
BINARY_SECURITY="$TEMP_DIR/config/archives/nexora-security.list.binary"
[[ -s "$CHROOT_SECURITY" ]] || fail "Build-time Ubuntu security pocket source was not generated."
[[ -s "$BINARY_SECURITY" ]] || fail "Runtime Ubuntu security pocket source was not generated."

grep -Fxq "deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://snapshot.ubuntu.com/ubuntu/$SNAPSHOT resolute-security main restricted universe multiverse" "$CHROOT_SECURITY" || \
  fail "Build-time security source must use the selected signed Ubuntu snapshot and resolute-security suite."
grep -Fxq "deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://security.ubuntu.com/ubuntu/ resolute-security main restricted universe multiverse" "$BINARY_SECURITY" || \
  fail "Runtime security source must use the Ubuntu security mirror and resolute-security suite."

if grep -Fq 'resolute/updates' "$CHROOT_SECURITY" "$BINARY_SECURITY"; then
  fail "Invalid Debian-style resolute/updates security suite was generated."
fi

printf 'NEXORA live-build compatibility test passed: generic boot theme, Ubuntu Resolute suite/keyring/Casper, and signed resolute-security sources.\n'
