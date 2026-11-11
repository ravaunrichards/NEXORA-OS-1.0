#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HELPER="$ROOT_DIR/build/prepare-debootstrap-overlay.sh"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nexora-debootstrap-overlay-test.XXXXXX")"
trap 'rm -rf -- "$TMP_ROOT"' EXIT

SOURCE="$TMP_ROOT/source"
OVERLAY="$TMP_ROOT/private-overlay"
mkdir -p "$SOURCE/scripts" "$SOURCE/suites"
cat > "$SOURCE/functions" <<'FIXTURE'
#!/bin/sh
  wgetprogress ()
  {
 [ ! "$VERBOSE" ] && NVSWITCH="-nv"
 local ret=0
 if [ "$USE_DEBIANINSTALLER_INTERACTION" ] && [ "$PROGRESS_NEXT" ]; then
 wget "$@" 2>&1 >/dev/null | $PKGDETAILS "WGET%" $PROGRESS_NOW $PROGRESS_NEXT $PROGRESS_END >&3
 ret=$?
 else
 wget $NVSWITCH "$@"
 ret=$?
 fi
 return $ret
}
FIXTURE
printf '#!/bin/sh\nSUITE=fixture\n' > "$SOURCE/scripts/resolute"
printf 'fixture suite metadata\n' > "$SOURCE/suites/resolute"
chmod 0755 "$SOURCE/functions" "$SOURCE/scripts/resolute"

bash "$HELPER" "$OVERLAY" "$SOURCE"
PATCHED="$OVERLAY/functions"
sh -n "$PATCHED"
grep -Fq '"${NEXORA_RETRY_WGET:?NEXORA_RETRY_WGET must name the private retry wrapper}" "$@" 2>&1 >/dev/null' "$PATCHED"
[[ "$(grep -Fc '"${NEXORA_RETRY_WGET:?NEXORA_RETRY_WGET must name the private retry wrapper}"' "$PATCHED")" == 2 ]]
[[ -s "$OVERLAY/scripts/resolute" ]]
[[ -s "$OVERLAY/suites/resolute" ]]

grep -Fq 'export DEBOOTSTRAP_DIR="$DEBOOTSTRAP_OVERLAY"' "$ROOT_DIR/build/build-iso.sh" || \
  { printf 'ERROR: Build does not export its private debootstrap support directory.\n' >&2; exit 1; }

# The package-owned source remains byte-for-byte unchanged.
grep -Fq 'wget "$@" 2>&1 >/dev/null' "$SOURCE/functions"
grep -Fq 'wget $NVSWITCH "$@"' "$SOURCE/functions"
! grep -Fq 'NEXORA_RETRY_WGET' "$SOURCE/functions"

# The helper must fail closed instead of overwriting an existing overlay.
if bash "$HELPER" "$OVERLAY" "$SOURCE" >/dev/null 2>&1; then
  printf 'ERROR: Helper overwrote an existing private overlay.\n' >&2
  exit 1
fi

printf 'NEXORA debootstrap private-overlay test passed: both wget paths use the explicit retry wrapper and source files remain unchanged.\n'
