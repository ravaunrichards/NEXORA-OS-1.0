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

printf 'NEXORA live-build compatibility test passed: obsolete memtest boot entry is disabled.\n'
