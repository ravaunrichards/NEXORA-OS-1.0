#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_SCRIPT="$ROOT_DIR/build/build-iso.sh"
MANIFEST="$ROOT_DIR/build/packages/nexora-base.list.chroot"

fail() {
  printf 'ERROR: %s\\n' "$*" >&2
  exit 1
}

# Ubuntu 26.04 splits the linux-firmware metapackage into supported
# device-specific packages. Keep that explicit dependency, but do not let
# live-build inject obsolete Debian-oriented firmware package names.
grep -Eq '^[[:space:]]*linux-firmware[[:space:]]*$' "$MANIFEST" || \
  fail "The explicit Ubuntu linux-firmware metapackage is missing."

grep -Eq '^[[:space:]]*--firmware-chroot[[:space:]]+false([[:space:]]|$)' "$BUILD_SCRIPT" || \
  fail "Automatic live-build firmware injection must remain disabled for Ubuntu Resolute."

if grep -Eq '^[[:space:]]*--firmware-chroot[[:space:]]+true([[:space:]]|$)' "$BUILD_SCRIPT"; then
  fail "Obsolete automatic firmware injection was re-enabled."
fi

printf 'NEXORA firmware selection test passed: explicit linux-firmware retained; legacy auto-injection disabled.\\n'
