#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nexora-wget-test.XXXXXX")"
trap 'rm -rf -- "$TMP_ROOT"' EXIT

FAKE_WGET="$TMP_ROOT/fake-wget"
STATE_FILE="$TMP_ROOT/calls"
RETRY_BIN="$TMP_ROOT/retry-bin"

cat > "$FAKE_WGET" <<'FAKE'
#!/usr/bin/env bash
set -Eeuo pipefail
count=0
[[ ! -f "${NEXORA_TEST_COUNT_FILE:?}" ]] || count="$(cat "$NEXORA_TEST_COUNT_FILE")"
count=$((count + 1))
printf '%s\n' "$count" > "$NEXORA_TEST_COUNT_FILE"
if [[ "$count" -eq 1 ]]; then
  exit 7
fi
exit 0
FAKE
chmod 0755 "$FAKE_WGET"

NEXORA_REAL_WGET="$FAKE_WGET" bash "$ROOT_DIR/build/patch-debootstrap-download-retries.sh" "$RETRY_BIN"
bash -n "$RETRY_BIN/wget"

# Preserve the existing generic transient-download retry test.
PATH="$RETRY_BIN:$PATH" NEXORA_TEST_COUNT_FILE="$STATE_FILE" wget -q https://nexora.invalid/test
[[ "$(cat "$STATE_FILE")" == 2 ]] || {
  printf 'ERROR: Expected one retry (2 calls), got %s.\n' "$(cat "$STATE_FILE")" >&2
  exit 1
}

# Prove that only a pinned snapshot .deb URL is rewritten, and that the
# package-relative path and versioned filename remain unchanged.
FALLBACK_WGET="$TMP_ROOT/fallback-wget"
FALLBACK_CALLS="$TMP_ROOT/fallback-calls"
FALLBACK_LOG="$TMP_ROOT/fallback.log"
cat > "$FALLBACK_WGET" <<'FALLBACK'
#!/usr/bin/env bash
set -Eeuo pipefail
url="${!#}"
printf '%s\n' "$url" >> "${NEXORA_TEST_FALLBACK_CALLS:?}"
case "$url" in
  https://snapshot.test/ubuntu/20261109T000000Z/pool/*.deb) exit 8 ;;
  https://archive.test/ubuntu/pool/*.deb) exit 0 ;;
  *) printf 'Unexpected URL in fallback test: %s\n' "$url" >&2; exit 90 ;;
esac
FALLBACK
chmod 0755 "$FALLBACK_WGET"

NEXORA_REAL_WGET="$FALLBACK_WGET" bash "$ROOT_DIR/build/patch-debootstrap-download-retries.sh" "$RETRY_BIN"
NEXORA_SNAPSHOT_MIRROR="https://snapshot.test/ubuntu/20261109T000000Z" \
NEXORA_ARCHIVE_MIRROR="https://archive.test/ubuntu" \
NEXORA_DOWNLOAD_LOG="$FALLBACK_LOG" \
NEXORA_TEST_FALLBACK_CALLS="$FALLBACK_CALLS" \
PATH="$RETRY_BIN:$PATH" \
wget -q -O "$TMP_ROOT/package.deb" \
  "https://snapshot.test/ubuntu/20261109T000000Z/pool/main/example/example_1.2.3_amd64.deb"

[[ "$(wc -l < "$FALLBACK_CALLS" | xargs)" == 2 ]] || {
  printf 'ERROR: Expected snapshot attempt plus one archive fallback.\n' >&2
  exit 1
}
grep -Fxq "https://snapshot.test/ubuntu/20261109T000000Z/pool/main/example/example_1.2.3_amd64.deb" "$FALLBACK_CALLS"
grep -Fxq "https://archive.test/ubuntu/pool/main/example/example_1.2.3_amd64.deb" "$FALLBACK_CALLS"
grep -q "debootstrap must validate the pinned checksum and size" "$FALLBACK_LOG"

printf 'NEXORA downloader tests passed: transient retries and exact-path snapshot package fallback.\n'
