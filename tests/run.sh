#!/bin/sh
# Entry point: `sh tests/run.sh`. Needs sh, curl, python3 (fake server only).
# Exits 0 only if every case passes.
# shellcheck disable=SC2034  # ARBOX, CASE_N and FAKE_* are read by the sourced lib.sh and cases.sh
HERE=$(cd "$(dirname "$0")" && pwd)
ARBOX="${ARBOX_UNDER_TEST:-$HERE/../skills/arbox-api/scripts/arbox}"
SANDBOX="$HERE/.tmp/run.$$"
CASE_N=1
# TEST_SH=dash runs the executor under another shell; resolve it now because some cases shrink PATH.
[ -n "${TEST_SH:-}" ] && TEST_SH=$(command -v "$TEST_SH") && export TEST_SH
mkdir -p "$SANDBOX"

for tool in curl python3; do
  command -v "$tool" >/dev/null 2>&1 || { echo "tests need $tool" >&2; exit 2; }
done

FAKE_LOG="$SANDBOX/fake.log"
FAKE_PORT_FILE="$SANDBOX/fake.port"
python3 -I "$HERE/fake_server.py" "$FAKE_PORT_FILE" "$FAKE_LOG" &
FAKE_PID=$!
# shellcheck disable=SC2329  # invoked through trap
cleanup() {
  kill "$FAKE_PID" 2>/dev/null
  rm -rf "$SANDBOX"
}
trap cleanup EXIT INT TERM
n=0
while [ ! -s "$FAKE_PORT_FILE" ]; do
  n=$((n + 1))
  [ "$n" -gt 100 ] && { echo "fake server did not start" >&2; exit 2; }
  sleep 0.1
done
FAKE_PORT=$(cat "$FAKE_PORT_FILE")
ARBOX_BASE_URL="http://127.0.0.1:$FAKE_PORT/api/public"
export ARBOX_BASE_URL

# shellcheck source=lib.sh
. "$HERE/lib.sh"
# shellcheck source=cases.sh
. "$HERE/cases.sh"

printf '\n%s passed, %s failed\n' "$PASS" "$FAIL"
if [ "$FAIL" -ne 0 ]; then
  printf 'failed cases:%s\n' "$FAILED_NAMES"
  exit 1
fi
exit 0
