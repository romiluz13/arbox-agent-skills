# Test helpers for tests/run.sh. POSIX sh. Sourced, not executed.
#
# The seam under test is the `arbox` process: argv, env and the profiles file
# in; stdout, stderr, exit code, files and HTTP requests (seen by the fake
# server) out. Nothing here reaches inside the script.

TESTKEY="TESTKEY_aaaa1111bbbb2222cccc3333dddd"

PASS=0
FAIL=0
FAILED_NAMES=""

# new_home: fresh sandbox HOME with an empty ARBOX_HOME; clears the fake log.
new_home() {
  HOME="$SANDBOX/home.$$.$CASE_N"
  CASE_N=$((CASE_N + 1))
  ARBOX_HOME="$HOME/.arbox"
  TMPDIR="$HOME/tmp"
  ACT="$HOME/Arbox/logs/activity.log"
  mkdir -p "$HOME" "$TMPDIR"
  : >"$FAKE_LOG"
  export HOME ARBOX_HOME TMPDIR
}

# write_profiles <content>: create $ARBOX_HOME/profiles with mode 600.
write_profiles() {
  mkdir -p "$ARBOX_HOME"
  printf '%s\n' "$1" >"$ARBOX_HOME/profiles"
  chmod 600 "$ARBOX_HOME/profiles"
}

# mode_of <path>: the rwx mode string, e.g. -rw-------
mode_of() {
  # shellcheck disable=SC2012  # ls -l is the portable way to read a mode string
  ls -ld "$1" | cut -c1-10
}

# run_arbox <args...>: run the executor; set RC, OUT (stdout file), ERR (stderr file).
run_arbox() {
  OUT="$HOME/stdout.txt"
  ERR="$HOME/stderr.txt"
  RC=0
  ${TEST_SH:-sh} "$ARBOX" "$@" >"$OUT" 2>"$ERR" || RC=$?
}

# run_arbox_bg <args...>: like run_arbox but in the background; finish with wait_bg.
run_arbox_bg() {
  OUT="$HOME/stdout.txt"
  ERR="$HOME/stderr.txt"
  (
    rc=0
    ${TEST_SH:-sh} "$ARBOX" "$@" >"$OUT" 2>"$ERR" || rc=$?
    echo "$rc" >"$HOME/bg.rc"
  ) &
  BG_PID=$!
}

wait_bg() {
  wait "$BG_PID"
  RC=$(cat "$HOME/bg.rc")
}

fail() {
  printf '    %s\n' "$1" >&2
  CASE_OK=0
}

assert_rc() {
  [ "$RC" -eq "$1" ] || fail "expected exit $1, got $RC (stderr: $(head -c 300 "$ERR"))"
}

assert_file_has() { # file text
  grep -qF -- "$2" "$1" 2>/dev/null || fail "expected '$2' in $1: $(head -c 300 "$1" 2>/dev/null)"
}

assert_file_lacks() { # file text
  if grep -qF -- "$2" "$1" 2>/dev/null; then fail "did not expect '$2' in $1"; fi
}

assert_out_has() { assert_file_has "$OUT" "$1"; }
assert_err_has() { assert_file_has "$ERR" "$1"; }

# assert_requests <n>: the fake server saw exactly n requests.
assert_requests() {
  got=$(wc -l <"$FAKE_LOG" | tr -d ' ')
  [ "$got" -eq "$1" ] || fail "expected $1 requests, fake server saw $got"
}

# nth_request <n> <field-number>: field of the n-th logged request.
# Fields: 1 N, 2 METHOD, 3 PATH, 4 QUERY, 5 API_KEY, 6 BODY_FILE.
nth_request() {
  awk -F '\t' -v n="$1" -v f="$2" 'NR == n { print $f }' "$FAKE_LOG"
}

# act_field <line> <field>: a column of the activity log. Columns: 1 time,
# 2 verb, 3 profile, 4 method, 5 path, 6 query keys, 7 status, 8 rows, 9 flags.
act_field() {
  awk -F '\t' -v n="$1" -v f="$2" 'NR == n { print $f }' "$ACT"
}

# assert_demo_marker <file>: the response carries a top-level "_demo": true.
assert_demo_marker() {
  grep -Eq '"_demo": *true' "$1" || fail "no \"_demo\": true in $1: $(head -c 200 "$1")"
}

# assert_key_nowhere: the test key appears in no file the executor may have
# written (stdout, stderr, logs, outputs), apart from the profiles file itself.
assert_key_nowhere() {
  hits=$(grep -rlF -- "$TESTKEY" "$HOME" 2>/dev/null | grep -v "/.arbox/profiles$" || true)
  [ -z "$hits" ] || fail "key found in: $hits"
}

# t <name> <function>: run one named case in this shell; the function sets
# failures through fail().
t() {
  CASE_OK=1
  new_home
  "$2"
  if [ "$CASE_OK" -eq 1 ]; then
    PASS=$((PASS + 1))
    printf 'ok    %s\n' "$1"
  else
    FAIL=$((FAIL + 1))
    FAILED_NAMES="$FAILED_NAMES
  $1"
    printf 'FAIL  %s\n' "$1"
  fi
}

# make_path_without <tool>...: build $HOME/nobin containing the tools the
# executor needs except the named ones; prints the directory.
make_path_without() {
  d="$HOME/nobin"
  rm -rf "$d"
  mkdir -p "$d"
  for tool in sh awk cat cp chmod curl date dirname grep head mkdir mktemp mv rm sed sort tr wc uname ls cut tail ps xargs basename readlink env expr cmp diff; do
    skip=0
    for ex in "$@"; do [ "$tool" = "$ex" ] && skip=1; done
    [ "$skip" -eq 1 ] && continue
    if [ -x "/usr/bin/$tool" ]; then src="/usr/bin/$tool"; elif [ -x "/bin/$tool" ]; then src="/bin/$tool"; else src=$(command -v "$tool" 2>/dev/null) || continue; fi
    ln -sf "$src" "$d/$tool"
  done
  printf '%s' "$d"
}
