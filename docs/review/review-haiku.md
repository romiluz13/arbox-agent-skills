# Review R10H: owner truth and docs fidelity (Haiku, 2026-10-14)

Scope: `skills/arbox-api/SKILL.md`, `references/setup.md`, `references/safety.md`; `skills/arbox-recipes/SKILL.md` and all recipe references; `README.md`, `docs/decisions.md`, `CHANGELOG.md`. Also read, because the scope points at them: `skills/arbox-api/scripts/arbox`, `skills/arbox-api/references/openapi.json`, `.claude-plugin/plugin.json`, `.github/workflows/*.yml`, `tests/`, `docs/research/`.

Method: each claim about the executor, the spec or Arbox was checked against the code, the spec snapshot, the demo fixtures, the research notes, or (for Claude Code permissions and plugin install) the live docs at code.claude.com. Commands run are listed in the Evidence line of each finding.

## Findings

### 1. [blocker] First-use install command does not exist in the executor
- **Where:** `skills/arbox-api/SKILL.md:23` (`sh <skill-dir>/scripts/arbox install`) and `:27` ("The helper installs itself (and its sample data)"); `skills/arbox-recipes/SKILL.md:38` (same command); `skills/arbox-api/references/setup.md:7` (Step 0 points to SKILL §1).
- **Trigger:** an owner or agent on a fresh Mac follows Step 0, or the recipes' "if that command is not found" branch.
- **Consequence:** the command prints usage and exits 2. Nothing is copied to `~/.arbox/bin/arbox` and no demo is installed. Every later `~/.arbox/bin/arbox ...` fails with "command not found", so setup stops at Step 0 and the permission rules in §3 name a file that does not exist. The earlier `cmp -s … cp` lines were removed in this round without the executor gaining the `install` command the replacement needs.
- **Evidence:** `grep -n install skills/arbox-api/scripts/arbox` matches only comments and usage text. The dispatch `case` (scripts/arbox ~line 920) has no `install)` branch. Run in a throwaway HOME: `sh scripts/arbox install` → usage on stderr, exit 2, and `$HOME/.arbox` is not created. `--version` works (0.9.0).
- **Fix (pick one):**
  - A (preferred, matches `lead-response.md` item 3): add `install) cmd_install "$@" ;;` to the dispatch and a `cmd_install` that does `mkdir -p "$ARBOX_DIR/bin" "$ARBOX_DIR/demo"`, copies `"$0"` to `$ARBOX_DIR/bin/arbox` when `cmp -s` differs, runs `chmod 700`, and copies the demo fixtures from the same place `read --demo` finds them (scripts/arbox ~line 339). Add `case_install` to `tests/cases.sh` (fresh HOME; second run is a no-op; `--version` works from the installed copy).
  - B (no code change): put back the `cmp -s <skill-dir>/scripts/arbox ~/.arbox/bin/arbox || cp …` and `cp -R <skill-dir>/assets/demo/. ~/.arbox/demo/` lines in SKILL §1, and change `:27` and the recipes' line 38 to say so. Then `install` is removed from every file.

### 2. [high] "You can undo it in a click" is false for tasks; the write log is the only record
- **Where:** `skills/arbox-api/references/safety.md:3` ("v1 allows only small internal updates that a person can undo in a click"); `:32` (example: "You can delete them in Arbox"); `skills/arbox-api/SKILL.md:79` ("that it can be undone in Arbox").
- **Trigger:** the owner approves creating follow-up tasks (R1) on the strength of "undo in a click".
- **Consequence:** the owner is told a reversibility the product does not offer through this helper. The leads recipe says the opposite: `recipe-leads-and-trials.md:68` "no task delete exists … tasks can only be marked done, not deleted". The spec has no `DELETE /v3/tasks` (checked: only `POST /v3/tasks`, `POST /v3/tasks/markAsCompleted/{task_id}`). Lead notes and member notes have no delete either.
- **Evidence:** spec paths listed with `DELETE` on `/v3/tasks` and `/v3/tasks/{task_id}`: none. `grep -n "undo\|delete them"` on the three files gives the lines above.
- **Fix:** in `safety.md:3`, replace with "v1 allows only small internal updates. The helper has no way to undo them; a task can be marked done and a note stays. Undo in the Arbox screen is a LIVE CHECK." In `safety.md:32`, replace "You can delete them in Arbox" with "The tasks can be marked done in Arbox; this helper cannot delete them." In `SKILL.md:79`, replace "that it can be undone in Arbox" with "that the helper cannot undo it (say how the owner can mark it done or remove it in Arbox, if they know)".

### 3. [high] The owner's fallback key path names a placeholder the executor never writes
- **Where:** `skills/arbox-api/references/setup.md:45` ("You'll see a line `default=PASTE-YOUR-KEY-HERE`"); the real placeholder is set at `skills/arbox-api/scripts/arbox:15`.
- **Trigger:** the owner chose the TextEdit fallback (`setup --open`) because Terminal felt like too much.
- **Consequence:** the owner looks for `PASTE-YOUR-KEY-HERE`, does not find it, and either pastes into the wrong place or stops. This is the step the owner is most likely to get stuck on.
- **Evidence:** `PLACEHOLDER="PASTE_YOUR_ARBOX_KEY_HERE"` at scripts/arbox:15. The `--prompt` text in the same file (`cmd_setup`) also prints `$PLACEHOLDER`, so the file and the instructions must agree.
- **Fix:** in `setup.md:45`, change the quoted line to `default=PASTE_YOUR_ARBOX_KEY_HERE` (underscores). Also say "the placeholder after `default=`" so the owner does not depend on the exact text.

### 4. [medium] Permission section overstates the gate; the write `ask` rule is spelling-bound
- **Where:** `skills/arbox-api/SKILL.md:64` ("the `ask` rule keeps every change prompting … the `deny` rules stop the agent's file tools, and shell commands like `cat`, from opening the key file"); `docs/decisions.md:11` ("the gate is enforced outside the model").
- **Trigger:** an agent types `sh ~/.arbox/bin/arbox write …` or runs the executor by another path; SKILL §1 already warns about this, but §3 and D5 describe the rule as the gate.
- **Consequence:** the Claude Code docs (code.claude.com/docs/en/permissions) say a Bash rule "matches the command text Claude writes … It doesn't match the same program invoked in a different form, so a deny or ask rule covers the invocation Claude usually produces and isn't a security boundary around the program." So the write prompt can be skipped by spelling. The real write gate is the executor: the 7-path allowlist (`write_allowed`) plus the `--yes-i-confirmed` requirement. The `cat` claim is correct for Bash `cat` (docs: Read/Edit deny rules cover "file commands Claude Code recognizes in Bash, such as `cat`"), but the same docs say they do not cover "a Python or Node script that opens files itself".
- **Evidence:** docs quoted above (permissions page, sections "Bash rule limits" and "Read and Edit deny rules"). `write_allowed` at scripts/arbox:272.
- **Fix:** in `SKILL.md:64`, replace the "Why each part" sentences about `ask` and `deny` with: "The `ask` rule prompts when a write is typed exactly as `~/.arbox/bin/arbox write …`. The `deny` rule stops the agent's file tools and Bash commands such as `cat` from reading the key file; it does not stop a script that opens the file itself. These rules are a prompt, not a security boundary. The gate that holds is the helper: it refuses every write path outside its seven, and every write needs the owner's yes." In `docs/decisions.md:11`, replace "so the gate is enforced outside the model" with "so reads run without prompts and writes prompt; the helper's allowlist is the enforced gate."

### 5. [medium] "Settings → Club Information" is stated as fact; the research says it is unverified
- **Where:** `skills/arbox-api/SKILL.md:38`; `skills/arbox-api/references/setup.md:13` (English), `:17` (Hebrew label); `README.md:83`.
- **Trigger:** an owner looks for the key at that menu path.
- **Consequence:** if the label differs, the owner stops and the agent has nothing to fall back on. The research is explicit: `docs/research/arbox-product-2.md:407` "Show the API key menu path as 'Settings > Club Information (per Academy); older label Business Information' until verified", and line 265 "Location: Settings > Club Information (Academy)… Plan gate, issuer, and visibility still UNKNOWN." setup.md:19 flags only the Hebrew label as unverified; the English path is presented as fact everywhere.
- **Evidence:** the research lines above; the Academy page is the only source.
- **Fix:** in `setup.md:13`, add "(Arbox's Zapier guide names this menu; if you can't find it, look for 'Business Information' or ask Arbox support)". Use the same sentence in `SKILL.md:38` and `README.md:83`. Change `setup.md:19` to say the English and Hebrew labels both come from Arbox's guide and are not confirmed on a live account.

### 6. [medium] Plugin manifest lists recipes that do not exist
- **Where:** `.claude-plugin/plugin.json:4` ("run ready-made recipes (churn risk, weekly digest, class fill, revenue, lead follow-up)").
- **Trigger:** the plugin is installed from the marketplace and its description is shown to the owner.
- **Consequence:** the description promises "churn risk", "weekly digest", and "revenue" recipes. The shipped recipes are renewal watch, who's drifting, payments to chase, leads and trials, sales snapshot, class fill, no-shows, first 30 days, waivers and forms, and the Monday page (`README.md:55–66`). The owner gets a mismatched promise on the install screen.
- **Evidence:** `README.md` recipe table; `skills/arbox-recipes/SKILL.md:16–29` index.
- **Fix:** replace the parenthesis with "(renewals, who's drifting, payments to chase, leads and trials, sales, class fill, no-shows, first 30 days, waivers, the Monday page)".

### 7. [low] README overstates test coverage of recipes
- **Where:** `README.md:87` ("Every skill, safety rule and recipe is validated against the official API spec and a fake Arbox server, with automated tests and evals").
- **Trigger:** a reader takes "every recipe … a fake Arbox server" at face value.
- **Consequence:** `tests/cases.sh` covers the helper only (61 cases, all passing when I ran `sh tests/run.sh`). Recipes are checked by `tools/validate.py` for paths, links and operation names; they are not run against the fake server. The README's own "Checks" line (line 95) says the same, so the two statements disagree.
- **Evidence:** `tests/cases.sh` case names are all helper behaviour; `sh tests/run.sh` → `61 passed, 0 failed`.
- **Fix:** replace line 87's sentence with "The helper is tested against a fake Arbox server (61 cases). Recipes are checked against the official spec for paths, links and operation names; live verification is pending."

### 8. [low] Decisions say R2 is messages only; the safety file lists five R2 kinds
- **Where:** `docs/decisions.md:13` (D7: "R2 (messages) is drafts only"); `skills/arbox-api/SKILL.md:76` and `references/safety.md:40` (R2 = messages, bookings, cancellations, trial bookings, schedule changes).
- **Consequence:** a reader of D7 would think bookings are allowed to the agent or are a different tier.
- **Fix:** in D7, change "R2 (messages) is drafts only" to "R2 (messages, bookings, cancellations, trial bookings, schedule changes) is drafts or lists only".

### 9. [low] Decisions say the default output includes a CSV; three recipes ship none by default
- **Where:** `docs/decisions.md:19` (D13: "Default output: a local HTML report plus a CSV"); `skills/arbox-recipes/references/recipe-sales-snapshot.md:57` ("CSV: none by default"); `recipe-class-fill.md:60` ("CSV: none"); `monday-page.md:44` ("CSV: none").
- **Fix:** in D13, change to "Default output: a local HTML report; a CSV when the output is a list of people to contact."

### 10. [low] Renewal "Both members" is three members
- **Where:** `skills/arbox-recipes/references/recipe-renewal-watch.md:96`.
- **Evidence:** `v3__reports__expiringSessionsReport.json` rows with `sessions_left > 0`: נועה כהן (1, future 2), Tamar Ben-David (3, future 1), איתי גולן (1, cancelled). The three of them give 0 unbooked credits; the sentence says "Both members … either have a future booking (…, …) or are cancelled (…)".
- **Fix:** replace "Both members with sessions left" with "The three members with sessions left".

### 11. [low] Payments recipe states an Arbox reminder behaviour with no source
- **Where:** `skills/arbox-recipes/references/recipe-payments-to-chase.md:8` ("Arbox sends its own overdue reminders if the owner turned them on").
- **Evidence:** the research mentions "payment-due reminders" only for the education vertical (`docs/research/arbox-product-2.md:50`); nothing about overdue reminders as a general setting.
- **Fix:** "Arbox may send its own payment reminders; check the owner's settings. The research does not confirm this for every plan."

### 12. [low] Renewal menu path "Reports > Retention" is not verified
- **Where:** `skills/arbox-recipes/references/recipe-renewal-watch.md:14` and `:99`.
- **Evidence:** research `docs/research/arbox-product-2.md:202` names "Retention" as a report group with "memberships expiring without renewal". The menu path "Reports > Retention" is not in any source.
- **Fix:** "Arbox's Retention report (the path in your menu may differ; LIVE CHECK)".

### 13. [low] Quoted owner-facing error does not match the executor's text
- **Where:** `skills/arbox-api/references/setup.md:56` (`"keys with quotes or spaces are refused"`).
- **Evidence:** the executor's message is `The key for profile '…' contains unexpected characters (spaces or quotes?). Re-copy it from Arbox into $PROFILES` (scripts/arbox ~line 108). The text in setup.md is not printed anywhere.
- **Fix:** change setup.md:56 to: the message "contains unexpected characters (spaces or quotes?)" means extra text was pasted; repeat Step 2.

### 14. [nit] Hebrew wording
- `skills/arbox-recipes/references/drafts.md:40`: "רוצים שנשריין לכם מקום בשיעור הבא?" → "רוצים שנשמור לכם מקום בשיעור הבא?" ("נשריין" reads as jargon).
- `skills/arbox-api/references/setup.md:29` (email): "את חשבון הארבוקס שלי" → "את חשבון Arbox שלי" (brand name in Latin letters, as in the rest of the Hebrew text).

### 15. [note, outside scope] Stale planning doc
- `docs/plan/live-checks.md:13` says the write allowlist "Not built" and an R3 denylist exists. Both are now the other way round (`write_allowed` at scripts/arbox:272). Not in this review's scope; fix when the plan is next touched.

## Checked and correct

- The 7 allowed writes match the executor exactly: `POST /v3/leads`, `/v3/leads/updateStatus`, `/v3/leads/markAsLost`, `/v3/leads/createNote`, `/v3/tasks`, `/v3/tasks/markAsCompleted/{id}`, `/v3/users/createNote`. Checked against `write_allowed` (scripts/arbox:272–284) and the spec operationIds in `safety.md` (Create New Lead, Update Lead Status, Mark Lead as Lost, Add Note to Lead, Create New Task, Mark Task as Completed, Create user note).
- R2 and R3 paths cited in `safety.md` exist in the spec: `/v3/message`, `/v3/schedule/bookSession`, `/v3/schedule/cancelUserBooking`, `/v3/schedule/booking/trial`, `PATCH /v3/schedule`, `GET /v3/schedule/entryFromWaitingList` with `confirm`. The executor refuses `confirm=` on reads (scripts/arbox:455).
- Exit codes 3 (no key), 4 (network), 5 (refused) match the code; the log path `~/Arbox/logs/activity.log` matches (scripts/arbox:51); `--out` is confined to `~/Arbox` (confine_out, :240); `--all` is 500 rows per page, stopping at 20 pages (:523, :540).
- Spec: 65 operations; 47 report names used by the recipes all appear in `reports.md`; recipe query parameters `registration_count`, `waiting_list_count`, `from_date`, `to_date` exist on their operations; the `POST /v3/tasks` body (`location_id`, `task_type_id`, `reminder` required) matches the leads recipe.
- Permissions: `deny` → `ask` → `allow` order and `~` paths in `Read(...)` rules match the Claude Code docs.
- Plugin install lines in `README.md:25–32` match the Claude Code docs: `/plugin install <plugin> --marketplace <source>` needs v2.1.275 or later, and the two-step form covers older versions.
- Validator: `python3 tools/validate.py` → `operations: 65/65 linked; reports: 47 checked` → `OK`. `sh tests/run.sh` → `61 passed, 0 failed`. CI (`ci.yml`) runs both; the drift job runs weekly (`drift.yml`, cron `0 6 * * 1`).
- Hebrew in `drafts.md` templates, `setup.md` Hebrew steps and the README Hebrew paragraph reads naturally, apart from item 14.
- The 3 skills agree on tiers, key location (`~/.arbox/profiles`), the 7 writes and the booking policy (no agent bookings in v1).

## Vouch: yes-if fixes 1, 2, 3, 4 and 5 are made

The first-use install path is broken, one safety promise (undo in a click) is false for tasks, the owner's fallback key path names a placeholder that is not written anywhere, the permission section overstates the write gate, and a menu path is presented as verified when the research says it is not. The rest is wording and consistency.

---

## Round 2 (R10H.2, 2026-10-14)

Scope: (a) check the lead's fixes for findings 2–15 against the tree (`git diff` against HEAD; `scripts/` and `tests/` are untracked, so they were read directly); (b) sweep `skills/arbox-guide/**`. No files were edited.

### Part A: findings 2–15

| # | Status | Note |
|---|---|---|
| 2 | OK | safety.md:3 and :32, SKILL.md:75 and :79 no longer promise an undo. Tier-key lines in finance, leads, other, users, schedule now say "no undo through the API". Still open in code: the comment at `scripts/arbox:268` says "reversible" (B02.3 scope). |
| 3 | OK | setup.md:45 now says `default=PASTE_YOUR_ARBOX_KEY_HERE`, matching `scripts/arbox:15`. |
| 4 | OK | SKILL.md:64 and decisions.md:11 describe the rules as prompts and name the helper's allowlist as the gate. The `cat` claim is now limited to Bash `cat`. |
| 5 | **Still wrong** | setup.md:19 now says "Both the English and the Hebrew menu labels come from Arbox's guide". The guide is English. The Hebrew label is our translation, so the new sentence is itself inaccurate. Also README.md:83 says "on some accounts it may be labeled 'Business Information'", which has no source (the research only records an older label from a search summary). SKILL.md:38 and setup.md:13 are fine. |
| 6 | OK | plugin.json:4 lists the ten shipped recipes, matching the README table. |
| 7 | OK | README.md:87 now says what is tested: the helper against the fake server, recipes against spec paths and links, skills by evals. |
| 8 | OK | decisions.md:13 (D7) lists all five R2 kinds. |
| 9 | OK | decisions.md:19 (D13) makes the CSV conditional. |
| 10 | OK | renewal-watch.md:96 says "The three members". |
| 11 | OK | payments-to-chase.md:8 is hedged ("not confirmed for every plan"). |
| 12 | OK | renewal-watch.md:14 and :99 mark the menu path as LIVE CHECK. |
| 13 | OK | setup.md:56 quotes "contains unexpected characters (spaces or quotes?)", which matches the executor's message. |
| 14 | OK | drafts.md:40 now reads "נשמור לכם מקום"; setup.md:29 reads "חשבון Arbox שלי". Both are natural. |
| 15 | OK | docs/plan/live-checks.md:13 now matches the code: `write_allowed` exists and `tests/run.sh` covers refusals. |

**Still open, not part of 2–15:** the first-use install line is still in `skills/arbox-api/SKILL.md:23` and `skills/arbox-recipes/SKILL.md:38`. The command still does not exist, so it stays broken until B02.3 lands.

### Part B: arbox-guide sweep

Checked: the 31 report names the guide uses all appear in `reports.md`; every `GET`/`POST` path the guide cites exists in the spec; the guide names no helper command or flag; `/v3/message` (push and WhatsApp only) and "SMS and email not documented" match the spec; plan prices are annual figures, as the table says; spaces management at Professional and the English help center being empty both have sources.

**G1 [high] Form-link creation is listed as something Claude can do with a yes.**
- Where: `skills/arbox-guide/references/arbox-product.md:53` ("Claude can do only with the owner's yes … create a form link"); `skills/arbox-guide/references/ideas-catalog.md:75` (idea 9: "optional R1 creating a form link").
- Trigger: the owner asks for a waiver or health form link.
- Consequence: the helper refuses it (exit 5), since `write_allowed` (`scripts/arbox:272`) allows seven writes and `POST /v3/digitalForms/createLink` is not one of them. SKILL.md:75 says the seven are the only writes. The owner was told a capability that does not exist in v1.
- Evidence: spec has `POST /v3/digitalForms/createLink`; `write_allowed` lists no such path.
- Fix: in product:53, remove "create a form link" and add "form links" to the app-only list at product:59. In catalog:75, replace "optional R1 creating a form link (sends nothing by itself)" with "form links are made in the Arbox app; the helper cannot create them in v1".

**G2 [medium] Glossary names the wrong schedule filter.**
- Where: `skills/arbox-guide/references/glossary.md:13` ("`coach_id` is a query filter").
- Trigger: an agent maps "coach" to a schedule query.
- Consequence: the agent sends a parameter the schedule operation does not take. Its only query filter is `staff_id`. `coach_id` appears only in the reports operation.
- Evidence: `GET /v3/schedule` parameters from the spec: `staff_id`, `box_category_id`, `location_id`, and others. No `coach_id`.
- Fix: change the glossary row to "`staff_id` is the schedule query filter; the schedule row gives `staff_member` as a name".

**G3 [medium] Birthday and renewal auto actions are stated as fact.**
- Where: `skills/arbox-guide/SKILL.md:107` ("Auto actions (Standard+) send automatic reminders and birthday messages"); `ideas-catalog.md:118` ("Arbox auto actions (Standard+) can already send birthday messages"); `ideas-catalog.md:36` ("Auto actions (Standard+) can send renewal reminders").
- Trigger: the owner is told to use Arbox's native birthday or renewal message instead of Claude's.
- Consequence: the owner may set up something Arbox's page does not confirm. `arbox-product.md:65` already hedges these ("birthdays, onboarding and renewals … not verified on the page"). The guide's other files contradict the hedge.
- Evidence: `arbox-product.md:65`, research `docs/research/arbox-product.md` (auto actions appear in the Standard feature list; birthday and renewal triggers are not on the fetched page).
- Fix: SKILL.md:107 → "Auto actions (Standard+) send reminders and follow-ups; birthday and renewal triggers are not confirmed on Arbox's page, so check in the app." Make the same change at catalog:36 and catalog:118.

**G4 [medium] The key menu label is presented as a fact, and the "older label" is unsourced.**
- Where: `skills/arbox-guide/references/arbox-product.md:83` ("API key / Zapier key: Settings > Club Information (an older label is Business Information)").
- Trigger: the owner or agent looks for the key using the guide's menu path.
- Consequence: same issue as R10H #5. The research says the path is unverified, and only a search summary mentions "Business Information". Calling it an "older label" states an Arbox history that no source records.
- Evidence: `docs/research/arbox-product-2.md:407`.
- Fix: "API key (Zapier key): Settings > Club Information, per Arbox's Zapier guide. A search summary also gave 'Business Information'. Not confirmed on a live account."

**G5 [medium] The Hebrew examples use masculine second person.**
- Where: `skills/arbox-guide/references/interview.md:127–137` (worked example: "הכי כואב לך", "שאתה שם לב", "מה אתה מוכר", "שלך"); also the Q lines at :132, :134, :136.
- Trigger: the owner's gender is not known, and the guide tells the agent to copy this shape ("Mirror the owner's language").
- Consequence: the agent may address the owner in masculine forms before it knows the owner's gender, which reads as a wrong assumption.
- Evidence: the masculine forms at those lines; the customer drafts (drafts.md) use plural "you" on purpose for the same reason.
- Fix: use the plural (אתם / שלכם / לכם) in the examples, e.g. "מה אתם מוכרים?", "מה הכי כואב לכם עכשיו?". Add one line to interview.md: "Use plural 'you' in Hebrew until the owner uses a form."

**G6 [medium-low] The payments idea offers a task write the recipe does not do.**
- Where: `skills/arbox-guide/references/ideas-catalog.md:41` (idea 3, payments: "optional `POST /v3/tasks` (R1 …)").
- Trigger: the owner accepts the idea and asks for tasks.
- Consequence: `recipe-payments-to-chase.md` has no write step, and `skills/arbox-recipes/SKILL.md:60` says the one optional write is in leads-and-trials. The guide promises a feature the recipe does not have.
- Evidence: payments-to-chase has no write section; recipes SKILL.md:60.
- Fix: remove the `POST /v3/tasks` mention from catalog:41. Keep it on idea 4 only.

**G7 [low] The Monday page is described with the wrong sections.**
- Where: `skills/arbox-guide/references/ideas-catalog.md:81` ("composes renewal-watch, payments-to-chase, sales-snapshot, class-fill and whos-drifting").
- Consequence: the owner expects a drifting list on the Monday page. `monday-page.md` has five sections: renewal, payments, sales, class fill, and no-shows. Drifting is not one of them.
- Fix: replace "whos-drifting" with "no-shows" at catalog:81.

**G8 [low] Failed-payment messaging is stated as fact, with the plan unknown.**
- Where: `skills/arbox-guide/references/ideas-catalog.md:42` ("Arbox has Failed Transactions with a built-in debt and card-update message to the member").
- Consequence: `arbox-product.md:69` lists this feature's plan as UNKNOWN. The catalog drops that caveat.
- Fix: append "(plan not confirmed)" to catalog:42.

**G9 [low] Zapier lead sources and Growth conversion are stated more firmly than the research.**
- Where: `skills/arbox-guide/references/ideas-catalog.md:48` ("Zapier brings leads from Facebook, Instagram and Google ads into Arbox; the Growth reports show conversion").
- Consequence: the research lists those Zapier apps and marks lead intake "unknown plan" (`arbox-product-2.md:383`). The Growth conversion claim is sourced (`arbox-product-2.md:201`). Only the Zapier half is overstated.
- Fix: "Arbox's Zapier integration lists Facebook, Instagram and Google Ads lead sources (plan not confirmed). The Growth reports show the share of leads converted."

**G10 [low] A key label the owner will not see.**
- Where: `skills/arbox-guide/references/glossary.md:73` (say "a connection code from your Arbox settings" instead of "API key").
- Consequence: setup.md:13 tells the owner to look for "API Key" in Arbox. An owner told to find a "connection code" may not recognise the label.
- Fix: "say 'the API key' and show the label as Arbox displays it (see arbox-api setup.md)".

**Not checked:** the claim that report field shapes are typed for "40 of 47 reports" (ideas-catalog.md:21). Mapping report names to schemas was not done in this round.

### Round 2 vouch

**Vouch: yes-if setup.md:19 is corrected, G1 through G5 are fixed, and B02.3 (`arbox install`) lands before the build ships.** Findings 2–4 and 6–15 are fixed. Finding 5 is partly fixed, and its new Hebrew sentence is wrong. The guide's main risk is G1: it promises a form-link write that the helper refuses. The rest is hedging and wording.

## Round 3 (V1, 2026-10-15)

Scope: (a) re-run every recipe's "Data to fetch" command live on the test gym; (b) owner-facing and fact-check read of `README.md`, `docs/launch/README.md` and `docs/launch/directory-submission.md`. No files outside `docs/plan/live-check-results.md` and this review were edited; `skills/`, `scripts/`, `tests/`, `README.md` and `docs/launch/` were not touched.

### Part A: live re-run

- Every recipe fetch returned 200 with the window as written. Table in `docs/plan/live-check-results.md` ("V1 re-run").
- Rows flipped to PASS (fixed, lead L1 14-26): R-whos-drifting, R-payments-to-chase, R-leads-and-trials, R-sales-snapshot, R-class-fill, R-no-shows, R-first-30-days, R-waivers-and-forms, G3-sales-cap, G3-tasks-cap, G5-absenceReport, G5-trialClassesReport, G5-salesReport, G7-schedule-42d. H-all-zero flipped to PASS "fixed in repo": `tests/cases.sh` `case_all_zero_rows` passes, suite 72 passed, 0 failed.
- **Caveat, not a pass:** the installed copy at `~/.arbox/bin/arbox` predates the zero-row fix. Until `arbox install` runs, `--all` on an empty result still writes a 0-byte file, and the whos-drifting jq fails on it ("Cannot iterate over null"). The plain read is 200 and works.
- whos-drifting end to end: the join matched 0 of 13 absence rows (phone empty on all 13), and 0 regulars exist. The recipe's stop rule applies: counts only, no report. Correct behaviour.
- class-fill end to end: the recipe's jq runs on the live file and keeps all 21 classes, because `cancelled_status` is absent. Report at `~/Arbox/reports/class-fill-2026-10-15.html` with the footer note.
- Counts after the flips: PASS 50, FAIL 0, BLOCKED 31, NOT RUN 3 (84 rows).

### Part B: owner and fact-check review

Checked and correct: `tools/validate.py` prints OK; `claude plugin validate . --strict` passes; the seven writes in the README and submission form match the allowlist in `skills/arbox-api/scripts/arbox:285-288`; eval numbers (96% and 67%, 5 prompts, 18 checks) match `evals/results.md`; README is 1,616 words; LICENSE present; no hooks, no `.mcp.json`; no tracked symlinks, no tracked `.DS_Store`, no tracked file over 256 KiB; drift check runs weekly (`.github/workflows/drift.yml`, Monday 06:00 UTC); Claude Code 2.1.300 meets the README's 2.1.275 floor; `skills@1.7.2` exists on npm. The refusal tests (`case_r3_paths_refused`) were run in the earlier pass and not re-run here.

**F1 [high] The launch posts say the tool changes nothing. It can make seven small changes.**
- Where: `docs/launch/README.md:59` (WhatsApp, English: "It never sends or changes anything"), `:62` (WhatsApp, Hebrew: "הוא לא שולח ולא משנה כלום"), `:66` (short post: "read-only"); `:7` (ground rule lists "reads, reports, drafts" only).
- Trigger: any owner who reads the post and then sees a lead, note or task created after a yes.
- Consequence: the post contradicts `README.md:73` and `directory-submission.md:41`, and it erodes trust the first time a change appears.
- Evidence: `write_allowed` (`skills/arbox-api/scripts/arbox:285-288`) allows POST `/v3/leads`, `/v3/leads/updatestatus`, `/v3/leads/markaslost`, `/v3/leads/createnote`, `/v3/tasks`, `/v3/users/createnote`, `/v3/tasks/markascompleted/*`. Seven paths, as the README says.
- Fix: "It never sends messages, moves money or changes memberships. It can add a lead note, a task or a lead status, only after you say yes." Use the same meaning in Hebrew, and drop "read-only".

**F2 [high] The install line in the posts uses a form the CLI does not show.**
- Where: `README.md:81` (`/plugin install arbox --marketplace romiluz13/arbox-agent-skills`), `docs/launch/README.md:30` and `:50`.
- Trigger: an owner or reader copies the line into Claude Code.
- Consequence: it may fail, and the owner gets no working install.
- Evidence: `claude plugin install --help` documents `plugin@marketplace`. `README.md:102-103` (agent section) uses `claude plugin install arbox@arbox-agent-skills`. The marketplace name is `arbox-agent-skills`, and the plugin name is `arbox` (`.claude-plugin/marketplace.json`).
- Fix: use `/plugin marketplace add romiluz13/arbox-agent-skills` and then `/plugin install arbox@arbox-agent-skills`. I could not run the slash command here, so check it once in Claude Code before posting.

**F3 [medium] "47 reports, each with a deep link" is not true.**
- Where: `README.md:74`.
- Evidence: `skills/arbox-api/references/reports.md` has one docs link, `Get%20Reports`, which all 47 entries share. The 65 operations do each have their own link (`validate.py`: 65/65).
- Fix: "All 65 operations link to their official docs. The 47 reports are documented under the Get Reports operation."

**F4 [medium] "A real report on the built-in sample studio" calls sample data real.**
- Where: `README.md:57`.
- Fix: "A sample report on the built-in sample studio, with made-up data."

**F5 [medium] The tag the directory form asks for does not exist.**
- Where: `docs/launch/directory-submission.md:29` ("Branch or tag: `v0.9.0`").
- Evidence: `git tag -l v0.9.0` prints nothing. The fetched portal doc says an empty field follows the default branch.
- Fix: create and push the tag before submitting, or enter `main` now.

**F6 [medium] The data-handling answers miss two questions the portal asks.**
- Where: `docs/launch/directory-submission.md:38-42`.
- Evidence: the portal's Data handling step (`claude.com/docs/plugins/submit`) also asks how long data is kept and whether the plugin is for people under 18. The form covers neither.
- Fix: add both answers, marked for the submitter to confirm. For example: "Results stay on the owner's computer until the owner deletes them. Not intended for people under 18."

**F7 [medium] Two claims are unsourced.**
- Where: `directory-submission.md:3` ("the official marketplace (`claude-plugins-official`) doesn't take submissions"; "Directory installs reach Claude Code as `arbox@synced`"). Neither appears on the page fetched. `:11`: "Held for a reviewer" is a prediction, not a finding.
- Fix: cite the source for each, or remove it. Write "may be held for a reviewer".

**F8 [medium] The privacy promise is narrower than the skills' rule.**
- Where: `README.md:137` ("left out unless you ask about a specific person").
- Evidence: `skills/arbox-api/SKILL.md:96` ("unless the owner explicitly asks for that field").
- Fix: "left out unless you ask for that field".

**F9 [low] The directory file count is out of date.**
- Where: `directory-submission.md:15` ("125 files"). Right now 97 tracked plus 30 untracked, not ignored: 127 shippable files.
- Fix: count at submission time, or drop the number.

**F10 [low] The activity log "has no data" is slightly overstated.**
- Where: `README.md:132` ("a log of every call (no key, no data)").
- Evidence: the log records the URL path. In the current log, 1 of 212 lines has a numeric id in its path (`/v3/users/999999999`, a 404 test read).
- Fix: "(no key; URL paths can include an id)".

**F11 [low] Hebrew: plural and singular are mixed, and one term is used two ways.**
- Where: `README.md:26` ("תתקין לי … ותעזור לי", singular) next to `README.md:149` ("פשוט שאלו", plural). `README.md:28` calls the plugin "הכישורים של ארבוקס"; `docs/launch/README.md:40` and `:62` call the same thing "תוסף".
- Rule (plural you): use plural forms in owner-facing Hebrew, for example "תתקינו לי … ותעזרו לי". The owner's typed prompts can stay as the owner would type them, but should match each other.
- Fix: one term for the plugin, "התוסף של ארבוקס", across the README and the launch kit.

**F12 [low] Hebrew calque.**
- Where: `docs/launch/README.md:53` ("זו גרסת מועמדת לשחרור").
- Fix: "זו גרסה מועמדת לשחרור (RC)", or the English "release candidate" in brackets.

**F13 [low] "Live verification on a real studio" overstates the evidence.**
- Where: `docs/launch/README.md:8`.
- Evidence: all live checks ran on a test gym (`docs/plan/live-check-results.md`).
- Fix: "live verification on a test gym is in progress".

**Not checked:**
- The slash command form in F2 (I cannot run `/plugin` from here).
- The F6 portal questions and the F7 claims: both come from the portal doc read in an earlier pass, not re-fetched this round.
- The menu path "Settings → Club Information" (`README.md:94`). It comes from the Academy/Zapier notes, which also list the older label "Business Information" (`docs/research/arbox-product-2.md:265`). Not confirmed on a studio screen. Confirm before the posts go out.
- The native Arbox menu label in Hebrew (L3, still LIVE).
- Hebrew reading is my judgement, one reader.

**Noticed, not in these files (lead's recipes):** `recipe-first-30-days.md` tells the owner "For two months, set the window to 60 days". The 31-day cap refuses that window.

### Round 3 vouch

**Vouch: yes-if F1 is fixed (no "never changes anything" or "read-only" in any post), F2 is verified or replaced with the `plugin@marketplace` form, F3, F5, F6 and F7 are fixed, the menu path in Not checked is confirmed, and `arbox install` is run so `~/.arbox/bin/arbox` gets the zero-row fix.** Live recipe fetches now return 200, and the whos-drifting stop rule and the class-fill cancelled-status footer both behave as the recipes say. The owner copy is close: the Hebrew needs the plural and one-term fixes, and the posts need F1 before anyone sends them.
