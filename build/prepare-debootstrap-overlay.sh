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
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")

# Ubuntu revisions vary indentation and may put the opening brace on
# the next line. The body also varies its quiet-switch name (NVSWITCH,
# QSWITCH, etc.), so patch wget command positions rather than flags.
starts = list(re.finditer(
    r"(?m)^[ \t]*wgetprogress[ \t]*\([ \t]*\)[ \t]*(?:\{[ \t]*|$)",
    text,
))
if len(starts) != 1:
    raise SystemExit(f"ERROR: Expected exactly one debootstrap wgetprogress function; found {len(starts)}.")

start_match = starts[0]
line_end = text.find("\n", start_match.start())
if line_end < 0:
    raise SystemExit("ERROR: Truncated wgetprogress declaration.")
declaration = text[start_match.start():line_end]
if "{" in declaration:
    body_open_end = line_end + 1
else:
    cursor = line_end + 1
    while cursor < len(text):
        next_end = text.find("\n", cursor)
        if next_end < 0:
            next_end = len(text)
        candidate = text[cursor:next_end].strip()
        if candidate:
            if candidate != "{":
                raise SystemExit("ERROR: wgetprogress declaration is not followed by an opening brace.")
            body_open_end = next_end + (1 if next_end < len(text) else 0)
            break
        cursor = next_end + 1
    else:
        raise SystemExit("ERROR: Missing opening brace for wgetprogress.")

end_match = re.search(r"(?m)^[ \t]*\}[ \t]*$", text[body_open_end:])
if end_match is None:
    raise SystemExit("ERROR: Could not identify the closing brace of wgetprogress.")

end = body_open_end + end_match.end()
block = text[start_match.start():end]
commands = list(re.finditer(r"(?m)^([ \t]*)wget(?=[ \t])", block))
if len(commands) != 2:
    raise SystemExit(f"ERROR: Expected exactly two wget command paths in wgetprogress; found {len(commands)}.")

retry_wget = '"${NEXORA_RETRY_WGET:?NEXORA_RETRY_WGET must name the private retry wrapper}"'
for match in reversed(commands):
    block = block[:match.start()] + match.group(1) + retry_wget + block[match.end():]

path.write_text(text[:start_match.start()] + block + text[end:], encoding="utf-8")
PY

sh -n "$OUTPUT_DIR/functions" || fail "Patched debootstrap functions file does not parse."
grep -Fq '"${NEXORA_RETRY_WGET:?NEXORA_RETRY_WGET must name the private retry wrapper}"' "$OUTPUT_DIR/functions" && fail "Retry-wrapper template marker was not substituted."
grep -Fq '"${NEXORA_RETRY_WGET:?NEXORA_RETRY_WGET must name the private retry wrapper}"' "$OUTPUT_DIR/functions" || fail "Private retry-wrapper reference was not installed."
[[ "$(grep -Fc '"${NEXORA_RETRY_WGET:?NEXORA_RETRY_WGET must name the private retry wrapper}"' "$OUTPUT_DIR/functions")" == 2 ]] || fail "Expected both wget paths to use the private retry wrapper."
printf 'Created private debootstrap overlay: %s\n' "$OUTPUT_DIR"
printf 'Both HTTPS and ordinary wgetprogress paths call the exact private retry wrapper; system debootstrap files remain unchanged.\n'
