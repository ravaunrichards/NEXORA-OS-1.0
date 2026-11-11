#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[[ $# -eq 2 ]] || fail "Usage: $0 OUTPUT_DIR SOURCE_DEBOOTSTRAP_DIR"
OUTPUT_DIR="$1"
SOURCE_DIR="$2"

[[ -d "$SOURCE_DIR" && -s "$SOURCE_DIR/functions" ]] || fail "Debootstrap support directory or functions file is missing: $SOURCE_DIR"
[[ ! -e "$OUTPUT_DIR" ]] || fail "Refusing to overwrite existing private debootstrap overlay: $OUTPUT_DIR"

mkdir -p "$(dirname -- "$OUTPUT_DIR")"
mkdir -p "$OUTPUT_DIR"
cp -a "$SOURCE_DIR/." "$OUTPUT_DIR/"

python3 - "$OUTPUT_DIR/functions" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
start_marker = "wgetprogress () {"
start = text.find(start_marker)
if start < 0 or text.find(start_marker, start + len(start_marker)) >= 0:
    raise SystemExit("ERROR: Expected exactly one debootstrap wgetprogress function.")

end = text.find("\n}\n", start)
if end < 0:
    raise SystemExit("ERROR: Could not identify the end of wgetprogress function.")
end += len("\n}\n")
block = text[start:end]

old_interactive = 'wget "$@" 2>&1 >/dev/null'
old_normal = 'wget $QSWITCH "$@"'
if block.count(old_interactive) != 1 or block.count(old_normal) != 1:
    raise SystemExit("ERROR: Unexpected debootstrap wgetprogress layout; refusing unsafe patch.")

retry_wget = '"${NEXORA_RETRY_WGET:?NEXORA_RETRY_WGET must name the private retry wrapper}"'
block = block.replace(old_interactive, retry_wget + ' "$@" 2>&1 >/dev/null')
block = block.replace(old_normal, retry_wget + ' $QSWITCH "$@"')
path.write_text(text[:start] + block + text[end:], encoding="utf-8")
PY

sh -n "$OUTPUT_DIR/functions" || fail "Patched debootstrap functions file does not parse."
grep -Fq '${NEXORA_RETRY_WGET:?NEXORA_RETRY_WGET must name the private retry wrapper}' "$OUTPUT_DIR/functions" || fail "Private retry-wrapper reference was not installed."
printf 'Created private debootstrap overlay: %s\n' "$OUTPUT_DIR"
printf 'Both HTTPS and ordinary wgetprogress paths call the exact private retry wrapper; system debootstrap files remain unchanged.\n'
