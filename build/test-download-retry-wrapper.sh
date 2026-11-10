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

PATH="$RETRY_BIN:$PATH" NEXORA_TEST_COUNT_FILE="$STATE_FILE" wget -q https://nexora.invalid/test
[[ "$(cat "$STATE_FILE")" == 2 ]] || {
  printf 'ERROR: Expected one retry (2 calls), got %s.\n' "$(cat "$STATE_FILE")" >&2
  exit 1
}

printf 'NEXORA downloader retry test passed: transient failure recovered on retry.\n'
