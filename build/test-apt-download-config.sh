#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT_DIR/build/apt-download.conf"
BUILD_SCRIPT="$ROOT_DIR/build/build-iso.sh"

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

command -v apt-config >/dev/null 2>&1 || fail "apt-config is required for APT configuration validation."
[[ -s "$CONFIG" ]] || fail "APT download configuration is missing or empty."

DUMP="$(mktemp)"
trap 'rm -f -- "$DUMP"' EXIT
apt-config -c "$CONFIG" dump > "$DUMP"

for expected in \
  'Acquire::Retries "8";' \
  'Acquire::Retries::Delay "true";' \
  'Acquire::Retries::Delay::Maximum "60";' \
  'Acquire::Retries::HandleRetryAfter "true";' \
  'Acquire::Queue-Mode "access";'; do
  grep -Fq "$expected" "$DUMP" || fail "APT configuration did not load expected setting: $expected"
done

grep -Fq 'config/apt/apt.conf' "$BUILD_SCRIPT" || \
  fail "The ISO builder does not install the build-time APT configuration."
grep -Fq 'install -m 0644 "$ROOT_DIR/build/apt-download.conf" config/apt/apt.conf' "$BUILD_SCRIPT" || \
  fail "The ISO builder must install the exact tested APT configuration into the live-build apt hook."

printf 'NEXORA APT download resilience test passed: retry/backoff, Retry-After, serialized URI access, and live-build hook wiring verified.\n'
