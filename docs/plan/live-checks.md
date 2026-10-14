# Live checks runbook (test gym only)

Purpose: turn every LIVE CHECK in the arbox-api references, the recipe assumptions and the owner-journey L1-L10 list into a recorded fact, or into a recorded decision to ship without it. Promotion to 1.0.0 follows the rule in section 7.

Status: written 2026-10-14 against v0.9.0. Nothing here has been run. Results go in `docs/plan/live-check-results.md` (create it on the first run, using the template in section 6).

## 0. Gates before anyone runs a write

Read this first. Three things in the current build differ from the plan, so the runbook is written to the build as it is.

| Gate | Current state | What the runbook does |
|---|---|---|
| Write allowlist (B02.2 item 8) | Not built. `skills/arbox-api/scripts/arbox` has an R3 **denylist** (`r3_refused`, lines 178-198). Any path not on the denylist is allowed past the gate with `--yes-i-confirmed`. | No write check (G10) runs until the allowlist is in and `tests/run.sh` proves PATCH /v3/users, PATCH /v3/users/injury, PATCH /v3/schedule, the bookings and /v3/message are refused. Reads (G1-G9) can run now. |
| `arbox setup --prompt` | Does not exist. Setup takes `[name] [--open]` and creates a placeholder line. `--open` opens the keys file in TextEdit on a Mac. | Use `arbox setup testgym --open`. The owner pastes the key in the file, never in chat. A hidden-input prompt is the D6 change and is not built; L6 decides whether `!` can carry it. |
| `read --pages N` | Does not exist. `read` takes `--out FILE` and `--all` (pages by itself, and `page=` or `limit=` cannot be set with it). | Use `--all`. Page counts come from the row count in the output. |

If a gate fails, the affected check is recorded as **blocked**, not skipped silently.

## 1. Prerequisites

1. **Test gym only.** A test or sandbox Arbox account with disposable members, leads and tasks. Never a live studio. Name every test record `LIVECHECK-YYYYMMDD-n` so it can be found and deleted in the Arbox app afterwards.
2. **Who runs what.** The human runs every command in their own terminal, or with the `!` prefix in Claude Code. The agent does not read `~/.arbox/profiles`, does not see the key, and does not run writes without the human's explicit yes for that exact command.
3. **The key arrives by file, never in chat** (decision: "Test gym key: user will provide later, via a file, never in chat").
4. **Set up the profile.**
   ```
   ~/.arbox/bin/arbox doctor                 # offline: curl, python3 (not used if a stub), jq, node, keys file mode
   ~/.arbox/bin/arbox setup testgym --open   # creates the keys file with a placeholder and opens it in TextEdit
   ```
   In TextEdit: replace the placeholder after `testgym=` with the key, save as plain text. The key is never typed in the terminal.
5. **Check the profile without printing the key.**
   ```
   ~/.arbox/bin/arbox profiles               # names and states only
   ~/.arbox/bin/arbox doctor --online        # a live call; reports the connection state
   ```
6. **Record the test gym's plan tier and location count** in the results file before anything else. Several recipes depend on Standard+ screens (section 5).
7. **Logs.** Every `read` and `write` is logged to `~/Arbox/logs/actions.log` (HTTP status only). Keep it with the results.

## 2. Rules while running

- Reads first, all of them, before any write.
- One command at a time. No loops except the rate-limit test in G2, which the human runs.
- Stop at the first HTTP 429 or a burst of 5xx. Record it and stop.
- Never retry a write. A repeated POST may create a duplicate (quirks.md: no operation documents idempotency).
- Use `--out ~/Arbox/work/livecheck/<name>.json` for any response with member data. Record field names, row counts and masked samples, never full rows or phone numbers, emails or card digits.
- Do not use Claude Code's accept-everything permission mode during the run. The point is to see the real prompts (L6).

## 3. L1-L10: the environment and product questions

From docs/design/owner-journey.md section 5b, updated for the current build.

| ID | Check | Command or action | Record | Changes which file |
|---|---|---|---|---|
| L1 | Which runtimes exist on a clean Mac, and whether `python3` is a stub | `~/.arbox/bin/arbox doctor` on a Mac with only the Claude Code native install; separately `command -v curl node jq python3` | the doctor lines for curl, jq, node, python3 | owner-journey.md rule 7; the compute fallback in the recipes |
| L2 | Does the plugin install work without Node, and does `npx` exist | In a clean Claude Code: `/plugin marketplace add romiluz13/arbox-agent-skills`, then `/plugin install arbox@arbox-agent-skills`. Note whether `npx` is present. | install result, whether the three skills appear, Node present yes/no | README install section; arbox-guide SKILL.md install line |
| L3 | Where the owner gets the key, whether it is per location, read-only or full power | Find it in Arbox (Settings > Club Information per Academy). Then `~/.arbox/bin/arbox read /v3/locations` and compare the rows with the test gym's location count. | the menu label seen, location rows returned, whether a key sees one or several locations, the plan tier | quirks.md key rules; setup copy; arbox-product.md "Where to find things" |
| L4 | Status codes for a good key and a bad key | Good key: `read /v3/locations`. Bad key: a second profile `badtest` whose value the human types into the file as a clearly wrong string, then `read -p badtest /v3/locations`. | the HTTP status the executor prints (401 or 403), the body text, and whether the `Arbox said:` line is safe to show | quirks.md auth section (G1); the executor's error text |
| L5 | Pagination totals, default limit, `extra`, rate limits | `read /v3/users limit=500 --out ...`, then `read /v3/users --all --out ...`; then the rate test in G2 | row counts, whether any response reveals a total, what `extra` holds, first 429 if any | quirks.md:30-35; the `--all` default |
| L6 | Harness allow rule and hidden input | In Claude Code, add `Bash(~/.arbox/bin/arbox read:*)` to settings. Run one read: expect no prompt. Run one write-shaped command with no `--yes-i-confirmed`: expect the executor to refuse, and the harness to prompt. Then test `! read -s x; echo ${#x}` (prints the length only, never the value). | prompt yes/no per command, whether `!` accepts hidden input | setup copy (owner-journey rule 2 and 4); whether setup can use `!` |
| L7 | Report shapes and the seven UNTYPED reports | See G4 and G5. | see those groups | arbox-reports.md; the recipe field lists |
| L8 | `POST /v3/message` behavior | **Not run through the executor.** `/v3/message` is on the R3 denylist and sends to members. Only the owner decides whether it is tested, and then only to the owner's own test user, by hand, in the Arbox app or with a human-typed command. | "not run" unless the owner decides otherwise | v1.1 send feasibility; the drafts-only rule stays |
| L9 | Hebrew round-trip (UTF-8 through JSON bodies and HTML) | After the write gate: create a `LIVECHECK` lead whose name is Hebrew (G10), read it back with `read /v3/users/searchUser type=phone value=...` or `GET /v3/leads`, compare bytes. Render one report with `dir="auto"` in headless Chrome. | the bytes match yes/no, the rendered RTL result | the report template; decisions Q7b |
| L10 | Can a cloud routine reach local files | Human creates a cloud routine that reads `~/.arbox/profiles`. Expect it cannot. | yes/no | promises about scheduling in README and guide (none in v1) |

## 4. LIVE CHECK groups in the references

Each group maps to read commands unless stated. The group is the unit of work. Results go to the results file with the group ID.

Common output pattern for a read:
```
~/.arbox/bin/arbox read -p testgym /v3/<path> [name=value ...] --out ~/Arbox/work/livecheck/<group>-<n>.json
```
Then record the status line, the row count, the top-level keys and the field names (`python3 -I` or `jq` if present).

### G1. Auth and error shape
Covers: quirks.md 401/403/429 not declared; `GET /v3/users/{type}` unknown-id behavior; `GET /v3/locations` bad key (L4).
- `read /v3/users/{userId}` with an id that does not exist: record 404, 422, or empty array.
- Record exactly which of 401 or 403 the bad key returns (L4).
- Changes: quirks.md auth and errors; executor message text.

### G2. Query defaults, scope and rate
Covers: `GET /v3/users` (default limit, `sort`, whether leads and staff are included without `only_clients`); quirks.md:65 (`location_id` omitted); L5.
- `read /v3/users` with no parameters; then with `location_id=<id>`. Compare counts.
- `read /v3/users only_clients=1` vs no filter. Compare counts and `user_role` values.
- Rate test (human only): 20 `read /v3/locations` in a row with the timing. Record any 429 and stop there.
- Changes: users.md (Get All Users); quirks.md:30-35, 65.

### G3. Dates and windows
Covers: reports `fromDate`/`toDate` (quirks.md:61); finance `from_date`/`to_date` 31-day cap (quirks.md:58); `GET /v3/tasks` date meaning; lead conversion and lost windows; failed transactions window.
- `read /v3/reports/birthdayReport fromDate=2026-09-01 toDate=2026-09-07`: check whether rows are filtered by birthday or by another date.
- `read /v3/finance/reports/sales from_date=2026-08-01 to_date=2026-09-15` (46 days): record whether the cap is enforced and the exact error. Then a 31-day window: record the row count.
- `read /v3/tasks` with a date range: does it filter reminder date or creation date.
- `read /v3/leads/converted` and `/v3/leads/lost` with no window: all-time or a window.
- `read /v3/finance/reports/failedTransactions` for 30 days: do resolved failures drop out.
- Changes: quirks.md:58, 61; finance.md; other.md (Get All Tasks); leads.md (Get Converted/Lost Leads); arbox-reports.md (fromDate/toDate rule).

### G4. The seven UNTYPED reports (report-to-schema mapping)
Covers: arbox-reports.md L7 for `inactiveHeadMembersReport`, `bookingStatisticsReport`, `bookingsReport`, `activeHugimReport`, `hugimRevenueReport`, `hugimRevenueByReceiptReport`, `revenueAnalysisReport`.
- One command each: `read /v3/reports/<name> --out ~/Arbox/work/livecheck/G4-<name>.json`.
- Record: status, row count, top-level keys, the field names of the first row (masked), and whether the fields match what the recipe assumes (section 5).
- Decision per report: mapped to a schema (only if the names match exactly, as in the H07a method) or kept UNTYPED with the field list written in the reports reference.
- Changes: arbox-reports.md entries 25, 31, 36, 44-47; skills/arbox-api/references/reports.md; the recipe that uses the report.

### G5. Recipe-critical fields (the 40 INFERRED reports that recipes use)
Covers: `absenceReport` (`last_seen` meaning, `future_registration`, `latest_registration`, no `user_id`); `expiringSessionsReport` and `sessionsReport` (`sessions_left` as string or null, `future_schedules` meaning); `expiringMembershipsReport`; `debtReport` (`debt`); `trialClassesReport`; `regularsReport`; `inactiveMembersReport`; `convertedLeadReport` (fuzzy match); `membersPropertiesReport` (fuzzy match); `salesReport`; `activeMembershipsReport`.
- For each: one read, one row-level comparison.
- `last_seen`: pick five members the human knows well. Compare `last_seen` with the last visit in the Arbox client profile. Record match, off by days, or a different meaning (booking date, login date).
- `sessions_left`: find one membership with a known balance. Record whether a null means zero, unlimited, or unknown.
- `future_schedules`: find one member with a booking next week. Record whether the count includes it.
- Changes: arbox-reports.md (the INFERRED entries); recipes-decision.md "Reopen if" line; the recipe's assumption text.

### G6. Membership and person fields
Covers: `GET /v3/users/memberships` (`active` 0/1/2 meaning, `type` filter, `sessions_left` absent on the read, users.md:358 and 518); `GET /v3/users/searchUser` (phone formats); `GET /v3/users/recurringPayments` (card masking).
- `read /v3/users/memberships active=0`, `active=1`, `active=2`: record counts and what `2` returns.
- `read /v3/users/searchUser type=phone value=<05x form>` and the `+972` form, same person: record whether both match.
- `read /v3/users/recurringPayments user_id=<disposable test user>`: record only whether `credit_card_number` is masked (yes or no). Never record digits.
- Changes: users.md (Get User Memberships, Search user, Get user recurring payments); quirks.md:44, 54, 105.

### G7. Schedule and waiting list
Covers: `GET /v3/schedule` with `registration_count=1&waiting_list_count=1` (opt-in counts); `cancelled=1`; `GET /v3/schedule/entryFromWaitingList`; trial bookings read; services and settings units; space and staff availability rows.
- `read /v3/schedule from_date=... to_date=...` with and without `registration_count=1&waiting_list_count=1`: record which fields appear.
- `read /v3/schedule/entryFromWaitingList` **with no `confirm` parameter.** `read` refuses it if a `confirm` is given (B02.2 item 11). Record whether the list is current waiting people or people already promoted.
- `read /v3/schedule/booking/trial` with a window: record the default order.
- `read /v3/schedule/boxCategories` and `/v3/schedule/boxScheduleSettings`: record service type values 1, 2, 4 and the time units.
- Changes: schedule.md (Get Schedule, Get Waiting List Entries, Get Services, Get Schedule Settings, availability operations); ideas-catalog class-fill.

### G8. Leads, sources, tasks
Covers: `GET /v3/leads` (converted and lost included?); whether `user_id` stays the same after a lead joins; `GET /v3/sources`; `GET /v3/statuses` and `GET /v3/lostReasons`; `GET /v3/tasks` and `GET /v3/tasks/types`.
- `read /v3/leads` and `read /v3/leads/converted`: compare the `user_id` of one converted lead across the two.
- `read /v3/statuses`, `read /v3/lostReasons`, `read /v3/sources`: record item shapes.
- `read /v3/tasks/types`: record the types and the id field.
- Changes: leads.md (Get All Leads, Get Lead Statuses, Get Lead Sources, Get Lead Lost Reasons); other.md (tasks).

### G9. Finance reads
Covers: invoices, receipts, cash flow, sales row shapes (`Get Cash Flow Report`, `Get Invoices Report`, `Get Receipts Report`, `Get Sales By Invoice Report`); failed-transaction fields; masking of `last_four_digits`.
- One 31-day read per report. Record top-level keys, row fields, and `last_four_digits` masked yes/no.
- Changes: finance.md (all six finance reads).

### G10. Write checks (allowlist only, after the Gate in section 0)
Covers: duplicate and retry behavior, defaults on create, reversibility, Hebrew (L9). Every write is a `LIVECHECK-` record. The human types the confirm flag for each command.
- `POST /v3/leads` with a Hebrew name and a phone number: record the response, then send the same body again. Record whether a duplicate appears. (Duplicate phone behavior, defaults for status and source.)
- `POST /v3/leads/createNote` on that lead: record where the note reads back. Re-send: duplicate?
- `POST /v3/leads/updateStatus` to a status, then the same status again: idempotent?
- `POST /v3/leads/markAsLost`: can `updateStatus` reopen it?
- `POST /v3/tasks` with `reminder.time` in one format, then a second format if the first fails: record the format and whether the assignee is notified.
- `POST /v3/tasks/markAsCompleted/{task_id}` twice: record the second response.
- `POST /v3/users/createNote` for the test user: record whether a lead id works and whether the note is visible to the member.
- Command shape: `arbox write -p testgym POST /v3/leads --body-file ~/Arbox/work/livecheck/lead.json --yes-i-confirmed`. The body file holds only `LIVECHECK` test data.
- Changes: leads.md (Create New Lead, Add Note, Update Lead Status, Mark Lead as Lost); other.md (tasks, Create user note); quirks.md:89 (idempotency).

### G11. Operations outside v1 (no command)
These are not run by the executor, because they are R2 or R3 or not on the allowlist. Their open questions stay open, and the features stay off in v1.
- Bookings and cancellations: Book Session, Cancel session, Book Trial Class, Cancel Trial Booking, Update Class Schedule.
- Members and memberships: Create New User, Update user, Delete user, Create User Membership, Update user membership, Cancel user membership, Suspend user membership, Create Membership QR, Attach commitment document, Group users, Create or update injury, Change user profile image, Edit user recurring payment.
- Money: Create Document, and any recurring-payment write.
- Messages: Send Message to User (L8), Create Digital Form Link (not on the allowlist).
- Never tested, not even by a human: Get Staff Salary. Salary data is skipped by default (SKILL.md safety).
- To revisit one of these, the owner must decide it is in scope. Then a separate runbook entry is written for it.

## 5. Recipe acceptance: row-for-row against the Arbox screen

Each recipe ships only if its output matches the native Arbox screen row for row on the test gym. The screen names come from docs/research/arbox-product.md and arbox-product-2.md. The exact label must be confirmed in the test gym before the first run, and the confirmed label is written into the results file.

| Recipe | Arbox screen to compare (confirm the label) | Filter to set in Arbox | What must match |
|---|---|---|---|
| renewal-watch | Reports > Retention (memberships expiring without renewal); Memberships list | Expiring within 14 days (the interview default) | same people, same end dates, same count |
| payments-to-chase | Transactions > Failed Transactions; client debt indicator; the debt report | Last 30 days; debt above 0 | same people and amounts; card digits never shown on either side |
| leads-and-trials | Leads list; Reports > Growth; trial classes | Last 30 days | same counts by status; same converted and lost totals |
| whos-drifting | Reports > Retention ("clients at risk"); absence report | No visit in 3 weeks (the default) | same names; five spot-checked against the client profile visit history |
| sales-snapshot | Dashboard or finance monthly history (Standard+); Reports Essentials | This month vs last month | same totals to the shekel; same rounding |
| class-fill | Schedule (capacity, registered, waiting list) | Next 2 weeks and last 4 weeks | same counts per class |
| no-shows | Penalties settings; absence and late-cancellation reports | This month | same counts per person |
| first-30-days | Clients list filtered to new members; active memberships report | Joined in the last 30 and 60 days | same members; same return-visit flags |
| waivers-and-forms | Digital forms; the signed-forms report | Per form type | same signed and unsigned counts |
| Monday page | No separate screen. Compare each section to its source screen above (renewal-watch, payments-to-chase, sales-snapshot, class-fill, no-shows). | As above | every section matches its source |

Pass rule: a recipe passes when one live run matches the screen on every "what must match" item, and the spot checks in the recipe are recorded. A recipe that fails stays in the release labelled beta, with the failing row listed on its page.

The commands for each recipe are the `read` lines in its `skills/arbox-recipes/references/recipe-<name>.md` file. Those files are not final yet, so the first run of each recipe records the command it actually used.

## 6. Results template

Create `docs/plan/live-check-results.md` on the first run. One row per check.

| ID | Date | Test gym (plan, locations) | Exact command (no key) | Status and result | Row count and field names | Decision (fact / still LIVE / blocked) | File changed |
|---|---|---|---|---|---|---|---|
| L4 | | | | | | | |
| G4-revenueAnalysisReport | | | | | | | |

Rules for the results file:
- Record the answer, not the data. No member names, phones, emails or card digits.
- A check is closed only by a row with a decision. "Looks fine" is not a result.
- Any check that could not run is recorded as blocked, with the gate that stopped it (section 0).

## 7. Promotion to 1.0.0

Version 0.9.0 becomes 1.0.0 only when all of the following hold. The lead decides the version bump.

1. L1, L2, L3, L4, L5, L6 and L9 each have a result row. L8 and L10 each have a decision row (run, or explicitly not in v1).
2. G1 through G9 each have result rows for every LIVE CHECK in their group. Any check still open has a "still LIVE" row and the feature that depends on it is labelled beta or removed.
3. G4: every UNTYPED report has a row. No recipe depends on an untyped field without saying so on its page.
4. Section 5: every recipe in the 1.0 release passes row-for-row, or is labelled beta with its failing check.
5. The write allowlist (B02.2 item 8) is in the executor, with tests that prove the refused operations are refused. Then G10 has result rows.
6. README and CHANGELOG say: "validated against the published spec and a fake server; live results from <date> on a test gym (<plan>)". No claim beyond what the results file records.

Stop rules at any point: a 429 burst, a 5xx burst, an unexpected write, or a response that prints a key or a card number. Stop, record it, and do not continue until the lead has read the record.
