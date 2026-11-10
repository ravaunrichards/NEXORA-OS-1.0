#!/usr/bin/env bash
set -Eeuo pipefail

OUTPUT_DIR="${1:-}"
[[ -n "$OUTPUT_DIR" ]] || {
  printf 'ERROR: Usage: bash build/patch-debootstrap-download-retries.sh /path/to/private-bin\n' >&2
  exit 1
}
REAL_WGET="${NEXORA_REAL_WGET:-$(command -v wget || true)}"
[[ -n "$REAL_WGET" && -x "$REAL_WGET" ]] || {
  printf 'ERROR: A working wget executable is required.\n' >&2
  exit 1
}

mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd -- "$OUTPUT_DIR" && pwd)"
WRAPPER="$OUTPUT_DIR/wget"

{
  printf '#!/usr/bin/env bash\n'
  printf 'set -uo pipefail\n'
  printf 'REAL_WGET=%q\n' "$REAL_WGET"
  cat <<'WRAPPER_BODY'
last_status=1
for attempt in 1 2 3 4; do
  if "$REAL_WGET" "$@"; then
    exit 0
  else
    last_status=$?
  fi

  if [[ "$attempt" -lt 4 ]]; then
    printf 'NEXORA downloader: retrying failed wget request (attempt %s of 4)\n' "$attempt" >&2
    sleep "$attempt"
  fi
done

exit "$last_status"
WRAPPER_BODY
} > "$WRAPPER"

chmod 0755 "$WRAPPER"
printf 'Created isolated four-attempt wget retry wrapper: %s\n' "$WRAPPER"
printf 'The system wget and debootstrap files were not modified.\n'
