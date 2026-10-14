# v1 recipe picks: Sonnet (T5S, blind)

Owner: Matt | Route: Plan | Phase: resolve design decisions | Author: Sonnet | 2026-10-14
Lens: data truth (what the reports and endpoints can reliably compute), then build effort, then eval-ability on the test gym.
Blind: written before reading any other teammate's recipe file.

Citations: `RPT #n` = `docs/research/arbox-reports.md` entry n. `EP` = `docs/research/arbox-endpoints.md`. `PROD` = `docs/research/arbox-product.md`. `D7-17` = write policy in `.team/decisions.md`. **(spec check)** marks a fact I read straight from `arbox-openapi.json` because the research files list only the "key fields".

## 0. Data-truth findings that drive the picks

1. **Report row ids are integers, endpoint ids are strings.** In the typed report schemas `user_id` is `integer|null` (spec check: expiring/debt/leads reports); `GET /v3/*` returns strings (EP cross-cutting fact: "requests take numbers, responses strings"). `TrialClassesReportResource.user_id` is `string|null` (spec check), so even reports disagree. Always cast.
2. **Two reports a recipe might want have no `user_id` at all:** `absenceReport` (RPT #41, spec check) and `lateCancellationReport` (RPT #35 lists `booking_id`, `membership_user_id`, no `user_id`). Any follow-up write needs a join through `GET /v3/users/searchUser?type=phone` (EP), whose phone matching is a LIVE CHECK.
3. **`expiringMembershipsReport` has no `allow_sms`/`allow_email`; `expiringSessionsReport` does** (spec check; RPT #3 and #20 key lists omit them). Consent for membership-type expiries needs a join to `GET /v3/users` (`allow_sms`, `allow_email`, EP).
4. **No report is LINKED to its schema** (RPT header: 0 LINKED, 40 INFERRED). Every recipe below carries that risk and needs the L7 probe. UNTYPED reports (`bookingsReport`, `bookingStatisticsReport`, `revenueAnalysisReport`, `activeHugimReport`, `hugim*Revenue*`, `inactiveHeadMembersReport`) are excluded from every pick.
5. **Pagination is the silent killer.** `limit` max 500, no total (EP). `classesSummaryReport` is one row per member per class (RPT #32), so a busy week overruns 500. Recipes must say "page until short page" and refuse to print totals when a cap may have hit.
6. **Money and counts are strings** (RPT quirk 6: `sessions_left`, `debt`; spec check: `price`, `paid`, `amount`). Cast, and keep the raw string in the output file.
7. **Plan gating is unknown.** PROD §1 lists reports "Basic" on Free/Basic and "Advanced" on Standard+; PROD §5 does not know which plan has API access. `docs/questions-for-arbox.md` Q1 already asks. Until answered, every recipe has an unknown availability floor.

---

## 1. Top 6 v1 recipes, ranked

Ranking logic: unambiguous fields first, seedable on the test gym second, then owner value. Drafts only for messages (D7-17).

### #1 Pack and membership expiry watch (drafts)
- **Owner pitch:** "Everyone whose pack or membership ends in the next two weeks, who has not already renewed, with a friendly message drafted for each."
- **Operations and fields:**
  - `GET /v3/reports/expiringSessionsReport` (RPT #20): `user_id`, `full_name`, `phone`, `email`, `membership_type_name`, `start_date`, `end_date`, `sessions_left` (string|null), `future_schedules`, `count_session`, `cancelled`, `cancel_reason`, `has_another_session`, `has_another_plan`, `allow_sms`, `allow_email`, `task_status` (last five spec check).
  - `GET /v3/reports/expiringMembershipsReport` (RPT #3): `membership_user_id`, `full_name`, `phone`, `email`, `membership_type_name`, `end_date`, `cancelled`, `cancel_reason`, `has_another_plan`, `has_another_session`, `price`.
  - Consent join for memberships only: `GET /v3/users` `allow_sms`, `allow_email` (EP).
  - Output only: HTML and CSV with one draft per person. No `POST /v3/message` (EP: R2, not in v1).
- **Business types:** Pilates, yoga, personal training, clinics (packs); CrossFit, gyms (monthly memberships). RPT #3/#20 list these.
- **Why it wins under this lens:** every field is a date, a count or a flag the owner can check against Arbox in seconds; `has_another_plan` / `has_another_session` remove the false positives that make renewal lists useless (RPT #3 quirk); both reports are typed (INFERRED), and no UNTYPED report is involved.
- **Biggest risk of being wrong:** what `fromDate`/`toDate` filter on is unknown (RPT shared facts), and the encoding of `cancelled` / `has_another_plan` is unknown (strings, probably '0'/'1' or yes/no, LIVE CHECK). Fallback: fetch without dates and filter `end_date` locally.
- **Eval on the test gym:** seed three memberships through the harness (`POST /v3/users/memberships`, R3 on the test gym only, EP): ends today+3 (`sessions_left` 2), +10 (`sessions_left` 9), +30; give the +10 member a second plan. Run with a 14-day window. Assert (deterministic, no model judge): drafts exist for the +3 member only; the +10 member (who has a second plan) is listed as "already renewed" with no draft; the +30 member is absent; each draft quotes that row's exact `sessions_left` and `end_date`, no `POST /v3/message` was issued, the key never appears in the transcript.

### #2 Class-fill and waiting-list view
- **Owner pitch:** "Which classes are nearly empty, which are always full, and where people are waiting."
- **Operations and fields:**
  - `GET /v3/schedule` with `from_date`, `to_date` (required) and `registration_count=1`, `waiting_list_count=1` (EP): `schedule_id`, `date`, `start_time`, `session_name`, `staff_member` (name), `max_participants`, `registration_count`, `waiting_list_count`, `cancelled_status` (all strings).
  - Optional attendance layer: `GET /v3/reports/classesSummaryReport` (RPT #32): `schedule_id`, `registration_percentage`, `check_in`, `check_in_percentage`, `standby_members`. Do not request or print `salary` (S flag).
  - Replaces the catalog's use of UNTYPED `bookingStatisticsReport` (RPT #31) and the ambiguous `GET /v3/schedule/entryFromWaitingList` (EP LIVE CHECK: current waiters or promotions).
- **Business types:** Pilates (reformer capacity), yoga, CrossFit, kids classes.
- **Why it wins:** it needs only one typed endpoint (EP: `ScheduleResource`), the arithmetic is `registration_count / max_participants`, and it does not touch any report schema mapping. It is the recipe least exposed to the L7 risk.
- **Biggest risk:** whether `registration_count` includes standby or cancelled bookings, and what `max_participants` holds for unlimited classes (null or 0). Counts are absent unless the flags are set.
- **Eval:** pick a fixture class on the test gym. Record the recipe's fill for it, call `POST /v3/schedule/bookSession` twice (EP, harness only), rerun, assert `registration_count` rose by exactly 2 and the computed fill percentage matches the arithmetic; cancel via `POST /v3/schedule/cancelUserBooking` and assert it falls by 1. Class creation needs the Arbox UI, so a standing fixture class is a prerequisite.

### #3 Payments to chase
- **Owner pitch:** "Who owes me money, for what, since when, and whose card keeps failing."
- **Operations and fields:**
  - `GET /v3/reports/debtReport` (RPT #28): `user_id`, `full_name`, `phone`, `item_name`, `status`, `price`, `debt`, `created_at`, `task_status`, `sale_person_name`.
  - `GET /v3/finance/reports/failedTransactions` (EP): `user_id`, `full_name`, `membership_user_id`, `membership_type_name`, `amount`, `last_four_digits`. No date params.
  - Optional detail: `GET /v3/reports/transactionsReport` (RPT #29): `transaction_date`, `amount`, `status`, `transaction_payment_response_code`.
  - Optional R1 follow-up: `POST /v3/tasks` (EP) one task per debtor with empty `task_status`, after chat confirmation (D7-17). Draft reminder text goes to a file; no card digits in any draft.
- **Business types:** all (RPT #28).
- **Why it wins:** read-only by default (lowest build effort), three typed sources, and both `debtReport` and `failedTransactions` carry `user_id`, so rows join cleanly. Owners care about money more than any other metric, and the numbers are verifiable against the Arbox UI.
- **Biggest risk:** meaning of `debt` (overdue vs scheduled installments) and the free-text `status` (RPT #28); how far back `failedTransactions` goes and whether resolved failures stay (EP). Sums are over strings.
- **Eval:** harness seeds `debt: 150` on a test membership (`POST /v3/users/memberships/update`, EP R3, test gym only). Assert the member appears with `debt` 150, the total equals the sum of seeded debts, drafts contain no 4-digit card number, no `POST /v3/message`, and the `S2` rows were written only to the owner's report file, not echoed in chat.

### #4 Lead and trial follow-up queue (the one R1 write recipe)
- **Owner pitch:** "New and stale leads and trial attendees who nobody has followed up, with a call task created for each after you say yes."
- **Operations and fields:**
  - `GET /v3/reports/leadsInProcessReport` (RPT #15): `user_id`, `full_name`, `phone`, `lead_status`, `lead_source`, `lead_owner_id`, `campaign`, `created_at`, `updated_at`, `task_status`, `allow_sms` (`gender`, `age` etc. exist and are not needed).
  - `GET /v3/reports/trialClassesReport` (RPT #40): `user_id`, `date`, `class_name`, `status`, `check_in`, `source_name`, `task_status`, `lost_reason_name`.
  - Lookups (EP): `GET /v3/locations` (`location_id`), `GET /v3/tasks/types` (`task_type_id`), `GET /v3/users/allStaffMembers` (`assigned_to`).
  - Write, R1, confirmed in chat with a batch preview: `POST /v3/tasks` `{location_id, task_type_id, user_id, assigned_to, description, reminder{date,time}}`. Verify with `GET /v3/tasks` (`from_date`, `to_date`).
- **Business types:** all lead-driven studios, especially with trial classes (RPT #15, #40).
- **Why it wins:** `task_status` is in both reports, so the recipe can skip leads that already have a task. That matters because EP shows no delete-task operation, so a duplicate task cannot be undone. `created_at` / `updated_at` give a stale-lead age that `GET /v3/leads` lacks (EP: no created date).
- **Biggest risk:** the encoding of `task_status`; `updated_at` is probably bumped by our own note or task, which would hide a lead from "stale" after one pass; `reminder.time` format and the `lead_owner_id` to `assigned_to` mapping are unverified (EP LIVE CHECKs).
- **Eval (best of the six):** end-to-end on the test gym with R1 only. Seed `POST /v3/leads`. Run: assert the lead is proposed and **nothing was written before confirmation**. Confirm: assert exactly one task exists via `GET /v3/tasks` for that `user_id`. Rerun: assert zero new proposals. That third step tests the idempotency we otherwise cannot rely on.

### #5 Sales snapshot (typed sources only)
- **Owner pitch:** "What I sold this week or month, what was paid, what is still owed, and which items and sources brought it."
- **Operations and fields:** `GET /v3/reports/salesReport` (RPT #30): `date`, `item_name`, `item_type`, `price`, `discount`, `paid`, `debt`, `status`, `action`, `sub_action`, `sale_person_name`, `lead_source`, `campaign_name`, `promo_code`. The same rows carry `medical_cert`, `has_waiver`, `personal_id` (H/P flags): the recipe must drop them before anything is printed or written. Reconcile one period against `GET /v3/finance/reports/sales` (EP: untyped, 31-day cap) only as a LIVE CHECK, not as a data source.
- **Business types:** all.
- **Why it wins over the catalog's idea 5:** idea 5 depends on UNTYPED `revenueAnalysisReport` and untyped finance data (RPT corrections item 6). `salesReport` is typed, and no 31-day cap is documented for it (RPT shared facts).
- **Biggest risk:** what a row is (line item or invoice) and how refunds appear (`action` / `sub_action` are free strings, RPT #30). A "revenue" total that mixes sales and refunds is wrong. Also the 500-row page cap with no cursor: a busy month spans pages and rows could shift between calls.
- **Eval:** harness seeds three memberships at price 100, 200, 300 (`POST /v3/users/memberships`, test gym), runs the recipe over the seeded date, asserts `paid` and `price` totals equal 600 (or the observed `paid` semantics), asserts H fields never appear in output files, and asserts the output states "not a profit report" and the row count.

### #6 Who's drifting (gated behind one probe)
- **Owner pitch:** "Members who used to come and have gone quiet, with no class booked, so you can reach out first."
- **Operations and fields:** `GET /v3/reports/absenceReport` (RPT #41, all 15 fields): `full_name`, `phone`, `email`, `last_seen`, `future_registration`, `latest_registration`, `memberships`, `membership_name`, `debt`, `task_status`, `allow_sms`, `allow_email`. Filter locally: `last_seen` older than N days (or null), `future_registration` empty, `membership_name` non-empty.
- **Business types:** all (RPT #41). The owner-journey flagship pain for Pilates.
- **Why it is only #6 under this lens:** (1) the report has **no `user_id`** (spec check), so any follow-up write must join by phone (`GET /v3/users/searchUser?type=phone`, EP); (2) `last_seen` is `string|null` with no stated meaning (check-in, booking, or app login?); (3) `memberships` is a nested untyped string (RPT #41).
- **Biggest risk:** `last_seen` does not mean "last attended". If it is a login or booking date, the list is wrong in a way no filter can detect.
- **Eval:** weakest of the six, because attendance cannot be seeded: the API has no check-in operation (PROD §3). Only the filter arithmetic can be tested on a fixture. Gate it on the L7 probe: compare `last_seen` for three known members to what the Arbox UI shows as their last visit, and ship only if they match. If the probe passes, this moves to #2 on owner value.

---

## 2. Three ideas from the 22 I would cut

1. **Idea 15, Schedule planner.** Its only real data source is UNTYPED `bookingStatisticsReport` (RPT #31, "the biggest blocker"), and it can only advise: the one write that would act on it is `PATCH /v3/schedule`, which changes the instructor, not the timetable (EP). Advice from unprobed data on a core decision (when to run classes) is worse than no advice. Revisit after the L7 probe, and fold into #2 if it proves out.
2. **Idea 12, Local dashboard.** It is not a recipe. It is an output format over ideas 1, 2, 3 and 5, and it inherits their untyped parts (RPT map: "inherits their U"). Ship it as an output option on each recipe ("save as a Monday page"), not as a separately tested recipe.
3. **Idea 8, Birthday and milestone messages (as written).** The milestone half rests on UNTYPED `bookingsReport` and an ASSUMED derivation from `sessionsReport` (RPT map row 8). The birthday half rests on `birthdayReport` (RPT #14), whose date filter semantics are unknown (is `fromDate` a month-day or the report date?), and it is the lowest-impact pain on the owner's list. Keep birthdays as one section of a daily briefing only if L7 clears it.

Folded rather than cut, so nothing is lost: idea 4 (waiting-list pressure) is absorbed into #2; idea 2 (weekly digest) needs untyped `bookingsReport`, so a typed "Monday page" is recipes 1 to 5 stitched together rather than its own recipe.

---

## 3. One idea nobody has proposed: "Unbooked credits"

- **Owner pitch:** "Members who still have sessions in their pack but nothing booked, so you can nudge them to book before the pack expires."
- **Operations and fields:** `GET /v3/reports/sessionsReport` (RPT #19) or `expiringSessionsReport` (RPT #20): `sessions_left`, `count_session`, `total_sessions`, `future_schedules`, `end_date`, `membership_type_name`, `allow_sms`, `allow_email`, `user_id` (spec check for the last four). Filter: `sessions_left` > 0 and `future_schedules` = 0 and `end_date` within N days or beyond. `sessionsReport` uses `name`, not `full_name` (RPT #19).
- **Why it is new:** the catalog frames every pack idea as **churn** (idea 1 drifting, idea 7 expiry). This is the **engagement** version: it targets people who are still paying and still holding credits, which is positive-tone and works before anyone is at risk. It needs no join and no UNTYPED report.
- **Business types:** Pilates, yoga, personal training, clinics, beauty (packs, RPT #19).
- **Risk:** `future_schedules` has no stated meaning (a count of future bookings? RPT #19/#20 give no definition), and `sessions_left` is `string|null`, null possibly meaning unlimited.
- **Eval:** seed a membership with `sessions_left: 5` and no bookings (test gym harness). Assert it is listed. Book one future class (`POST /v3/schedule/bookSession`). Rerun. Assert it drops off the list. That second step proves what `future_schedules` means, which is the real value of the test.
- **Relationship to #1:** same two reports and the same fetch. Build it as a second section of the expiry recipe if the lead wants fewer than seven.

---

## 4. The strongest argument against my own #1

**The expiry watch may be built for exactly the owners who do not need it, and unavailable to those who do.** PROD §2 says Arbox already offers "automated subscription renewals", booking reminders and "upsell and renewal campaigns", and PROD §1 gates "auto actions" and "email communication" to the Standard plan and above. PROD §1 and §5 also leave open which plans get API access and whether lower plans get the "Basic" reports that PROD §1 attributes to Free and Basic. So the likely situation is: owners on Standard and up have native renewal automation and gain little from a drafts-only recipe that makes them copy 30 messages by hand (v1 cannot send, D7-17); owners on Free and Basic, who lack automation and would gain most, may have no API key or no `expiring*` reports. If that holds, #1's real value is not "renewal reminders" but the narrow sliver of owners with API access and no automation, and it would be better to rank the recipes that Arbox cannot do natively at all (the queue in #4, the credits idea in section 3) above it.

**How to settle it:** `docs/questions-for-arbox.md` Q1 (which plans include API access) plus one question not yet asked: "do the `expiringSessionsReport` / `expiringMembershipsReport` reports return data on every plan?" If the answer is "API access starts at Standard", the argument bites in full and I would drop #1 to #3 and promote #4.

---

## 5. Verification and open items

- Cited from `arbox-reports.md` and `arbox-endpoints.md`: every report number and operation named above. Items marked "spec check" were read from `arbox-openapi.json` with `python3 -I` in this session: allow-field presence in the two expiring reports, `user_id` absence in `absenceReport`, `user_id` types per report, and the `trialClassesReport` field types.
- Not run: any API call. All behavior claims about `fromDate`/`toDate`, `last_seen`, `future_schedules`, `task_status`, `has_another_plan` and `debt` are LIVE CHECK, not facts.
- Eval sketches assume the test gym can be seeded with `POST /v3/users/memberships`, `POST /v3/leads` and `POST /v3/schedule/bookSession` by a harness that is allowed R2/R3 on that gym only. If the test key is read-only or seeding is refused, only #3 (read-only, with whatever debt exists) and the pure-arithmetic parts of the others can be evaluated, and the eval plan needs a standing fixture set created by hand in the Arbox UI.
