#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[[ $# -ge 5 ]] || fail "Usage: run-qemu-live-boot.sh log timeout-seconds success-regex -- qemu-command [args...]"
LOG_PATH="$1"
TIMEOUT_SECONDS="$2"
SUCCESS_REGEX="$3"
[[ "$4" == "--" ]] || fail "Expected -- before the QEMU command."
shift 4
(( $# > 0 )) || fail "A QEMU command is required."
[[ "$TIMEOUT_SECONDS" =~ ^[1-9][0-9]{0,3}$ ]] || fail "Timeout must be an integer from 1 to 9999 seconds."
command -v timeout >/dev/null 2>&1 || fail "GNU timeout is required."
command -v python3 >/dev/null 2>&1 || fail "Python 3 is required for the QEMU monitor."

[[ ! -e "$LOG_PATH" ]] || fail "Refusing to overwrite an existing boot log: $LOG_PATH"
mkdir -p "$(dirname -- "$LOG_PATH")"
: > "$LOG_PATH"

SOCKET_ROOT="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
QMP_DIR="$(mktemp -d "$SOCKET_ROOT/nexora-qmp.XXXXXX")"
QMP_SOCKET="$QMP_DIR/monitor.sock"

timeout --signal=TERM --kill-after=15s "${TIMEOUT_SECONDS}s" \
  "$@" -qmp "unix:$QMP_SOCKET,server=on,wait=off" &
QEMU_PID=$!

cleanup() {
  local status=$?
  trap - EXIT INT TERM
  if kill -0 "$QEMU_PID" 2>/dev/null; then
    kill -TERM "$QEMU_PID" 2>/dev/null || true
    wait "$QEMU_PID" 2>/dev/null || true
  fi
  rm -rf -- "$QMP_DIR"
  exit "$status"
}
trap cleanup EXIT INT TERM

deadline=$((SECONDS + TIMEOUT_SECONDS))
boot_seen=0
while (( SECONDS <= deadline )); do
  if grep -Eiq -- "$SUCCESS_REGEX" "$LOG_PATH"; then
    boot_seen=1
    break
  fi
  if ! kill -0 "$QEMU_PID" 2>/dev/null; then
    break
  fi
  sleep 2
done

if (( boot_seen )); then
  # Ask QEMU to exit cleanly as soon as the guest reaches its live userspace
  # target. Fall back to TERM only if the QMP socket is unavailable.
  if ! python3 - "$QMP_SOCKET" <<'PY'
import json
import socket
import sys
import time

path = sys.argv[1]
deadline = time.monotonic() + 8
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.settimeout(5)
try:
    while True:
        try:
            sock.connect(path)
            break
        except OSError:
            if time.monotonic() >= deadline:
                raise
            time.sleep(0.1)

    stream = sock.makefile("rwb", buffering=0)
    greeting = json.loads(stream.readline())
    if "QMP" not in greeting:
        raise RuntimeError("QEMU did not provide a QMP greeting")

    stream.write(b'{"execute":"qmp_capabilities"}\r\n')
    while True:
        response = json.loads(stream.readline())
        if "error" in response:
            raise RuntimeError(f"QMP capability negotiation failed: {response['error']}")
        if "return" in response:
            break

    stream.write(b'{"execute":"quit"}\r\n')
finally:
    sock.close()
PY
  then
    kill -TERM "$QEMU_PID" 2>/dev/null || true
  fi

  qemu_status=0
  wait "$QEMU_PID" || qemu_status=$?
  case "$qemu_status" in
    0|124|143) ;;
    *) fail "QEMU exited unexpectedly after reaching its boot target (status $qemu_status)." ;;
  esac
  printf 'QEMU reached the live userspace target and was shut down (status %s).\n' "$qemu_status"
  exit 0
fi

qemu_status=0
wait "$QEMU_PID" || qemu_status=$?
tail -n 160 "$LOG_PATH" >&2 || true
fail "QEMU did not reach the live userspace target within ${TIMEOUT_SECONDS}s (status $qemu_status)."
