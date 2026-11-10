#!/usr/bin/env bash
set -Eeuo pipefail

FUNCTIONS_FILE="${DEBOOTSTRAP_FUNCTIONS:-/usr/share/debootstrap/functions}"
[[ -f "$FUNCTIONS_FILE" && -r "$FUNCTIONS_FILE" && -w "$FUNCTIONS_FILE" ]] || {
  printf 'ERROR: Cannot safely patch debootstrap functions file: %s\n' "$FUNCTIONS_FILE" >&2
  exit 1
}
command -v python3 >/dev/null 2>&1 || {
  printf 'ERROR: python3 is required to apply the verified debootstrap retry patch.\n' >&2
  exit 1
}

python3 - "$FUNCTIONS_FILE" <<'PY'
from pathlib import Path
import os
import re
import stat
import sys
import tempfile

path = Path(sys.argv[1])
text = path.read_text()
marker = "# NEXORA_DEBOOTSTRAP_DOWNLOAD_RETRIES: 4 attempts"

start = text.find("download_debs () {")
end = text.find("\ndownload_release () {", start + 1)
if start < 0 or end < 0:
    raise SystemExit("ERROR: Unsupported debootstrap functions layout; file left unchanged.")

section = text[start:end]
if marker in section:
    print(f"debootstrap download retry patch already present: {path}")
    raise SystemExit(0)

pattern = re.compile(
    r'(?m)^(?P<indent>[ \t]*)if get "\$m/\$fil" "\$TARGET/\$debdest" "\$checksum" "\$size"; then\n'
    r'(?P<success>.*?)^(?P=indent)else\n'
    r'(?P<failure>.*?)^(?P=indent)fi\s*$',
    re.S,
)
matches = list(pattern.finditer(section))
if len(matches) != 1:
    raise SystemExit(
        f"ERROR: Expected exactly one debootstrap package-download block, found {len(matches)}; file left unchanged."
    )

match = matches[0]
indent = match.group("indent")
success = match.group("success")
failure = match.group("failure")
replacement = (
    f"{indent}{marker}\n"
    f"{indent}nexora_attempt=1\n"
    f"{indent}nexora_download_ok=false\n"
    f"{indent}while [ \"$nexora_attempt\" -le 4 ]; do\n"
    f"{indent}\tif get \"$m/$fil\" \"$TARGET/$debdest\" \"$checksum\" \"$size\"; then\n"
    f"{success}"
    f"{indent}\t\tnexora_download_ok=true\n"
    f"{indent}\t\tbreak\n"
    f"{indent}\tfi\n"
    f"{indent}\tif [ \"$nexora_attempt\" -lt 4 ]; then\n"
    f"{indent}\t\twarning RETRYING \"Retrying package download %s (attempt %s of 4)\" \"$fil\" \"$nexora_attempt\"\n"
    f"{indent}\t\tsleep \"$nexora_attempt\"\n"
    f"{indent}\tfi\n"
    f"{indent}\tnexora_attempt=\"$(($nexora_attempt + 1))\"\n"
    f"{indent}done\n"
    f"{indent}if [ \"$nexora_download_ok\" = true ]; then\n"
    f"{indent}else\n"
    f"{failure}"
    f"{indent}fi"
)
patched_section = section[:match.start()] + replacement + section[match.end():]
patched = text[:start] + patched_section + text[end:]

mode = stat.S_IMODE(path.stat().st_mode)
fd, temp_name = tempfile.mkstemp(prefix=path.name + ".nexora.", dir=str(path.parent))
try:
    with os.fdopen(fd, "w") as handle:
        handle.write(patched)
        handle.flush()
        os.fsync(handle.fileno())
    os.chmod(temp_name, mode)
    os.replace(temp_name, path)
except Exception:
    try:
        os.unlink(temp_name)
    except FileNotFoundError:
        pass
    raise

print(f"Applied NEXORA 4-attempt transient-download retry patch to {path}")
PY
