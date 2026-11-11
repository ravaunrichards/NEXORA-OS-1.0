#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
BUILD_SCRIPT="$ROOT_DIR/build/build-iso.sh"

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

printf 'NEXORA live-build compatibility test passed: generic boot-theme path, Ubuntu Resolute suite/keyring and Casper remain explicit.\n'
