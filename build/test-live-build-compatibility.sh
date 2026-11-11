#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
BUILD_SCRIPT="$ROOT_DIR/build/build-iso.sh"

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

grep -Fq -- '--memtest none \' "$BUILD_SCRIPT" || \
  fail "The ISO must skip live-build's incompatible legacy memtest boot entry."

if grep -Fq -- '--memtest memtest86+' "$BUILD_SCRIPT" || grep -Fq -- '--memtest memtest86 ' "$BUILD_SCRIPT"; then
  fail "The incompatible legacy memtest entry must not be requested."
fi

grep -Fq -- '--mode debian \\' "$BUILD_SCRIPT" || \
  fail "The obsolete Ubuntu-mode live-build Syslinux integration must not be selected."
grep -Fq -- '--distribution resolute \\' "$BUILD_SCRIPT" || \
  fail "The target suite must remain Ubuntu Resolute."
grep -Fq -- '--parent-distribution resolute \\' "$BUILD_SCRIPT" || \
  fail "The parent suite must remain Ubuntu Resolute."
grep -Fq -- '--bootstrap-keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg \\' "$BUILD_SCRIPT" || \
  fail "The Ubuntu archive bootstrap keyring must be explicit."
grep -Fq -- '--keyring-packages ubuntu-keyring \\' "$BUILD_SCRIPT" || \
  fail "The target image must include Ubuntu archive trust roots."
grep -Fq -- '--initramfs casper \\' "$BUILD_SCRIPT" || \
  fail "Ubuntu Casper must be the live initramfs."
grep -Fq -- '--syslinux-theme live-build \\' "$BUILD_SCRIPT" || \
  fail "The removed Ubuntu Oneiric Syslinux theme must not be requested."
grep -Fq -- 'boot=casper console=ttyS0' "$BUILD_SCRIPT" || \
  fail "The live kernel command line must explicitly activate Casper."

if grep -Fq -- '--mode ubuntu' "$BUILD_SCRIPT" || grep -Fq 'ubuntu-oneiric' "$BUILD_SCRIPT"; then
  fail "The obsolete Ubuntu-specific live-build boot-theme path was reintroduced."
fi

printf 'NEXORA live-build compatibility test passed: generic boot-theme path is isolated; Ubuntu Resolute, Ubuntu keyring and Casper remain explicit.\n'
