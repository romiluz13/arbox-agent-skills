# Named cases for tests/run.sh. Sourced after lib.sh.

case_read_sends_key_header_and_query() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/locations location_id=7
  assert_rc 0
  assert_out_has "Studio Flow"
  assert_requests 1
  [ "$(nth_request 1 2)" = "GET" ] || fail "method was $(nth_request 1 2)"
  [ "$(nth_request 1 3)" = "/api/public/v3/locations" ] || fail "path was $(nth_request 1 3)"
  [ "$(nth_request 1 4)" = "location_id=7" ] || fail "query was $(nth_request 1 4)"
  [ "$(nth_request 1 5)" = "$TESTKEY" ] || fail "server did not receive the key in the api-key header"
}
t "read: GET reaches the fixed path with the key in the api-key header" case_read_sends_key_header_and_query

case_key_not_in_process_list() {
  write_profiles "default=$TESTKEY"
  run_arbox_bg read /v3/slow
  sleep 0.8
  ps -axww -o command= >"$HOME/ps.txt"
  wait_bg
  assert_file_lacks "$HOME/ps.txt" "$TESTKEY"
  assert_file_has "$HOME/ps.txt" "arbox" # the snapshot did catch the running executor
  assert_rc 0
  assert_key_nowhere
}
t "key never appears in the process list during a slow request" case_key_not_in_process_list

case_no_profiles_file() {
  run_arbox read /v3/locations
  assert_rc 3
  assert_err_has "Run: ~/.arbox/bin/arbox setup --prompt (in a new Terminal tab)"
  assert_requests 0
  run_arbox profiles
  assert_rc 3
  assert_err_has "Run: ~/.arbox/bin/arbox setup --prompt (in a new Terminal tab)"
}
t "no profiles file: exit 3 and points to 'setup --prompt' in a new Terminal tab" case_no_profiles_file

case_placeholder_key() {
  write_profiles "default=PASTE_YOUR_ARBOX_KEY_HERE"
  run_arbox read /v3/locations
  assert_rc 3
  assert_err_has "has not been filled in"
  assert_err_has "Run: ~/.arbox/bin/arbox setup --prompt (in a new Terminal tab)"
  assert_requests 0
  write_profiles "downtown=PASTE_YOUR_ARBOX_KEY_HERE"
  run_arbox read -p downtown /v3/locations
  # shellcheck disable=SC2088  # literal ~ in the hint text
  assert_err_has "~/.arbox/bin/arbox setup downtown --prompt (in a new Terminal tab)"
}
t "placeholder key is treated as not set up" case_placeholder_key

case_profile_selection() {
  write_profiles "# my studios
first=$TESTKEY-first

default=$TESTKEY-default
downtown=$TESTKEY-downtown"
  run_arbox read /v3/locations
  assert_rc 0
  [ "$(nth_request 1 5)" = "$TESTKEY-default" ] || fail "default profile not used: $(nth_request 1 5)"
  run_arbox read -p downtown /v3/locations
  [ "$(nth_request 2 5)" = "$TESTKEY-downtown" ] || fail "-p downtown not used: $(nth_request 2 5)"
  write_profiles "first=$TESTKEY-first
second=$TESTKEY-second"
  run_arbox read /v3/locations
  [ "$(nth_request 3 5)" = "$TESTKEY-first" ] || fail "first line not used when there is no default: $(nth_request 3 5)"
  run_arbox read -p nosuch /v3/locations
  assert_rc 3
  assert_err_has "nosuch"
  assert_requests 3
}
t "profiles: default, -p, first-line fallback, comments, unknown name" case_profile_selection

case_crlf_profiles() {
  mkdir -p "$ARBOX_HOME"
  printf 'default=%s\r\n' "$TESTKEY" >"$ARBOX_HOME/profiles"
  chmod 600 "$ARBOX_HOME/profiles"
  run_arbox read /v3/locations
  assert_rc 0
  [ "$(nth_request 1 5)" = "$TESTKEY" ] || fail "CR leaked into the key: $(nth_request 1 5 | od -c | head -2)"
}
t "profiles file with Windows line endings still works" case_crlf_profiles

case_unsafe_key_rejected() {
  write_profiles "default=abc\"def
other=abc def"
  run_arbox read /v3/locations
  assert_rc 3
  assert_err_has "unexpected characters"
  run_arbox read -p other /v3/locations
  assert_rc 3
  assert_requests 0
}
t "keys with quotes or spaces are refused (cannot inject curl config)" case_unsafe_key_rejected

case_401_plain_english() {
  write_profiles "downtown=bad-key-123"
  run_arbox read -p downtown /v3/locations
  assert_rc 4
  assert_err_has "Arbox rejected the key for profile 'downtown'"
  assert_err_has "Settings"
  # shellcheck disable=SC2088  # literal ~ in the hint text
  assert_err_has "~/.arbox/bin/arbox setup downtown --prompt (in a new Terminal tab)"
  assert_file_lacks "$OUT" "Unauthenticated"
}
t "HTTP 401: plain-English message naming the profile, exit 4" case_401_plain_english

case_403_plain_english() {
  write_profiles "default=forbidden-key-123"
  run_arbox read /v3/locations
  assert_rc 4
  assert_err_has "Arbox rejected the key for profile 'default'"
  # shellcheck disable=SC2088  # literal ~ in the hint text
  assert_err_has "~/.arbox/bin/arbox setup --prompt (in a new Terminal tab)"
}
t "HTTP 403: same plain-English message, exit 4" case_403_plain_english

case_error_echo_scrubbed() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/echo401
  assert_rc 4
  assert_err_has "[key hidden]"
  assert_file_lacks "$ERR" "$TESTKEY"
  assert_file_lacks "$OUT" "$TESTKEY"
  run_arbox read /v3/boom
  assert_rc 4
  assert_err_has "HTTP 500"
  assert_file_lacks "$ERR" "$TESTKEY"
  assert_key_nowhere
}
t "HTTP error whose body echoes the request headers never shows the key" case_error_echo_scrubbed

case_422_body_shown() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/422
  assert_rc 4
  assert_err_has "HTTP 422"
  assert_err_has "The phone field is required"
}
t "HTTP 422: status and Arbox's validation message are shown, exit 4" case_422_body_shown

case_unreachable() {
  write_profiles "default=$TESTKEY"
  ARBOX_BASE_URL="http://127.0.0.1:1/api/public" run_arbox read /v3/locations
  assert_rc 4
  assert_err_has "Could not reach Arbox"
}
t "network failure: plain-English message, exit 4" case_unreachable

case_read_refuses_non_get() {
  write_profiles "default=$TESTKEY"
  for m in POST PATCH PUT DELETE; do
    run_arbox read "$m" /v3/tasks
    assert_rc 5
    assert_err_has "arbox write"
  done
  assert_requests 0
  run_arbox read GET /v3/locations
  assert_rc 0
  assert_requests 1
}
t "read refuses every method except GET (exit 5, nothing sent)" case_read_refuses_non_get

case_write_refuses_get() {
  write_profiles "default=$TESTKEY"
  run_arbox write GET /v3/locations --yes-i-confirmed
  assert_rc 5
  assert_err_has "arbox read"
  assert_requests 0
}
t "write refuses GET (exit 5, nothing sent)" case_write_refuses_get

case_write_delete_refused() {
  write_profiles "default=$TESTKEY"
  run_arbox write DELETE /v3/schedule/booking/trial user_id=1 --yes-i-confirmed
  assert_rc 5
  assert_err_has "Arbox app"
  run_arbox write DELETE /v3/users/member/123 --yes-i-confirmed
  assert_rc 5
  assert_requests 0
}
t "write DELETE is refused outright, whatever the path (exit 5)" case_write_delete_refused

# The R3 denylist (docs/research/arbox-endpoints.md): money, identity, delete.
# One line per refused path; matching is case-insensitive and ignores a
# trailing slash. Keep in sync with the denylist block in the script.
R3_PATHS="/v3/users/memberships/cancel
/v3/users/memberships/update
/v3/users/memberships/hold
/v3/users/memberships
/v3/users/group
/v3/users/recurringPayments
/v3/finance/documents
/v3/message"

case_r3_paths_refused() {
  write_profiles "default=$TESTKEY"
  for p in $R3_PATHS; do
    for variant in "$p" "$p/" "$(printf '%s' "$p" | tr '[:lower:]' '[:upper:]' | sed 's/^\/V3/\/v3/')"; do
      run_arbox write POST "$variant" --body '{}' --yes-i-confirmed
      [ "$RC" -eq 5 ] || fail "POST $variant: expected exit 5, got $RC"
      run_arbox write PATCH "$variant" --body '{}' --yes-i-confirmed
      [ "$RC" -eq 5 ] || fail "PATCH $variant: expected exit 5, got $RC"
    done
  done
  assert_err_has "Arbox app"
  assert_requests 0
}
t "R3 paths (money, identity, membership changes, messages) are refused with every flag" case_r3_paths_refused

# The write allowlist (B02.2 #8): the only operations `arbox write` sends.
WRITE_ALLOWED="/v3/leads
/v3/leads/updateStatus
/v3/leads/markAsLost
/v3/leads/createNote
/v3/tasks
/v3/tasks/markAsCompleted/55
/v3/users/createNote"

case_write_allowlist_passes() {
  write_profiles "default=$TESTKEY"
  n=0
  for p in $WRITE_ALLOWED; do
    run_arbox write POST "$p" --body '{}' --yes-i-confirmed
    [ "$RC" -eq 0 ] || fail "POST $p: expected exit 0, got $RC ($(head -c 200 "$ERR"))"
    n=$((n + 1))
    [ "$(nth_request "$n" 3)" = "/api/public$p" ] || fail "POST $p: server saw $(nth_request "$n" 3)"
  done
  assert_requests 7
}
t "write allowlist: the 7 v1 operations (leads, tasks, notes) are sent" case_write_allowlist_passes

WRITE_NOT_ALLOWED="POST /v3/users
POST /v3/users/memberships/qr
POST /v3/users/memberships/document
POST /v3/digitalForms/createLink
POST /v3/message
POST /v3/params
POST /v3/whatever
POST /v3/tasks/
POST /v3/tasks/markAsCompleted
POST /v3/tasks/markAsCompleted/1/2
POST /v3/leads/updateStatus/extra
PATCH /v3/tasks
PATCH /v3/leads
PATCH /v3/users
PATCH /v3/users/injury
PATCH /v3/schedule
PATCH /v3/schedule/"

case_write_allowlist_refuses_everything_else() {
  write_profiles "default=$TESTKEY"
  while IFS=' ' read -r m p; do
    run_arbox write "$m" "$p" --body '{}' --yes-i-confirmed
    [ "$RC" -eq 5 ] || fail "$m $p: expected exit 5, got $RC"
  done <<EOF
$WRITE_NOT_ALLOWED
EOF
  assert_err_has "Arbox app"
  assert_requests 0
}
t "write allowlist: PATCH users/injury/schedule, create user, qr, messages, unknown paths are refused" case_write_allowlist_refuses_everything_else

case_write_needs_confirm_flag() {
  write_profiles "default=$TESTKEY"
  run_arbox write POST /v3/tasks --body '{}'
  assert_rc 2
  assert_err_has "--yes-i-confirmed"
  assert_requests 0
}
t "write without --yes-i-confirmed exits 2 and sends nothing" case_write_needs_confirm_flag

case_write_sends_body_and_logs() {
  write_profiles "default=$TESTKEY"
  printf '{"task_type_id":3,"description":"call Dana"}' >"$HOME/body.json"
  run_arbox write POST /v3/tasks --body-file "$HOME/body.json" --yes-i-confirmed
  assert_rc 0
  [ "$(nth_request 1 2)" = "POST" ] || fail "method"
  assert_file_has "$(nth_request 1 6)" '"description":"call Dana"'
  run_arbox write POST /v3/leads --body '{"lead_id":9}' -p default --yes-i-confirmed
  assert_rc 0
  assert_file_has "$(nth_request 2 6)" '"lead_id":9'
  [ "$(wc -l <"$ACT" | tr -d ' ')" -eq 2 ] || fail "expected 2 log lines"
  [ "$(act_field 1 2)" = "write" ] || fail "verb: $(act_field 1 2)"
  [ "$(act_field 1 3)" = "default" ] || fail "profile: $(act_field 1 3)"
  [ "$(act_field 1 4)" = "POST" ] || fail "method col: $(act_field 1 4)"
  [ "$(act_field 1 5)" = "/v3/tasks" ] || fail "path col: $(act_field 1 5)"
  [ "$(act_field 1 7)" = "200" ] || fail "status col: $(act_field 1 7)"
  [ "$(act_field 2 5)" = "/v3/leads" ] || fail "path col line 2: $(act_field 2 5)"
  assert_file_lacks "$ACT" "Dana"
  assert_file_lacks "$ACT" "$TESTKEY"
  assert_key_nowhere
}
t "write sends the body and logs time/verb/profile/method/path/status (no body, no key)" case_write_sends_body_and_logs

case_failed_write_is_logged() {
  write_profiles "default=bad-key-1"
  run_arbox write POST /v3/tasks --body '{}' --yes-i-confirmed
  assert_rc 4
  [ "$(act_field 1 7)" = "401" ] || fail "401 not logged: $(act_field 1 7)"
  write_profiles "default=$TESTKEY"
  ARBOX_BASE_URL="http://127.0.0.1:1/api/public" run_arbox write POST /v3/tasks --body '{}' --yes-i-confirmed
  assert_rc 4
  [ "$(act_field 2 7)" = "000" ] || fail "unreachable not logged: $(act_field 2 7)"
}
t "failed and unreachable writes are logged with their status" case_failed_write_is_logged

case_base_url_locked() {
  write_profiles "default=$TESTKEY"
  for evil in "https://evil.example.com/api/public" "http://127.0.0.1.evil.com/api/public" "http://localhost@evil.com/api/public" "http://127.0.0.1:1@evil.com/x" "https://127.0.0.1/api/public" "ftp://localhost/x"; do
    ARBOX_BASE_URL="$evil" run_arbox read /v3/locations
    [ "$RC" -eq 5 ] || fail "$evil: expected exit 5, got $RC"
  done
  assert_err_has "ARBOX_BASE_URL"
  assert_requests 0
  assert_key_nowhere
}
t "ARBOX_BASE_URL is refused unless it is http://127.0.0.1 or localhost" case_base_url_locked

case_bad_paths_rejected() {
  write_profiles "default=$TESTKEY"
  for bad in "/v3/../etc/passwd" "https://evil.example.com/v3/x" "/v3/users?active=1" "/v2/users" "v3/users" "//v3/users" "/v3/us ers" "/v3/users#x" "/v3/users/%2e%2e/x" "/v3/a\\b"; do
    run_arbox read "$bad"
    [ "$RC" -eq 2 ] || fail "read '$bad': expected exit 2, got $RC"
  done
  run_arbox write POST "/v3/../x" --body '{}' --yes-i-confirmed
  [ "$RC" -eq 2 ] || fail "write ../ : expected exit 2, got $RC"
  assert_requests 0
}
t "paths must be plain /v3/... paths (no .., URLs, query, spaces, encoded dots)" case_bad_paths_rejected

case_query_params_encoded() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/params 'q=Dana K&co' 'name=שלום' plus=a+b
  assert_rc 0
  assert_out_has '"q":"Dana K&co"'
  assert_out_has '"name":"שלום"'
  assert_out_has '"plus":"a+b"'
  run_arbox write POST /v3/leads user_id=5 'note=x y' --body '{"a":1}' --yes-i-confirmed
  assert_rc 0
  [ "$(nth_request 2 4)" = "user_id=5&note=x%20y" ] || fail "write query was: $(nth_request 2 4)"
  assert_file_has "$(nth_request 2 6)" '{"a":1}'
}
t "query values are percent-encoded (spaces, &, +, Hebrew) for read and write" case_query_params_encoded

case_out_file_and_summary() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/users limit=5 page=1 --out "$HOME/Arbox/work/users.json"
  assert_rc 0
  assert_file_has "$HOME/Arbox/work/users.json" '"first_name":"User5"'
  assert_out_has "5 rows"
  assert_out_has "users.json"
  assert_file_lacks "$OUT" "User1"
  mode=$(mode_of "$HOME/Arbox/work/users.json")
  [ "$mode" = "-rw-------" ] || fail "output file mode is $mode, expected -rw-------"
  run_arbox read /v3/users limit=2
  assert_out_has '"first_name":"User2"'
}
t "--out writes the body to a private file and prints a row-count summary" case_out_file_and_summary

case_all_pages_merged() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/users --all --out "$HOME/Arbox/all.json"
  assert_rc 0
  assert_out_has "1200 rows"
  assert_requests 3
  [ "$(nth_request 1 4)" = "page=1&limit=500" ] || fail "first page query: $(nth_request 1 4)"
  [ "$(nth_request 3 4)" = "page=3&limit=500" ] || fail "third page query: $(nth_request 3 4)"
  rows=$(jq '.data | length' "$HOME/Arbox/all.json")
  [ "$rows" = "1200" ] || fail "merged file has $rows rows"
  first=$(jq -r '.data[0].user_id' "$HOME/Arbox/all.json")
  last=$(jq -r '.data[-1].user_id' "$HOME/Arbox/all.json")
  [ "$first-$last" = "1-1200" ] || fail "merged order wrong: $first-$last"
}
t "--all pages with limit=500 until a short page and merges the rows" case_all_pages_merged

case_all_page_cap() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/endless --all --out "$HOME/Arbox/endless.json"
  assert_rc 0
  assert_requests 20
  assert_err_has "20 pages"
  assert_out_has "INCOMPLETE"
}
t "--all stops at 20 pages and warns that the result is incomplete" case_all_page_cap

case_all_rejects_manual_paging() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/users --all page=2 --out "$HOME/Arbox/x.json"
  assert_rc 2
  assert_err_has "--all"
  assert_requests 0
}
t "--all refuses a hand-set page or limit" case_all_rejects_manual_paging

case_all_without_jq() {
  write_profiles "default=$TESTKEY"
  nobin=$(make_path_without jq)
  PATH="$nobin" run_arbox read /v3/users --all
  assert_rc 2
  assert_err_has "--out"
  PATH="$nobin" run_arbox read /v3/users --all --out "$HOME/Arbox/p/users.json"
  assert_rc 0
  assert_out_has "jq"
  assert_file_has "$HOME/Arbox/p/users.json.manifest.txt" "users.json.page-1.json"
  [ -f "$HOME/Arbox/p/users.json.page-1.json" ] || fail "page 1 file missing"
  [ -f "$HOME/Arbox/p/users.json.page-3.json" ] || fail "page 3 file missing"
}
t "--all without jq writes page files plus a manifest and says so" case_all_without_jq

case_setup_creates_private_file() {
  run_arbox setup
  assert_rc 0
  [ -f "$ARBOX_HOME/profiles" ] || fail "profiles file not created"
  [ "$(mode_of "$ARBOX_HOME/profiles")" = "-rw-------" ] || fail "profiles mode is not 600"
  [ "$(mode_of "$ARBOX_HOME")" = "drwx------" ] || fail "arbox dir mode is not 700"
  assert_file_has "$ARBOX_HOME/profiles" "default=PASTE_YOUR_ARBOX_KEY_HERE"
  assert_out_has "$ARBOX_HOME/profiles"
  assert_out_has "Settings"
  assert_out_has "never paste"
}
t "setup creates a private profiles file with a placeholder and plain instructions" case_setup_creates_private_file

case_setup_keeps_existing_keys() {
  write_profiles "default=$TESTKEY"
  run_arbox setup
  assert_rc 0
  assert_file_has "$ARBOX_HOME/profiles" "default=$TESTKEY"
  assert_file_lacks "$ARBOX_HOME/profiles" "PASTE_YOUR"
  run_arbox setup downtown
  assert_rc 0
  assert_file_has "$ARBOX_HOME/profiles" "default=$TESTKEY"
  assert_file_has "$ARBOX_HOME/profiles" "downtown=PASTE_YOUR_ARBOX_KEY_HERE"
  [ "$(mode_of "$ARBOX_HOME/profiles")" = "-rw-------" ] || fail "profiles mode changed"
  run_arbox setup downtown
  [ "$(grep -c '^downtown=' "$ARBOX_HOME/profiles")" = "1" ] || fail "profile line duplicated"
}
t "setup never overwrites keys and adds a placeholder for a new named profile" case_setup_keeps_existing_keys

case_setup_refuses_key_on_command_line() {
  run_arbox setup "$TESTKEY"
  assert_rc 2
  assert_err_has "never type"
  [ ! -f "$ARBOX_HOME/profiles" ] || fail "profiles file was created from a key-looking argument"
  assert_key_nowhere
  run_arbox setup 'abc=def'
  assert_rc 2
}
t "setup refuses a key (or anything that is not a short label) on the command line" case_setup_refuses_key_on_command_line

case_setup_open_uses_text_editor() {
  mkdir -p "$HOME/fakebin"
  printf '#!/bin/sh\nprintf "%%s\\n" "$*" >"%s/open.args"\n' "$HOME" >"$HOME/fakebin/open"
  printf '#!/bin/sh\necho Darwin\n' >"$HOME/fakebin/uname"
  chmod +x "$HOME/fakebin/open" "$HOME/fakebin/uname"
  nobin=$(make_path_without uname)
  PATH="$HOME/fakebin:$nobin" run_arbox setup --open
  assert_rc 0
  assert_file_has "$HOME/open.args" "-e $ARBOX_HOME/profiles"
}
t "setup --open launches the macOS text editor on the profiles file" case_setup_open_uses_text_editor

case_profiles_lists_names_not_keys() {
  write_profiles "# studios
default=$TESTKEY
downtown=PASTE_YOUR_ARBOX_KEY_HERE
north=$TESTKEY-n"
  run_arbox profiles
  assert_rc 0
  assert_out_has "default"
  assert_out_has "downtown"
  assert_out_has "not filled in"
  assert_out_has "north"
  assert_file_lacks "$OUT" "TESTKEY"
  assert_file_lacks "$ERR" "TESTKEY"
  rm "$ARBOX_HOME/profiles"
  run_arbox profiles
  assert_rc 3
}
t "profiles lists names and whether each is filled in, never the keys" case_profiles_lists_names_not_keys

case_loose_permissions_warning() {
  write_profiles "default=$TESTKEY"
  chmod 644 "$ARBOX_HOME/profiles"
  run_arbox read /v3/locations
  assert_rc 0
  assert_err_has "chmod 600"
  assert_file_lacks "$ERR" "$TESTKEY"
}
t "a profiles file readable by others triggers a warning but still works" case_loose_permissions_warning

case_usage() {
  run_arbox
  assert_rc 2
  assert_err_has "arbox read"
  run_arbox frobnicate
  assert_rc 2
  run_arbox --help
  assert_rc 0
  assert_out_has "arbox write"
}
t "usage: no command or an unknown one exits 2; --help exits 0" case_usage

case_doctor_ready() {
  write_profiles "default=$TESTKEY
north=PASTE_YOUR_ARBOX_KEY_HERE"
  run_arbox doctor
  assert_rc 0
  assert_out_has "curl"
  assert_out_has "jq"
  assert_out_has "python3"
  assert_out_has "node"
  assert_out_has "$ARBOX_HOME/profiles"
  assert_out_has "mode 600"
  assert_out_has "default: key set"
  assert_out_has "north: key NOT filled in"
  assert_out_has "READY"
  assert_file_lacks "$OUT" "TESTKEY"
  assert_requests 0
}
t "doctor lists tools, profiles file mode and profile names, no keys, no network by default" case_doctor_ready

case_doctor_not_ready_and_loose_mode() {
  run_arbox doctor
  assert_rc 3
  assert_out_has "NOT READY"
  assert_out_has "Run: ~/.arbox/bin/arbox setup --prompt (in a new Terminal tab)"
  write_profiles "default=$TESTKEY"
  chmod 644 "$ARBOX_HOME/profiles"
  run_arbox doctor
  assert_out_has "readable by other users"
}
t "doctor says NOT READY (exit 3) with no key and flags a loose file mode" case_doctor_not_ready_and_loose_mode

case_doctor_online_check() {
  write_profiles "default=$TESTKEY
old=bad-key-1"
  run_arbox doctor --online
  assert_rc 4
  assert_out_has "default: connected, 1 location (Studio Flow)"
  assert_out_has "old: Arbox rejected the key"
  assert_requests 2
  assert_file_lacks "$OUT" "$TESTKEY"
}
t "doctor --online tests each profile against /v3/locations and reports rejects" case_doctor_online_check

case_doctor_missing_tools() {
  write_profiles "default=$TESTKEY"
  nobin=$(make_path_without jq python3 node)
  PATH="$nobin" run_arbox doctor
  assert_rc 0
  assert_out_has "jq: not installed"
  assert_out_has "python3: not installed"
  assert_out_has "node: not installed"
  nobin2=$(make_path_without curl)
  PATH="$nobin2" run_arbox doctor
  assert_rc 1
  assert_out_has "curl: NOT FOUND"
}
t "doctor reports missing optional tools and fails (exit 1) without curl" case_doctor_missing_tools

case_doctor_never_runs_macos_python_stub() {
  write_profiles "default=$TESTKEY"
  mkdir -p "$HOME/fakebin"
  printf '#!/bin/sh\necho Darwin\n' >"$HOME/fakebin/uname"
  printf '#!/bin/sh\nexit 2\n' >"$HOME/fakebin/xcode-select"
  printf '#!/bin/sh\ntouch "%s/python3.ran"\necho Python 3.9\n' "$HOME" >"$HOME/fakebin/python3"
  chmod +x "$HOME/fakebin/uname" "$HOME/fakebin/xcode-select" "$HOME/fakebin/python3"
  nobin=$(make_path_without uname python3)
  PATH="$HOME/fakebin:$nobin" run_arbox doctor
  assert_rc 0
  [ ! -e "$HOME/python3.ran" ] || fail "doctor executed python3 although macOS developer tools are missing"
  assert_out_has "python3: not used"
}
t "doctor does not run python3 on a Mac without developer tools (avoids the install dialog)" case_doctor_never_runs_macos_python_stub

case_never_sends_or_clobbers_keys_file() {
  write_profiles "default=$TESTKEY"
  run_arbox write POST /v3/tasks --body-file "$ARBOX_HOME/profiles" --yes-i-confirmed
  assert_rc 5
  assert_err_has "private"
  mkdir -p "$ARBOX_HOME/sub"
  printf 'x' >"$ARBOX_HOME/sub/other.json"
  run_arbox write POST /v3/tasks --body-file "$ARBOX_HOME/sub/other.json" --yes-i-confirmed
  assert_rc 5
  run_arbox read /v3/locations --out "$ARBOX_HOME/profiles"
  assert_rc 5
  assert_file_has "$ARBOX_HOME/profiles" "default=$TESTKEY"
  run_arbox read /v3/locations --out "$ARBOX_HOME/../.arbox/profiles"
  assert_rc 5
  assert_requests 0
}
t "the keys folder can be neither sent as a body nor overwritten by --out" case_never_sends_or_clobbers_keys_file

case_temp_files_cleaned_up() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/locations
  run_arbox read /v3/echo401
  run_arbox write POST /v3/tasks --body '{"a":1}' --yes-i-confirmed
  ARBOX_BASE_URL="http://127.0.0.1:1/api/public" run_arbox read /v3/locations
  left=$(find "$TMPDIR" -mindepth 1 | head -5)
  [ -z "$left" ] || fail "temporary files left behind: $left"
}
t "temporary files (which briefly hold the key and bodies) are removed after every run" case_temp_files_cleaned_up

# ---- B02.2: version, key sanitizing, setup --prompt, demo, activity log, policy ----

case_version() {
  want=$(sed -n 's/^ARBOX_EXECUTOR_VERSION="\(.*\)"$/\1/p' "$ARBOX")
  [ -n "$want" ] || fail "no ARBOX_EXECUTOR_VERSION=\"...\" line in the script"
  run_arbox --version
  assert_rc 0
  assert_out_has "$want"
  write_profiles "default=$TESTKEY"
  run_arbox doctor
  assert_out_has "$want"
}
t "--version prints the executor version and doctor shows it" case_version

case_key_sanitizing() {
  mkdir -p "$ARBOX_HOME"
  {
    printf '# comment\n'
    printf 'padded=   %s-padded   \n' "$TESTKEY"
    printf 'straight="%s-straight"\n' "$TESTKEY"
    printf "single='%s-single'\\n" "$TESTKEY"
    printf 'curly=\342\200\234%s-curly\342\200\235\n' "$TESTKEY"
    printf 'curlysingle=\342\200\230%s-cs\342\200\231\n' "$TESTKEY"
    printf 'crlf=%s-crlf\r\n' "$TESTKEY"
    printf 'bom=\357\273\277%s-bom\n' "$TESTKEY"
    printf 'mixed= \342\200\234 %s-mixed \342\200\235 \r\n' "$TESTKEY"
  } >"$ARBOX_HOME/profiles"
  chmod 600 "$ARBOX_HOME/profiles"
  n=0
  for suffix in padded straight single curly cs crlf bom mixed; do
    case $suffix in
      cs) prof=curlysingle ;;
      *) prof=$suffix ;;
    esac
    run_arbox read -p "$prof" /v3/locations
    n=$((n + 1))
    [ "$RC" -eq 0 ] || fail "profile $prof: exit $RC ($(head -c 200 "$ERR"))"
    [ "$(nth_request "$n" 5)" = "$TESTKEY-$suffix" ] || fail "profile $prof: server got key '$(nth_request "$n" 5)'"
  done
}
t "keys are sanitized: spaces, CR, straight and curly quotes, BOM are stripped" case_key_sanitizing

case_key_sanitizing_bom_at_file_start() {
  mkdir -p "$ARBOX_HOME"
  printf '\357\273\277default=%s\n' "$TESTKEY" >"$ARBOX_HOME/profiles"
  chmod 600 "$ARBOX_HOME/profiles"
  run_arbox read /v3/locations
  assert_rc 0
  [ "$(nth_request 1 5)" = "$TESTKEY" ] || fail "BOM at start of file broke the profile name or key"
}
t "a BOM at the very start of the profiles file does not break the first profile" case_key_sanitizing_bom_at_file_start

case_key_rejected_inside_space_and_rtf() {
  write_profiles "spaced=abc def
good=$TESTKEY"
  run_arbox read -p spaced /v3/locations
  assert_rc 3
  assert_err_has "spaces"
  write_profiles "rtfval={\\rtf1\\ansi
good=$TESTKEY"
  run_arbox read -p rtfval /v3/locations
  assert_rc 3
  assert_err_has "Plain Text"
  assert_requests 0
  mkdir -p "$ARBOX_HOME"
  printf '{\\rtf1\\ansi\\ansicpg1252\\cocoartf2761\n{\\fonttbl}\ndefault=%s\\\n}\n' "$TESTKEY" >"$ARBOX_HOME/profiles"
  chmod 600 "$ARBOX_HOME/profiles"
  run_arbox read /v3/locations
  assert_rc 3
  assert_err_has "Plain Text"
  assert_requests 0
  run_arbox doctor
  assert_out_has "Rich Text"
}
t "keys with inner spaces and RTF files saved by TextEdit are refused with a plain message" case_key_rejected_inside_space_and_rtf

case_setup_prompt_needs_terminal() {
  run_arbox setup --prompt </dev/null
  assert_rc 2
  assert_err_has "open a new Terminal tab and run: ~/.arbox/bin/arbox setup --prompt"
  [ ! -f "$ARBOX_HOME/profiles" ] || fail "profiles file created without a terminal"
  ARBOX_TEST_KEY_INPUT="$TESTKEY" ARBOX_BASE_URL="https://example.com/api" run_arbox setup --prompt </dev/null
  assert_rc 2
  [ ! -f "$ARBOX_HOME/profiles" ] || fail "test hook honored although ARBOX_BASE_URL is not local"
  ARBOX_TEST_KEY_INPUT="$TESTKEY" ARBOX_BASE_URL="" run_arbox setup --prompt </dev/null
  assert_rc 2
  [ ! -f "$ARBOX_HOME/profiles" ] || fail "test hook honored with no ARBOX_BASE_URL"
  assert_key_nowhere
}
t "setup --prompt without a terminal exits 2 and says how to run it (test hook only works against localhost)" case_setup_prompt_needs_terminal

case_setup_prompt_writes_key() {
  old_umask=$(umask)
  umask 022
  lq=$(printf '\342\200\234')
  rq=$(printf '\342\200\235')
  ARBOX_TEST_KEY_INPUT="  $lq$TESTKEY-one$rq  " run_arbox setup --prompt </dev/null
  assert_rc 0
  [ "$(mode_of "$ARBOX_HOME/profiles")" = "-rw-------" ] || fail "profiles mode is $(mode_of "$ARBOX_HOME/profiles")"
  [ "$(mode_of "$ARBOX_HOME")" = "drwx------" ] || fail "dir mode is $(mode_of "$ARBOX_HOME")"
  assert_file_has "$ARBOX_HOME/profiles" "default=$TESTKEY-one"
  assert_file_lacks "$OUT" "$TESTKEY"
  assert_file_lacks "$ERR" "$TESTKEY"
  assert_out_has "default"
  write_profiles "# my keys
default=$TESTKEY-one
downtown=PASTE_YOUR_ARBOX_KEY_HERE
north=$TESTKEY-north
downtown=$TESTKEY-dup"
  ARBOX_TEST_KEY_INPUT="$TESTKEY-two" run_arbox setup downtown --prompt </dev/null
  assert_rc 0
  assert_file_has "$ARBOX_HOME/profiles" "# my keys"
  assert_file_has "$ARBOX_HOME/profiles" "default=$TESTKEY-one"
  assert_file_has "$ARBOX_HOME/profiles" "north=$TESTKEY-north"
  assert_file_has "$ARBOX_HOME/profiles" "downtown=$TESTKEY-two"
  assert_file_lacks "$ARBOX_HOME/profiles" "PASTE_YOUR"
  assert_file_lacks "$ARBOX_HOME/profiles" "$TESTKEY-dup"
  [ "$(grep -c '^downtown=' "$ARBOX_HOME/profiles")" = "1" ] || fail "downtown line count"
  [ "$(mode_of "$ARBOX_HOME/profiles")" = "-rw-------" ] || fail "profiles mode after replace"
  ARBOX_TEST_KEY_INPUT="$TESTKEY-three" run_arbox setup fresh --prompt </dev/null
  assert_rc 0
  assert_file_has "$ARBOX_HOME/profiles" "fresh=$TESTKEY-three"
  assert_file_lacks "$OUT" "$TESTKEY"
  assert_file_lacks "$ERR" "$TESTKEY"
  run_arbox read -p downtown /v3/locations
  [ "$(nth_request 1 5)" = "$TESTKEY-two" ] || fail "new key not usable"
  umask "$old_umask"
}
t "setup --prompt writes or replaces only that profile's line, sanitizes, keeps mode 600, never prints the key" case_setup_prompt_writes_key

case_setup_prompt_rejects_bad_input() {
  write_profiles "default=$TESTKEY-keep"
  for bad in "" "two words" 'abc"def' '{\rtf1 abc'; do
    ARBOX_TEST_KEY_INPUT="$bad" run_arbox setup --prompt </dev/null
    [ "$RC" -eq 3 ] || fail "input '$bad': expected exit 3, got $RC"
  done
  assert_file_has "$ARBOX_HOME/profiles" "default=$TESTKEY-keep"
  [ "$(wc -l <"$ARBOX_HOME/profiles" | tr -d ' ')" -eq 1 ] || fail "profiles file changed after rejected input"
}
t "setup --prompt refuses an empty or malformed key and leaves the file alone" case_setup_prompt_rejects_bad_input

# ---- demo mode ----

case_demo_needs_no_key_or_network() {
  run_arbox read --demo /v3/locations
  assert_rc 0
  assert_demo_marker "$OUT"
  assert_out_has "Studio Demo"
  assert_err_has "SAMPLE DATA"
  assert_requests 0
  ARBOX_DEMO=1 run_arbox read /v3/locations location_id=7 limit=5
  assert_rc 0
  assert_demo_marker "$OUT"
  assert_requests 0
  nobin=$(make_path_without curl)
  PATH="$nobin" run_arbox read --demo /v3/locations
  assert_rc 0
  assert_out_has "Studio Demo"
  ARBOX_BASE_URL="http://127.0.0.1:1/api/public" run_arbox read --demo /v3/locations
  assert_rc 0
  assert_requests 0
}
t "demo: read --demo and ARBOX_DEMO=1 work with no key, no network and no curl" case_demo_needs_no_key_or_network

case_demo_serves_every_fixture_byte_for_byte() {
  demo_dir="$HERE/../skills/arbox-api/assets/demo"
  count=0
  for f in "$demo_dir"/v3__*.json; do
    name=$(basename "$f" .json)
    apath="/$(printf '%s' "$name" | sed 's,__,/,g')"
    run_arbox read --demo "$apath"
    [ "$RC" -eq 0 ] || fail "$apath: exit $RC ($(head -c 200 "$ERR"))"
    cmp -s "$OUT" "$f" || fail "$apath: output differs from $name.json"
    grep -q '"_demo": *true' "$f" || fail "$name.json has no top-level _demo"
    count=$((count + 1))
  done
  [ "$count" -ge 20 ] || fail "only $count fixtures found"
  assert_requests 0
}
t "demo: every fixture is served unchanged under its API path" case_demo_serves_every_fixture_byte_for_byte

case_demo_page_and_missing() {
  run_arbox read --demo /v3/users page=2
  assert_rc 0
  assert_out_has '"data":[]'
  assert_file_lacks "$OUT" "Demo"
  run_arbox read --demo /v3/users page=1
  assert_out_has '"user_id"'
  run_arbox read --demo /v3/reports/noSuchReport
  assert_rc 4
  assert_err_has "no sample data for /v3/reports/noSuchReport"
  run_arbox read --demo /v3/../x
  assert_rc 2
  run_arbox read --demo POST /v3/users
  assert_rc 5
  assert_requests 0
}
t "demo: page above 1 is empty, a missing fixture is exit 4, bad paths and non-GET still refused" case_demo_page_and_missing

case_demo_install_layouts() {
  saved=$ARBOX
  mkdir -p "$ARBOX_HOME/bin"
  cp "$saved" "$ARBOX_HOME/bin/arbox"
  cp -R "$HERE/../skills/arbox-api/assets/demo" "$ARBOX_HOME/demo"
  ARBOX="$ARBOX_HOME/bin/arbox"
  run_arbox read --demo /v3/locations
  [ "$RC" -eq 0 ] || fail "installed layout (~/.arbox/bin + ~/.arbox/demo): exit $RC ($(head -c 200 "$ERR"))"
  assert_out_has "Studio Demo"
  ln -s "$saved" "$HOME/arbox-link"
  ARBOX="$HOME/arbox-link"
  run_arbox read --demo /v3/locations
  [ "$RC" -eq 0 ] || fail "symlinked script: exit $RC"
  ARBOX=$saved
  rm -rf "$ARBOX_HOME/demo"
  mkdir -p "$HOME/lonely"
  cp "$saved" "$HOME/lonely/arbox"
  ARBOX="$HOME/lonely/arbox"
  run_arbox read --demo /v3/locations
  ARBOX=$saved
  [ "$RC" -eq 4 ] || fail "no fixtures anywhere: expected exit 4, got $RC"
  assert_err_has "no sample data"
}
t "demo: fixtures are found next to the script (also via symlink) or in ~/.arbox/demo after install" case_demo_install_layouts

case_demo_never_writes() {
  write_profiles "default=$TESTKEY"
  ARBOX_DEMO=1 run_arbox write POST /v3/tasks --body '{}' --yes-i-confirmed
  assert_rc 5
  assert_err_has "sample"
  assert_requests 0
}
t "demo: ARBOX_DEMO=1 never lets a write through" case_demo_never_writes

case_demo_out_and_fake_server_reuse() {
  run_arbox read --demo /v3/users --out "$HOME/Arbox/work/demo-users.json"
  assert_rc 0
  assert_out_has "40 rows"
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/reports/debtReport
  assert_rc 0
  assert_demo_marker "$OUT"
  assert_requests 1
}
t "demo: --out summarizes rows; the fake server reuses the same fixtures" case_demo_out_and_fake_server_reuse

# ---- activity log ----

case_activity_log_every_call() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/locations location_id=7
  run_arbox read /v3/users search=Dana page=1 limit=2
  run_arbox read --demo /v3/locations
  run_arbox read POST /v3/tasks
  run_arbox write POST /v3/users --body '{"secret":"BODYMARK"}' --yes-i-confirmed
  run_arbox write POST /v3/tasks --body '{"secret":"BODYMARK"}' --yes-i-confirmed
  [ "$(wc -l <"$ACT" | tr -d ' ')" -eq 6 ] || fail "expected 6 activity lines, got $(wc -l <"$ACT")"
  [ "$(act_field 1 2)|$(act_field 1 4)|$(act_field 1 5)|$(act_field 1 6)|$(act_field 1 7)|$(act_field 1 8)" = "read|GET|/v3/locations|location_id|200|1" ] || fail "line 1: $(sed -n 1p "$ACT")"
  [ "$(act_field 2 6)" = "search,page,limit" ] || fail "line 2 keys: $(act_field 2 6)"
  [ "$(act_field 3 2)|$(act_field 3 7)" = "demo|demo" ] || fail "line 3: $(sed -n 3p "$ACT")"
  [ "$(act_field 4 2)|$(act_field 4 4)|$(act_field 4 5)|$(act_field 4 7)" = "read|POST|/v3/tasks|refused" ] || fail "line 4: $(sed -n 4p "$ACT")"
  [ "$(act_field 5 2)|$(act_field 5 4)|$(act_field 5 5)|$(act_field 5 7)" = "write|POST|/v3/users|refused" ] || fail "line 5: $(sed -n 5p "$ACT")"
  [ "$(act_field 6 2)|$(act_field 6 7)|$(act_field 6 9)" = "write|200|confirmed" ] || fail "line 6: $(sed -n 6p "$ACT")"
  for i in 1 2 3 4 5 6; do
    act_field "$i" 1 | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' || fail "line $i time is not ISO: $(act_field "$i" 1)"
  done
  assert_file_lacks "$ACT" "Dana"
  assert_file_lacks "$ACT" "BODYMARK"
  assert_file_lacks "$ACT" "$TESTKEY"
  assert_key_nowhere
}
t "activity log: every read, write, demo and refused call is one line; keys of filters only, never values, bodies or the key" case_activity_log_every_call

case_activity_log_private() {
  write_profiles "default=$TESTKEY"
  old_umask=$(umask)
  umask 022
  run_arbox read /v3/locations
  run_arbox read /v3/users --out "$HOME/Arbox/work/u.json" limit=2
  umask "$old_umask"
  [ "$(mode_of "$ACT")" = "-rw-------" ] || fail "activity.log mode is $(mode_of "$ACT")"
  [ "$(mode_of "$HOME/Arbox")" = "drwx------" ] || fail "Arbox folder mode is $(mode_of "$HOME/Arbox")"
  [ "$(mode_of "$HOME/Arbox/logs")" = "drwx------" ] || fail "logs dir mode is $(mode_of "$HOME/Arbox/logs")"
  [ "$(mode_of "$HOME/Arbox/work")" = "drwx------" ] || fail "work dir mode is $(mode_of "$HOME/Arbox/work")"
  [ "$(mode_of "$HOME/Arbox/work/u.json")" = "-rw-------" ] || fail "out file mode"
}
t "umask 077: log, ~/Arbox and --out folders are owner-only even when the caller's umask is 022" case_activity_log_private

# ---- policy: bookings, --out confinement, possibly-writing GET ----

case_bookings_refused() {
  write_profiles "default=$TESTKEY"
  for spec in "POST /v3/schedule/bookSession" "POST /v3/schedule/cancelUserBooking" "POST /v3/schedule/booking/trial" "DELETE /v3/schedule/booking/trial" "PATCH /v3/schedule"; do
    m=${spec%% *}
    p=${spec#* }
    run_arbox write "$m" "$p" --body '{}' --yes-i-confirmed
    [ "$RC" -eq 5 ] || fail "$spec: expected exit 5, got $RC"
    grep -q "Arbox app" "$ERR" || fail "$spec: message lacks 'Arbox app'"
    grep -q "prepare the list" "$ERR" || fail "$spec: message lacks 'prepare the list': $(head -c 200 "$ERR")"
  done
  assert_requests 0
}
t "no agent bookings in v1: bookSession, cancelUserBooking, trial booking (POST and DELETE) and PATCH schedule are refused" case_bookings_refused

case_out_confined_to_arbox_folder() {
  write_profiles "default=$TESTKEY"
  printf 'keep me' >"$HOME/.zshrc"
  printf 'victim' >"$HOME/victim.txt"
  mkdir -p "$HOME/Arbox" "$HOME/elsewhere"
  ln -s "$HOME/victim.txt" "$HOME/Arbox/link.json"
  ln -s "$HOME/elsewhere" "$HOME/Arbox/dirlink"
  for bad in "$HOME/.zshrc" "$HOME/elsewhere/x.json" "$HOME/Arbox/../x.json" "$HOME/Arbox/work/../../x.json" "../x.json" "$HOME/Arbox/link.json" "$HOME/Arbox/dirlink/x.json" "/etc/arbox-test.json" "$HOME/ArboxEvil/x.json" "$HOME/Arbox"; do
    run_arbox read /v3/locations --out "$bad"
    [ "$RC" -eq 5 ] || fail "--out $bad: expected exit 5, got $RC"
  done
  [ "$(cat "$HOME/.zshrc")" = "keep me" ] || fail ".zshrc was modified"
  [ "$(cat "$HOME/victim.txt")" = "victim" ] || fail "symlink target was modified"
  [ ! -e "$HOME/elsewhere/x.json" ] || fail "file written through a directory symlink"
  [ ! -e "$HOME/x.json" ] || fail "file written above ~/Arbox"
  assert_requests 0
  run_arbox read /v3/locations --out "$HOME/Arbox/work/ok.json"
  assert_rc 0
  assert_file_has "$HOME/Arbox/work/ok.json" "Studio Flow"
  run_arbox read /v3/users --all --out "$HOME/elsewhere/all.json"
  assert_rc 5
  assert_requests 1
  cd "$HOME/Arbox" || fail "cannot cd to ~/Arbox"
  run_arbox read /v3/locations --out "rel.json"
  assert_rc 0
  [ -f "$HOME/Arbox/rel.json" ] || fail "relative --out inside ~/Arbox was not written"
  cd "$HOME" || fail "cannot cd home"
  run_arbox read /v3/locations --out "rel2.json"
  assert_rc 5
  cd "$HERE" || true
}
t "--out is confined to ~/Arbox: ~/.zshrc, .., outside paths and symlinks (file or folder) are refused before any request" case_out_confined_to_arbox_folder

case_entry_from_waiting_list_confirm() {
  write_profiles "default=$TESTKEY"
  for q in confirm=1 confirm=0 Confirm=1 confirm=; do
    run_arbox read /v3/schedule/entryFromWaitingList "$q" schedule_id=5
    [ "$RC" -eq 5 ] || fail "$q: expected exit 5, got $RC"
  done
  run_arbox read /v3/schedule/entryfromwaitinglist confirm=1
  assert_rc 5
  assert_err_has "LIVE CHECK"
  assert_requests 0
  run_arbox read /v3/schedule/entryFromWaitingList schedule_id=5
  [ "$RC" -ne 5 ] || fail "plain lookup without confirm was refused"
  assert_requests 1
  [ "$(act_field 5 7)" = "refused" ] || fail "refusal not logged"
}
t "read refuses entryFromWaitingList whenever a confirm param is present (possibly-writing GET)" case_entry_from_waiting_list_confirm

# ---- B02.3: arbox install, the "run it from ~/.arbox/bin" tip, doctor's copy check ----

DEMO_SRC="$HERE/../skills/arbox-api/assets/demo"
INSTALLED_COPY() { printf '%s' "$ARBOX_HOME/bin/arbox"; }

# set_installed_version <x.y.z>: rewrite the version line of the installed copy.
set_installed_version() {
  sed "s/^ARBOX_EXECUTOR_VERSION=.*/ARBOX_EXECUTOR_VERSION=\"$1\"/" "$(INSTALLED_COPY)" >"$HOME/edit.tmp"
  cp "$HOME/edit.tmp" "$(INSTALLED_COPY)"
  chmod 700 "$(INSTALLED_COPY)"
}

case_install_fresh() {
  want=$(sed -n 's/^ARBOX_EXECUTOR_VERSION="\(.*\)"$/\1/p' "$ARBOX")
  run_arbox install
  assert_rc 0
  assert_out_has "installed arbox $want at ~/.arbox/bin/arbox"
  cmp -s "$ARBOX" "$(INSTALLED_COPY)" || fail "installed copy differs from the running script"
  [ "$(mode_of "$(INSTALLED_COPY)")" = "-rwx------" ] || fail "installed copy mode is $(mode_of "$(INSTALLED_COPY)")"
  [ "$(mode_of "$ARBOX_HOME/bin")" = "drwx------" ] || fail "bin dir mode is $(mode_of "$ARBOX_HOME/bin")"
  [ "$(mode_of "$ARBOX_HOME")" = "drwx------" ] || fail ".arbox folder mode is $(mode_of "$ARBOX_HOME")"
  diff -r "$DEMO_SRC" "$ARBOX_HOME/demo" >/dev/null 2>&1 || fail "demo fixtures were not copied to ~/.arbox/demo"
  [ ! -e "$ARBOX_HOME/profiles" ] || fail "install created a profiles file"
  assert_requests 0
  out=$("$(INSTALLED_COPY)" --version 2>&1) || fail "installed copy does not run"
  case $out in *"$want"*) ;; *) fail "installed copy reports: $out" ;; esac
}
t "install: fresh machine gets ~/.arbox/bin/arbox (700) and ~/.arbox/demo and says so" case_install_fresh

case_install_idempotent() {
  run_arbox install
  # shellcheck disable=SC2012  # ls -i is the portable way to read an inode
  inode1=$(ls -i "$(INSTALLED_COPY)" | awk '{print $1}')
  run_arbox install
  assert_rc 0
  assert_out_has "already up to date"
  # shellcheck disable=SC2012
  inode2=$(ls -i "$(INSTALLED_COPY)" | awk '{print $1}')
  [ "$inode1" = "$inode2" ] || fail "an identical install was rewritten"
  run_arbox install
  assert_out_has "already up to date"
}
t "install: running it again changes nothing and says 'already up to date'" case_install_idempotent

case_install_upgrade() {
  run_arbox install
  set_installed_version 0.0.1
  printf 'stray' >"$ARBOX_HOME/demo/stray.json"
  rm -f "$ARBOX_HOME/demo/v3__locations.json"
  run_arbox install
  assert_rc 0
  assert_out_has "installed arbox"
  assert_out_has "0.0.1"
  cmp -s "$ARBOX" "$(INSTALLED_COPY)" || fail "installed copy was not upgraded"
  diff -r "$DEMO_SRC" "$ARBOX_HOME/demo" >/dev/null 2>&1 || fail "demo folder was not refreshed (stray or missing files remain)"
  [ "$(mode_of "$(INSTALLED_COPY)")" = "-rwx------" ] || fail "upgraded copy mode"
  run_arbox install
  assert_out_has "already up to date"
}
t "install: an older installed copy is upgraded and the demo folder refreshed" case_install_upgrade

case_install_leaves_profiles_alone() {
  write_profiles "# mine
default=$TESTKEY
north=$TESTKEY-n"
  chmod 755 "$ARBOX_HOME"
  before=$(cksum <"$ARBOX_HOME/profiles")
  run_arbox install
  assert_rc 0
  [ "$(cksum <"$ARBOX_HOME/profiles")" = "$before" ] || fail "profiles file was modified"
  [ "$(mode_of "$ARBOX_HOME/profiles")" = "-rw-------" ] || fail "profiles mode changed"
  [ "$(mode_of "$ARBOX_HOME")" = "drwx------" ] || fail ".arbox folder was not tightened to 700"
  assert_file_lacks "$OUT" "$TESTKEY"
  assert_file_lacks "$ERR" "$TESTKEY"
  assert_key_nowhere
}
t "install: never touches the profiles file (and tightens the folder to 700)" case_install_leaves_profiles_alone

case_install_from_installed_copy() {
  run_arbox install
  saved=$ARBOX
  ARBOX=$(INSTALLED_COPY)
  run_arbox install
  ARBOX=$saved
  assert_rc 0
  assert_out_has "already up to date"
  diff -r "$DEMO_SRC" "$ARBOX_HOME/demo" >/dev/null 2>&1 || fail "demo folder damaged by installing from the installed copy"
  [ ! -s "$ERR" ] || fail "unexpected stderr: $(head -c 200 "$ERR")"
}
t "install: running it from the installed copy is a no-op" case_install_from_installed_copy

case_install_tip() {
  run_arbox read --demo /v3/locations
  assert_rc 0
  assert_demo_marker "$OUT"
  assert_err_has "tip: run 'sh "
  assert_err_has "install' once, then always use ~/.arbox/bin/arbox"
  assert_file_lacks "$OUT" "tip:"
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/locations
  assert_rc 0
  assert_err_has "tip: run 'sh "
  run_arbox install
  assert_file_lacks "$ERR" "tip:"
  run_arbox --version
  assert_file_lacks "$ERR" "tip:"
  saved=$ARBOX
  ARBOX=$(INSTALLED_COPY)
  run_arbox read --demo /v3/locations
  assert_rc 0
  assert_file_lacks "$ERR" "tip:"
  run_arbox read /v3/locations
  assert_rc 0
  assert_file_lacks "$ERR" "tip:"
  ln -s "$saved" "$HOME/elsewhere-link"
  ARBOX="$HOME/elsewhere-link"
  run_arbox read --demo /v3/locations
  ARBOX=$saved
  assert_rc 0
  assert_err_has "tip:"
}
t "tip: shown once on stderr when run outside ~/.arbox/bin, never on stdout, never when installed" case_install_tip

case_install_tip_does_not_break_or_leak_into_doctor() {
  write_profiles "default=$TESTKEY
old=bad-key-1"
  run_arbox doctor --online
  assert_rc 4
  assert_out_has "default: connected, 1 location (Studio Flow)"
  assert_out_has "old: Arbox rejected the key"
  assert_file_lacks "$OUT" "tip:"
  nobin=$(make_path_without jq)
  PATH="$nobin" run_arbox read --demo /v3/locations
  assert_rc 0
  assert_err_has "tip:"
}
t "tip: does not alter results, and doctor --online's inner calls stay quiet" case_install_tip_does_not_break_or_leak_into_doctor

case_doctor_reports_installed_copy() {
  write_profiles "default=$TESTKEY"
  want=$(sed -n 's/^ARBOX_EXECUTOR_VERSION="\(.*\)"$/\1/p' "$ARBOX")
  run_arbox doctor
  assert_out_has "installed copy: not installed"
  assert_out_has "install"
  run_arbox install
  run_arbox doctor
  assert_rc 0
  assert_out_has "installed copy: arbox $want"
  assert_out_has "up to date"
  set_installed_version 0.0.1
  run_arbox doctor
  assert_rc 0
  assert_out_has "OLDER"
  assert_out_has "0.0.1"
  assert_out_has "install"
  set_installed_version 99.0.0
  run_arbox doctor
  assert_out_has "NEWER"
  printf '# local edit\n' >>"$(INSTALLED_COPY)"
  set_installed_version "$want"
  run_arbox doctor
  assert_out_has "differs"
  run_arbox install
  saved=$ARBOX
  ARBOX=$(INSTALLED_COPY)
  run_arbox doctor
  ARBOX=$saved
  assert_out_has "this is the installed copy"
}
t "doctor: reports no install, up to date, OLDER, NEWER, edited, and when it is the installed copy" case_doctor_reports_installed_copy

case_doctor_online_decodes_unicode_names() {
  write_profiles "default=heb-key-1"
  run_arbox read /v3/locations
  assert_file_lacks "$OUT" "סטודיו"
  assert_out_has '\u05e1'
  run_arbox doctor --online
  assert_rc 0
  assert_out_has "default: connected, 2 locations (סטודיו דמו, Café "
  assert_file_lacks "$OUT" '\u'
  nobin=$(make_path_without jq)
  PATH="$nobin" run_arbox doctor --online
  assert_rc 0
  assert_out_has "default: connected, 2 locations (סטודיו דמו, Café "
  assert_out_has "🏋"
  assert_file_lacks "$OUT" '\u'
}
t "doctor --online shows Hebrew and emoji location names as text, with and without jq" case_doctor_online_decodes_unicode_names

case_all_zero_rows() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/empty --all --out "$HOME/Arbox/work/none.json"
  assert_rc 0
  assert_requests 1
  assert_out_has "Saved 0 rows"
  assert_file_lacks "$OUT" "install jq"
  [ -s "$HOME/Arbox/work/none.json" ] || fail "zero-row --all left an empty file"
  [ "$(jq -c . "$HOME/Arbox/work/none.json")" = '{"statusCode":200,"data":[],"extra":[]}' ] || fail "file holds: $(cat "$HOME/Arbox/work/none.json")"
  nobin=$(make_path_without jq)
  PATH="$nobin" run_arbox read /v3/empty --all --out "$HOME/Arbox/work/none2.json"
  assert_rc 0
  assert_out_has "Saved 0 rows"
  assert_file_lacks "$OUT" "install jq"
  [ "$(cat "$HOME/Arbox/work/none2.json")" = '{"statusCode":200,"data":[],"extra":[]}' ] || fail "no-jq file holds: $(cat "$HOME/Arbox/work/none2.json")"
  [ ! -e "$HOME/Arbox/work/none2.json.manifest.txt" ] || fail "manifest written for zero rows"
  PATH="$nobin" run_arbox read /v3/empty --all
  assert_rc 2
  run_arbox read /v3/empty --all
  assert_rc 0
  assert_out_has '"data":[]'
  [ -s "$OUT" ] || fail "zero-row --all without --out printed nothing"
}
t "--all with zero rows writes an empty envelope and says 0 rows (with and without jq)" case_all_zero_rows

case_404_is_plain() {
  write_profiles "default=$TESTKEY"
  run_arbox read /v3/notfound
  assert_rc 4
  assert_err_has "HTTP 404"
  assert_err_has "could not find"
  assert_file_lacks "$OUT" "statusCode"
  head -n 1 "$ERR" | grep -q '[{}"]' && fail "first line is not plain English: $(head -n 1 "$ERR")"
  assert_key_nowhere
}
t "HTTP 404 with a JSON error body: the first line stays plain English, exit 4" case_404_is_plain
