#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nexora-qmp-test.XXXXXX")"
trap 'rm -rf -- "$TMP_ROOT"' EXIT

FAKE_QEMU="$TMP_ROOT/fake-qemu"
LOG="$TMP_ROOT/boot.log"

cat > "$FAKE_QEMU" <<'PY'
#!/usr/bin/env python3
import json
import os
import socket
import sys

args = sys.argv[1:]
try:
    qmp_index = args.index("-qmp")
    qmp_spec = args[qmp_index + 1]
except (ValueError, IndexError):
    raise SystemExit("fake QEMU did not receive a QMP socket")

if not qmp_spec.startswith("unix:"):
    raise SystemExit("fake QEMU received an unexpected QMP transport")

socket_path = qmp_spec.split(":", 1)[1].split(",", 1)[0]
server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
server.bind(socket_path)
server.listen(1)
server.settimeout(10)

with open(os.environ["NEXORA_FAKE_QEMU_LOG"], "a", encoding="utf-8") as log:
    log.write("Reached target graphical.target - Graphical Interface\n")
    log.flush()

connection, _ = server.accept()
connection.settimeout(5)
reader = connection.makefile("rb")
connection.sendall(b'{"QMP":{"version":{"qemu":{"major":8,"minor":0,"micro":0},"package":""},"capabilities":[]}}\r\n')

capabilities = json.loads(reader.readline())
if capabilities.get("execute") != "qmp_capabilities":
    raise SystemExit("QMP capability negotiation was not sent")
connection.sendall(b'{"return":{}}\r\n')

command = json.loads(reader.readline())
if command.get("execute") != "quit":
    raise SystemExit("QMP quit command was not sent")
connection.sendall(b'{"return":{}}\r\n')

reader.close()
connection.close()
server.close()
PY
chmod 0755 "$FAKE_QEMU"

export NEXORA_FAKE_QEMU_LOG="$LOG"
bash "$ROOT_DIR/build/run-qemu-live-boot.sh" \
  "$LOG" \
  30 \
  'Reached target.*graphical[.]target' \
  -- "$FAKE_QEMU"

grep -Eiq 'Reached target.*graphical[.]target' "$LOG" || {
  printf 'ERROR: Fake QEMU did not record its successful boot marker.\n' >&2
  exit 1
}

printf 'NEXORA QEMU early-shutdown test passed: boot marker detected and QMP quit delivered.\n'
