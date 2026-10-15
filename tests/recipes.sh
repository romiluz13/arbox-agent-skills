# Recipe checks for tests/run.sh. POSIX sh. Sourced, not executed.
#
# Each case runs a recipe's own jq block, copied out of the recipe file, on the
# demo fixtures with today fixed at 2026-10-14, and compares the result with
# the recipe's spot-check. The demo fixtures carry the value shapes seen on a
# live account, so a recipe rule that only works on guessed shapes fails here.
# <!-- scar: 2026-10-15 — three recipes reported 0 on a live account because they tested for empty action, "true" flags and any task_status; the demo matched the guesses, so nothing caught it -->

RECIPES="$HERE/../skills/arbox-recipes/references"
DEMO="$HERE/../skills/arbox-api/assets/demo"

# recipe_jq <recipe>: the first fenced block under "## How to compute" that runs jq, placeholders filled.
recipe_jq() {
  awk '/^## How to compute/ { on = 1; next }
       on && /^## / { exit }
       on && /^```/ { if (inb) { if (buf ~ /jq /) { printf "%s", buf; exit } buf = ""; inb = 0 } else inb = 1; next }
       inb { buf = buf $0 "\n" }' "$RECIPES/recipe-$1.md" |
    sed -e 's/<first of last month>/2026-09-01/g' -e 's/<same day last month>/2026-09-14/g'
}

# run_recipe <recipe> <work-file>=<fixture or absolute path>...: put the files under ~/Arbox/work/<recipe>/ and run its jq block.
run_recipe() {
  r=$1
  shift
  mkdir -p "$HOME/Arbox/work/$r" "$HOME/bin"
  for pair in "$@"; do
    src=${pair#*=}
    case $src in /*) ;; *) src="$DEMO/$src.json" ;; esac
    cp "$src" "$HOME/Arbox/work/$r/${pair%%=*}"
  done
  cat >"$HOME/bin/date" <<'EOF'
#!/bin/sh
case "$*" in
  "+%Y-%m-%d" | "+%F") echo 2026-10-14 ;;
  "+%Y-%m-01") echo 2026-10-01 ;;
  *) echo "date shim: unexpected $*" >&2; exit 1 ;;
esac
EOF
  chmod +x "$HOME/bin/date"
  recipe_jq "$r" >"$HOME/recipe.sh"
  [ -s "$HOME/recipe.sh" ] || fail "no jq block found in recipe-$r.md"
  OUT="$HOME/recipe.out"
  ERR="$HOME/recipe.err"
  RC=0
  # shellcheck disable=SC2034  # RC is read by assert_rc in lib.sh
  PATH="$HOME/bin:$PATH" sh "$HOME/recipe.sh" >"$OUT" 2>"$ERR" || RC=$?
  assert_rc 0
}

# expect <jq filter> <expected compact JSON>: checked against the recipe output.
expect() {
  got=$(jq -c "$1" "$OUT" 2>&1)
  [ "$got" = "$2" ] || fail "$1: expected $2, got $got"
}

if ! command -v jq >/dev/null 2>&1; then
  printf 'skip  recipe checks (jq is not installed)\n'
else

case_recipe_sales_snapshot() {
  run_recipe sales-snapshot all.json=v3__reports__salesReport
  expect '.this | [.sales, .paid, .owed]' '[3,3380,180]'
  expect '.before | [.sales, .paid]' '[3,5520]'
  expect '[.special_rows, .free_items]' '[0,0]'
  expect '[.by_sub_action[] | [.sub_action, .rows]]' '[["Debt",1],["Purchase Occasion",2]]'
  expect '[.by_item[] | [.item, .sales, .paid]]' '[["20-session pack",1,3200],["Intro offer 3 classes",2,180]]'
}
t "recipe sales-snapshot: live-shaped action values count as sales (spot-check)" case_recipe_sales_snapshot

case_recipe_whos_drifting() {
  run_recipe whos-drifting regulars.json=v3__reports__regularsReport absence.json=v3__reports__absenceReport
  expect '[.[] | [.name, .days, .last_seen, .can_sms]]' '[["Shira Katz",30,"2026-09-14",true]]'
}
t "recipe whos-drifting: +972 phones join, future_registration \"no\" means nothing booked (spot-check)" case_recipe_whos_drifting

case_recipe_whos_drifting_shared_phone() {
  jq '.data += [.data[] | select(.full_name == "Shira Katz") | .full_name = "Someone Else" | .phone = "0500000008" | .last_seen = "2026-10-13"]' \
    "$DEMO/v3__reports__absenceReport.json" >"$HOME/absence-shared.json"
  run_recipe whos-drifting regulars.json=v3__reports__regularsReport absence.json="$HOME/absence-shared.json"
  expect '[.[] | [.name, .note]]' '[["Shira Katz","not matched, check"]]'
}
t "recipe whos-drifting: two absence rows with one phone key show \"not matched, check\", never a guess" case_recipe_whos_drifting_shared_phone

case_recipe_whos_drifting_regulars_share_phone() {
  jq '.data += [.data[] | select(.full_name == "Shira Katz") | .user_id = 999999 | .full_name = "Shira Katz Jr"]' \
    "$DEMO/v3__reports__regularsReport.json" >"$HOME/regulars-shared.json"
  run_recipe whos-drifting regulars.json="$HOME/regulars-shared.json" absence.json=v3__reports__absenceReport
  expect '[.[] | [.name, .note]] | sort' '[["Shira Katz","not matched, check"],["Shira Katz Jr","not matched, check"]]'
}
t "recipe whos-drifting: two regulars with one phone key are both \"not matched, check\"" case_recipe_whos_drifting_regulars_share_phone

case_recipe_leads_and_trials() {
  run_recipe leads-and-trials open.json=v3__reports__leadsInProcessReport trials.json=v3__reports__trialClassesReport tasks.json=v3__tasks
  expect 'length' '7'
  expect '[.[] | select(.old_task) | .name]' '["Alma Tal"]'
}
t "recipe leads-and-trials: taskNone and taskPast are not a current task (spot-check)" case_recipe_leads_and_trials

case_recipe_payments_to_chase() {
  run_recipe payments-to-chase debt.json=v3__reports__debtReport failed.json=v3__finance__reports__failedTransactions tasks.json=v3__tasks
  expect '[map(.owed) | add, length]' '[1300,4]'
  expect '[.[] | select(.has_open_task | not) | .name]' '["Adam Friedman"]'
}
t "recipe payments-to-chase: numeric debt sums (spot-check)" case_recipe_payments_to_chase

case_recipe_class_fill() {
  run_recipe class-fill schedule.json=v3__schedule
  expect '[.classes, .cancelled_skipped, .avg_fill, .waiting]' '[71,1,51,15]'
}
t "recipe class-fill: cancelled class dropped, average fill (spot-check)" case_recipe_class_fill

fi
