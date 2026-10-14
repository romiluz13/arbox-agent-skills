# Live check results (test gym, reads only)

Run: 2026-10-15, against the test gym profile, executor arbox 0.9.0. Reads only. No write was run, so G10 and L9's write half are not run.

Gym facts recorded: 2 locations (Qiryat Moẕqin; סניף שני). The plan tier is not in any response, so it is still LIVE (needs a screen in Arbox). The key is never printed or recorded here.

Status meanings: PASS = the check ran and the answer is recorded. FAIL = a claim in the skills or the reference is wrong for this account. BLOCKED = the check could not answer (a human is needed, a gate stopped it, or the endpoint returned no rows to look at). NOT RUN = deliberately not run.

Raw responses are in `~/Arbox/work/live/` (outside the repo, never committed). Member data is not recorded here.

| ID | Status | Command (no key) | What happened | Rows and fields | Decision | Raw file |
|---|---|---|---|---|---|---|
| L1 | BLOCKED | (human, clean Mac) | This Mac only: `doctor` READY; curl 8.7.1, jq (Homebrew), python3 3.13 (mise), node v26.10.0 | none | still LIVE: needs a clean Mac | none |
| L2 | BLOCKED | (human, clean Claude Code) | Needs a person in a clean Claude Code install | none | still LIVE | none |
| L3 | PASS | `read -p testgym /v3/locations` | 200; 2 locations; the key sees both | 2 rows; `address` str, `location_id` int, `location_name` str | fact. Plan tier and the Arbox menu label: still LIVE (screen) | L3-locations.json |
| L4 | BLOCKED | `read -p badtest /v3/locations` | Needs a person to type a wrong key into the file (never via chat). Good key: 200 | none | still LIVE | none |
| L5 | PASS | `read /v3/users limit=500`; `read /v3/users --all` | `limit=500` accepted; one page of 60 rows; `--all` gives 60 rows; default page size 200 (`extra.pagination`) | 60 rows | fact. Page cap (20 pages) and 429 not reached: 60 rows only | L5-users-limit500.json, L5-users-all.json |
| L6 | BLOCKED | Claude Code permission prompts; `! read -s` | Needs a person in Claude Code with the permission settings | none | still LIVE | none |
| L7 | (see G4, G5) | | | | | |
| L8 | NOT RUN | none | `/v3/message` is not run through the executor (owner decision) | none | not in v1 unless the owner decides | none |
| L9 | BLOCKED | none (needs the write gate) | Read side only: Hebrew names and statuses read back as UTF-8 in the saved JSON. No write made | none | still LIVE after G10 | existing reads |
| L10 | BLOCKED | (human, cloud routine) | Needs a person to create a cloud routine | none | still LIVE | none |
| G1-404 | PASS | `read /v3/users/<unknown id>` | HTTP 404; exit 4; body `{"statusCode":404,"error":{...},"data":null}` | none | fact | none |
| G1-401/403 | BLOCKED | bad-key read (as L4) | Needs L4 | none | still LIVE | none |
| G2-defaults | PASS | `read /v3/users --all` | 60 rows. Roles: client 26, staffMember 23, lead 11. Staff and leads are included by default | 60 rows | fact | G2-users-default.json |
| G2-only-clients | PASS | `read /v3/users only_clients=1` | 26 rows, all clients | 26 rows | fact | G2-users-only-clients.json |
| G2-location | PASS | `read /v3/users location_id=<id>` | 54 rows (of 60). The location filter works | 54 rows | fact | G2-users-location.json |
| G2-rate | BLOCKED | 20 reads in a row (human only) | Human-only test, not run | none | still LIVE | none |
| G3-birthday-window | BLOCKED | `read /v3/reports/birthdayReport fromDate=2026-09-01 toDate=2026-09-07` | 200; 0 rows, so the rule (birthday or another date) cannot be seen | 0 rows | still LIVE: needs a window with a birthday | G3-birthday-sep1-7.json |
| G3-birthday-cap (fixed in L2) | PASS | `birthdayReport` over a full year | 400 "The date range should not exceed 31 days." reports.md:235 says no cap | none | fact; fix the reference | none |
| G3-finance-sales-cap | PASS | `read /v3/finance/reports/sales` 46 days | 400 "The date range should not exceed 31 days." | none | fact (matches finance.md) | none |
| G3-finance-sales-31d | BLOCKED | `read /v3/finance/reports/sales` 30 and 31 days | 400 "This box is not connected to Arbox Invoice." | none | blocked: no Invoice connection on the test gym | none |
| G3-sales-cap (fixed, lead L1 14-26) | PASS | `read /v3/reports/salesReport` 60 days | 400 31-day cap. reports.md:394 says no cap | none | fact; fix the reference and recipes | none |
| G3-lateCancel-cap (fixed in L2) | PASS | `read /v3/reports/lateCancellationReport` 60 days | 400 31-day cap | none | fact; fix the reference | none |
| G3-tasks-cap (fixed, lead L1 14-26) | PASS | `read /v3/tasks` 31 and 60 days | 400 "The date range should not exceed 7 days." other.md:117 says nothing about a cap | none | fact; fix the reference and recipes | none |
| G3-tasks-window | BLOCKED | `read /v3/tasks from_date=2026-10-08 to_date=2026-10-14` | 200; 0 rows. Reminder date or creation date: cannot be seen | 0 rows | still LIVE | G3-tasks-7d.json |
| G3-leads-converted | PASS | `read /v3/leads/converted` | 200; no window parameter in the spec; returns 1 row | 1 row | fact | G3-leads-converted-nowindow.json |
| G3-leads-lost | PASS | `read /v3/leads/lost` | 200; no window parameter; 0 rows | 0 rows | fact | G3-leads-lost-nowindow.json |
| G3-failedTransactions | BLOCKED | `read /v3/finance/reports/failedTransactions` | 200; no date parameters, so a 30-day window is the same call. 0 rows: drop-out of resolved failures cannot be seen | 0 rows | still LIVE | G3-failed-plain.json |
| G4-inactiveHeadMembersReport | BLOCKED | `read /v3/reports/inactiveHeadMembersReport` | 200; 0 rows; no date parameters needed | 0 rows | still LIVE: fields not seen | G4-inactiveHeadMembersReport.json |
| G4-activeHugimReport | BLOCKED | `read /v3/reports/activeHugimReport` | 200; 0 rows; no date parameters needed | 0 rows | still LIVE: fields not seen | G4-activeHugimReport.json |
| G4-bookingsReport (fixed in L2) | PASS | no parameters; then `fromDate` and `toDate` for 31 days | 400 "'from date' is required", "'to date' is required"; with the window 200, 0 rows. reports.md:453 says none required | 0 rows | fact; fix the reference | G4-bookingsReport.json |
| G4-bookingStatisticsReport (fixed in L2) | PASS | `fromDate` `toDate` `type=summary_attendance_by_customer` | Required: `fromDate`, `toDate`, `type`. Allowed `type`: summary_attendance_by_customer, summary_attendance_by_membership. 200; 0 rows. reports.md:404 says none required | 0 rows | fact; fix the reference | G4-bookingStatisticsReport.json |
| G4-hugimRevenueReport (fixed in L2) | PASS | no parameters; then 31-day window | 400 dates required; with the window 200, 0 rows. reports.md:542 says none required | 0 rows | fact; fix the reference | G4-hugimRevenueReport.json |
| G4-hugimRevenueByReceiptReport (fixed in L2) | PASS | no parameters; then 31-day window | 400 dates required; with the window 200, 0 rows. reports.md:552 says none required | 0 rows | fact; fix the reference | G4-hugimRevenueByReceiptReport.json |
| G4-revenueAnalysisReport (fixed in L2) | PASS | `read /v3/reports/revenueAnalysisReport` | 400: `reportName` not in the server's list. The name is in the spec's enum (47 names) but the server refuses it. reports.md:562 says UNTYPED with no params | none | fact; fix the reference | none |
| G5-absenceReport (fixed, lead L1 14-26) | PASS | 31-day window with `group_by=user` | Plain: 400 (dates and `group_by` required). With the window: 200, 13 rows. `id` (no `user_id`); `phone` null on all 13; `last_seen` null on all 13; `future_registration` non-empty on all 13; `allow_sms` and `allow_email` "unknown" on all 13. reports.md:502 | 13 rows | fact; the join and the `last_seen` path cannot be checked on this gym | G5-absenceReport.json |
| G5-expiringSessionsReport (fixed in L2) | PASS | 31-day window, next 31 days | 200; 1 row. `sessions_left` int; `future_schedules` int; `count_session` int. reports.md:303 says string or null | 1 row | fact; fix the reference (303) | G5-expiringSessionsReport.json |
| G5-sessionsReport (fixed in L2) | PASS | plain | 200; 7 rows. `sessions_left` int on all 7; `count_session` null on all 7. reports.md:293 says string or null | 7 rows | fact; fix the reference (293) | G5-sessionsReport.json |
| G5-expiringMembershipsReport | BLOCKED | 31-day window | 200; 0 rows (the `--all` form wrote a 0-byte file). Fields not seen | 0 rows | still LIVE | G5-expiringMembershipsReport.json |
| G5-debtReport | PASS | plain | 200; 14 rows. `debt` int; `price` int; `status` labels "Incompatible Status" (9) and "inactive" (5); `task_status` "taskNone" (14) | 14 rows | fact. Meaning of `debt` (overdue or scheduled): still LIVE. `debt` equals `price` on all 14 rows | G5-debtReport (recipes/ptc-debt.json) |
| G5-trialClassesReport (fixed, lead L1 14-26) | PASS | 44-day window (leads-and-trials recipe) | 400 31-day cap. The 31-day window: 200; 0 rows | 0 rows | fact; fix the recipe window | G5-trialClassesReport.json |
| G5-regularsReport | BLOCKED | plain | 200; 0 rows: the gym has no regular slots. Fields not seen | 0 rows | still LIVE | G5-regularsReport.json |
| G5-inactiveMembersReport | BLOCKED | 31-day window | 200; 0 rows | 0 rows | still LIVE | G5-inactiveMembersReport.json |
| G5-convertedLeadReport | BLOCKED | 31-day window (and 30 days with `--all`) | 200; 0 rows; the `--all` form wrote a 0-byte file | 0 rows | still LIVE | G5-convertedLeadReport.json |
| G5-membersPropertiesReport | PASS | plain | 200; 13 rows. Fields present include `has_waiver`, `medical_cert`, `injury`, `personal_id` (values not read). Fuzzy match not run | 13 rows | fact | G5-membersPropertiesReport.json |
| G5-salesReport (fixed, lead L1 14-26) | PASS | 60-day window | 400 31-day cap. The 31-day window: 200; 0 rows | 0 rows | fact; fix the reference and the recipes | G5-salesReport (31-day) |
| G5-activeMembershipsReport | PASS | plain | 200; 6 rows; `end_date` null on all 6; `open_charges` and `ltv` strings | 6 rows | fact | G5-activeMembershipsReport.json |
| G5-last_seen | BLOCKED | from the absence rows | null on all 13 rows, so there is no value to compare with a member card | none | still LIVE | none |
| G5-future_schedules | BLOCKED | from the 1-row expiring-sessions report | No member with a booking next week to compare | 1 row | still LIVE | none |
| G6-active0 | PASS | `read /v3/users/memberships active=0` | 200; 15 rows; `active` int 0 on all | 15 rows | fact | G6-memberships-active0.json |
| G6-active1 | PASS | `read /v3/users/memberships active=1` | 200; 33 rows; `active` int 1 on all. No membership id in both sets | 33 rows | fact | G6-memberships-active1.json |
| G6-active2 | PASS | `read /v3/users/memberships active=2` | 200; 0 rows. Value 2 returns nothing on this gym (meaning still LIVE) | 0 rows | fact | G6-memberships-active2.json |
| G6-searchUser | PASS | `read /v3/users/searchUser type=phone value=<05x>`; then the `+972` form | Both 200, 1 row each. Both forms match the same person | 1 row each | fact | G6-search-05.json, G6-search-972.json |
| G6-recurringPayments | BLOCKED | `read /v3/users/recurringPayments user_id=<test user>` (11 users) | 200; 0 rows for each of 11 users. Masking not observed. No digits recorded | 0 rows | still LIVE | G6-recurringPayments.json |
| G7-schedule-plain | PASS | `read /v3/schedule from_date=2026-10-15 to_date=2026-10-21` | 200; 8 rows | 8 rows | fact | G7-schedule-7d-plain.json |
| G7-schedule-counts | PASS | same with `registration_count=1 waiting_list_count=1` | 200; 8 rows. Adds only `registration_count` and `waiting_list_count` (both int) | 8 rows | fact: counts appear only with the flags | G7-schedule-7d-counts.json |
| G7-cancelled | BLOCKED | same window with `cancelled=1` | Same 8 ids as the plain read. No cancelled classes in the window, so the filter cannot be seen | 8 rows | still LIVE | G7-schedule-7d-cancelled.json |
| G7-schedule-42d (fixed, lead L1 14-26) | PASS | 42-day window (class-fill recipe) | 400 31-day cap | none | fact; fix the recipe window | none |
| G7-waitinglist | BLOCKED | `read /v3/schedule/entryFromWaitingList` (no `confirm`) | 200; 0 rows. Current or promoted entries not seen | 0 rows | still LIVE | G7-waitinglist.json |
| G7-trial-bookings | BLOCKED | `read /v3/schedule/booking/trial` | 200; 0 rows. Default order not seen | 0 rows | still LIVE | G7-trial-bookings.json |
| G7-boxCategories | PASS | `read /v3/schedule/boxCategories`; then `service_type=1`, `2`, `4` | 200; 10 rows. `type` labels: "Group class" (1), "Appointments" (3), and a translation key "messages.boxCategoryTypes.3" (6). `service_type`=1 gives 1 row, 2 gives 3 rows, 4 gives 0 rows. Two rows carry a `salary_details` key (values not read) | 10 rows | fact: an untranslated key appears in the output | G7-boxCategories*.json |
| G7-boxScheduleSettings | PASS | `read /v3/schedule/boxScheduleSettings` | 200; a single object with 10 configuration keys, no rows. Values are configuration only (zeros and nulls) | 10 keys | fact | G7-boxScheduleSettings.json |
| G7-availability | BLOCKED | `staffAvailability` and `spacesAvailability` with `box_category_id` and a 7-day window | 200 each; 0 rows | 0 rows | still LIVE | G7-*Availability-7d.json |
| G8-leads-vs-converted | PASS | `read /v3/leads --all`; `read /v3/leads/converted` | The converted lead's id is not in the default `/v3/leads` list (11 rows). So converted leads leave the default list. `lead_status` values: "Created" (9), two Hebrew labels (1 each); the converted row reads "Converted to Member" | 11 and 1 rows | fact | G8-leads-all.json |
| G8-statuses | PASS | `read /v3/statuses` | 200; 5 rows. Fields `id` int, `status_name` str, `active` int. One label has trailing spaces | 5 rows | fact | G8-statuses.json |
| G8-lostReasons | PASS | `read /v3/lostReasons` | 200; 8 rows. Fields `id`, `lost_reason_name`, `active` | 8 rows | fact | G8-lostReasons.json |
| G8-sources | PASS | `read /v3/sources` | 200; 5 rows. Fields `id`, `source_name`, `active` | 5 rows | fact | G8-sources.json |
| G8-tasktypes | PASS | `read /v3/tasks/types` | 200; 6 rows. Fields `task_type_id` int, `type` str (mixed English and Hebrew), `task_type_color`, `active` | 6 rows | fact | G8-tasktypes.json |
| G9-invoices | BLOCKED | `read /v3/finance/reports/invoices` 31 days | 400 "This box is not connected to Arbox Invoice." | none | blocked: no Invoice connection | none |
| G9-receipts | BLOCKED | `read /v3/finance/reports/receipts` 31 days | Same 400 | none | blocked: as above | none |
| G9-cashFlow | BLOCKED | `read /v3/finance/reports/cashFlow` 31 days | Same 400 | none | blocked: as above | none |
| G9-sales | BLOCKED | `read /v3/finance/reports/sales` 31 days | Same 400 | none | blocked: as above | none |
| G9-failedTransactions | BLOCKED | `read /v3/finance/reports/failedTransactions` | 200; 0 rows. No masking to check | 0 rows | still LIVE | G3-failed-plain.json |
| G10 | NOT RUN | none | Lead's call after reads; gated | none | lead decides | none |
| R-whos-drifting (fixed, lead L1 14-26) | PASS | recipe commands | regularsReport: 0 rows. absenceReport with the recipe's 90-day window and no `group_by`: 400. The absence rows cannot be joined (phone null on all 13) and `last_seen` is null on all 13. No report produced | none | recipe needs a fix and a gym with regular slots | none |
| R-renewal-watch | BLOCKED | recipe commands | Windows of 31 days accepted. `expiringSessionsReport`: 1 row. `expiringMembershipsReport`: 0 rows. `users`: 60 rows. Too little data to compute. No report produced | 1, 0 and 60 rows | still LIVE: needs data | G5 and users files |
| R-payments-to-chase (fixed, lead L1 14-26) | PASS | recipe commands | `debtReport` 14 rows (computed). `failedTransactions` 0 rows. `tasks` (90-day window): 400 7-day cap. Report built with tasks shown as unknown | 14 rows | fact; fix the tasks window in the recipe | ptc-debt.json; report built |
| R-leads-and-trials (fixed, lead L1 14-26) | PASS | recipe commands | `leadsInProcessReport` 11 rows. `trialClassesReport` (44 days): 400 31-day cap. `convertedLeadReport` `--all`: 0-byte file. `tasks` (60 days): 400 7-day cap. `statuses` and `sources`: 5 rows each. No report produced | 11 rows | fact; fix the windows and the helper | recipes/lt-*.json |
| R-sales-snapshot (fixed, lead L1 14-26) | PASS | recipe commands | `salesReport` `--all` with 15-day windows: 0 rows, written as a 0-byte file | 0 rows | fact; helper defect (see H-all-zero) | recipes/ss-*.json |
| R-class-fill (fixed, lead L1 14-26) | PASS | recipe commands | Schedule (42 days): 400 31-day cap. Schedule (29 days): 21 rows. `cancelled_status` is not a field on any schedule row, so the recipe filter drops every row. Counts are int, not strings. `classesSummaryReport` (28 days): 31 rows, including a `salary` field (not read). Report built: all 21 classes show 0 bookings and 0 waiting | 21 rows | fact; fix the recipe window and filter | recipes/cf-*.json; report built |
| R-no-shows (fixed, lead L1 14-26) | PASS | recipe commands | `absenceReport` (no parameters): 400. `lateCancellationReport` and `bookingCancellationReport` with the 15-day windows: 0 rows, written as 0-byte files. No report produced | 0 rows | fact; fix the absence command and the helper | recipes/ns-*.json |
| R-first-30-days (fixed, lead L1 14-26) | PASS | recipe commands | `salesReport` (60 days): 400 31-day cap. `absenceReport` (no parameters): 400. `users`: 60 rows. No report produced | 60 rows | fact; fix the windows and the command | recipes/f30-*.json |
| R-waivers-and-forms (fixed, lead L1 14-26) | PASS | recipe commands | `membersPropertiesReport` 13 rows. `digitalForms` 5 rows. `signedFormsReport` (recipe command has no `toDate`): 400. With both dates: 0 rows, written as 0-byte file. `salesReport` (15 days): 0 rows. No report produced | 13 and 5 rows | fact; fix the command and the helper | recipes/wf-*.json |
| R-monday-page | NOT RUN | none | Composed from the sections above; not run | none | not run | none |
| H-all-zero (fixed in repo, tests 72/72; installed copy stale) | PASS | `read ... --all` with zero rows | Writes a 0-byte file and prints "install jq", though jq is installed. The cause is in `skills/arbox-api/scripts/arbox` `fetch_all` (around line 642, empty page list passed to `xargs jq`) and `emit_result` (line 590) | none | helper defect for the lead | any zero-row `--all` |
| H-server-enum (fixed in L2) | PASS | error text from `GET /v3/reports/{name}` | The server accepts 53 report names; the spec enum has 47. The server accepts `activeMembers`, `activePlanMembers`, `activeSessionMembers`, `externalMembershipsReport`, `getMissingMembers`, `shiftSummaryReport`, `workshopsBookingReport` (not in the spec). It refuses `revenueAnalysisReport` (in the spec) | none | fact; reconcile the reference with the server | none |

## Counts

Counts are taken from the Status column (the rows above; the L7 row points at G4 and G5 and is not counted).

84 rows after L2: PASS 35, FAIL 15, BLOCKED 31, NOT RUN 3 (L8, G10, R-monday-page). L1 counts were PASS 25, FAIL 25; L2 flipped 10 reference-only rows to PASS.

## Not covered in this run

- The 142 LIVE CHECK lines across the 24 reference and recipe files were not each run one by one. This run covers the checks grouped as G1 to G9 and the recipe fetch commands. Everything else is still LIVE.
- Nothing has been compared with the Arbox screens (section 5 of the runbook). That needs a person.

## L2 re-verification (2026-10-15)

Reference corrections applied to `skills/arbox-api/references/` (reports, quirks, other, finance). The re-runs below use the documented parameters. Each row is a read with the exit code from the helper.

| Command (no key) | Result |
|---|---|
| `read /v3/reports/inactiveMembersReport fromDate toDate` (31 days) | 200, 0 rows |
| `read /v3/reports/expiringMembershipsReport fromDate toDate` | 200, 0 rows |
| `read /v3/reports/convertedLeadReport fromDate toDate` | 200, 0 rows |
| `read /v3/reports/salesReport fromDate toDate` (31 days) | 200, 0 rows |
| `read /v3/reports/birthdayReport fromDate toDate` (31 days) | 200, 0 rows |
| `read /v3/reports/birthdayReport` full year | 400, 31-day cap |
| `read /v3/reports/lateCancellationReport fromDate toDate` (31 days) | 200, 0 rows |
| `read /v3/reports/lateCancellationReport` (60 days) | 400, 31-day cap |
| `read /v3/reports/signedFormsReport toDate` only | 200, 6 rows |
| `read /v3/reports/signedFormsReport fromDate toDate` (31 days) | 200, 0 rows |
| `read /v3/reports/bookingStatisticsReport ... type=summary_attendance_by_membership` | 200, 0 rows |
| `read /v3/reports/bookingsReport fromDate toDate` | 200, 0 rows |
| `read /v3/reports/hugimRevenueReport fromDate toDate` | 200, 0 rows |
| `read /v3/reports/hugimRevenueByReceiptReport fromDate toDate` | 200, 0 rows |
| `read /v3/reports/revenueAnalysisReport` | 400, name refused by the server |
| `read /v3/reports/expiringSessionsReport fromDate toDate` (31 days, forward) | 200, 1 row |
| `read /v3/reports/sessionsReport` | 200, 7 rows |
| `read /v3/reports/absenceReport fromDate toDate group_by=user` (31 days) | 200, 13 rows |
| `read /v3/tasks` 8 days | 400, 7-day cap |
| `read /v3/tasks` 7 days | 200, 0 rows |
| `read /v3/schedule` 31 days | 200, 8 rows |
| `read /v3/finance/reports/sales` 46 days | 400, 31-day cap |

The seven names the server accepts but the spec does not list (`activeMembers`, `activePlanMembers`, `activeSessionMembers`, `externalMembershipsReport`, `getMissingMembers`, `shiftSummaryReport`, `workshopsBookingReport`) are documented as undocumented in `reports.md`. Six return 400 without dates. Five return 500 with dates, `getMissingMembers` returns 500 with `fromDate`, and `workshopsBookingReport` returns 500 with no parameters.

## V1 re-run of recipe fetches (2026-10-15, test gym)

Each recipe's "Data to fetch" command was run as written, with dates for today. Status 200 is the key result; the row count is what the file held.

| Recipe | Command result (live) | Note |
|---|---|---|
| whos-drifting | regularsReport 200, 0 rows; absence 200, 13 rows | `--all` on the empty regulars report wrote a 0-byte file; plain read shows 200 |
| payments-to-chase | debt 200, 14 rows; failedTransactions 200, 0 rows; tasks (7-day window) 200, 0 rows | `--all` on empty tasks wrote 0 bytes |
| renewal-watch | expiringSessions 200, 1 row; expiringMemberships 200, 0 rows; users 200, 60 rows | empty `--all` wrote 0 bytes |
| leads-and-trials | leadsInProcess 200, 11 rows; trials 200, 0 rows; convertedLead 200, 0 rows; tasks 200, 0 rows; statuses 200, 5 rows; sources 200, 5 rows | three empty `--all` writes gave 0 bytes |
| class-fill | schedule 200, 21 rows; classesSummary 200, 17 rows | window is today-14 to today+14 |
| no-shows | lateCancellation 200, 0 rows; bookingCancellation 200, 0 rows; absence 200, 13 rows; users 200, 60 rows | empty `--all` gave 0 bytes |
| first-30-days | sales 200, 0 rows; absence 200, 13 rows; users 200, 60 rows | window 31 days |
| waivers-and-forms | membersProperties 200, 13 rows; signedForms 200, 6 rows; digitalForms 200, 5 rows; sales 200, 0 rows | |
| sales-snapshot | this month 200, 0 rows; last month 200, 0 rows | empty `--all` gave 0 bytes |

The repo copy of the helper has the zero-row fix (`tests/cases.sh` `case_all_zero_rows`, suite 72 passed, 0 failed). The installed copy at `~/.arbox/bin/arbox` predates it and still writes 0 bytes. Run `arbox install` to update it.

Recipe runs end to end:
- **class-fill**: report rebuilt at `~/Arbox/reports/class-fill-2026-10-15.html` with the footer note "Cancelled classes can't be told apart in this data". The recipe's jq filter runs on the live file and keeps all 21 classes.
- **whos-drifting**: the join matched 0 of 13 absence rows against 0 regulars (phone empty on all 13), so the recipe's stop rule applies. Counts only, no report. The recipe's jq on the 0-byte regulars file fails with "Cannot iterate over null"; on the plain envelope it runs and shows 0 joined.

