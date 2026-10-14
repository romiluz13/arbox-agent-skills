# Blind recipe picks (haiku, T5H)

Owner: Matt | Route: Plan | Phase: resolve design decisions | Author: haiku | 2026-10-14
Status: independent proposal for cross-examination. Advisory; no code, no API calls.

**Lens:** what owners actually struggle with (`docs/research/arbox-product.md` §4, `arbox-product-2.md` §1 and §3c), coverage of non-fitness operating models, and a "wow in the first 10 minutes" for a non-technical owner.

**Operating models** (from `arbox-product-2.md` §1, the four real models): **G** group classes and memberships; **A** 1:1 appointments with staff; **C** courses and workshops; **V** venue or event bookings with attendance.

**Write policy applied** (`.team/decisions.md` D7-D17): every recipe below is **R0 read-only** in v1. Outputs are a chat answer, a local HTML or CSV file, and drafts for the owner to send. No R1 writes (tasks, notes, lead status) and no R2 sends in v1. Where a recipe would naturally create tasks, that is noted as v1.1.

**Field and operation sources:** field lists come from `docs/research/arbox-reports.md` (report schemas; labels INFERRED or UNTYPED as stated there). Operation tiers come from `docs/research/arbox-endpoints.md`. Every report uses the shared `GET /v3/reports/{reportName}` parameters: `fromDate`, `toDate`, `location_id`, `limit` (max 500), `page`. No date cap is documented on that endpoint.

---

## 1. Top 6 v1 recipes, ranked

### #1 Pack and membership renewal watch (idea 7, narrowed)

- **Owner pitch:** "Who has a session pack or membership ending in the next 14 days, how many sessions are left, and who already has a renewal lined up?"
- **Operations:** `GET /v3/reports/expiringSessionsReport` and `GET /v3/reports/expiringMembershipsReport`, both R0, for the window `fromDate`..`toDate`. Optional lookup: `GET /v3/membershipTypes` to label plans.
- **Fields used:**
  - `expiringSessionsReport`: `full_name`, `phone`, `email`, `membership_type_name`, `end_date`, `sessions_left`, `future_schedules`, `count_session`, `has_another_plan`, `has_another_session`, `cancelled`, `price`, `group_leader`, `allow_sms`, `allow_email`. Typed (`ExpiringSessionsReportResource`, INFERRED by name).
  - `expiringMembershipsReport`: `membership_user_id`, `full_name`, `phone`, `membership_type_name`, `end_date`, `cancelled`, `cancel_reason`, `has_another_plan`, `price`, `location_name`. Typed (`ExpiringMembershipsReportResource`, INFERRED).
- **Output:** one list, sorted by `end_date`, with a plain-words column "sessions left" (cast `sessions_left` to number) and "renewal already in place" (`has_another_plan` or `has_another_session`). Rows where `cancelled` is set are shown in a separate "cancelled, check" section, not in the renewal list.
- **Business types served:** all four operating models. **G** monthly memberships and punch cards. **A** session packs for clinics, physiotherapists, beauty, and personal trainers. **C** course passes for tutors and kids' courses. **V** session tickets for activities. Arbox's own term is "Session Punch Card" (`arbox-product-2.md` §3e).
- **Why it beats the alternatives under this lens:**
  - "Packs about to run out" is a pick-two option for Pilates (pick (c)) and a membership-expiry option for CrossFit (pick (d)) in `owner-journey.md` §3. These are options we wrote, not owner-validated pains; the first live owner interview should confirm them.
  - It is the only recipe that gives a per-person pack balance. `arbox-endpoints.md` (lookup chain 3) says the memberships list has no sessions-left, and "a pack balance needs a report". This recipe is that report.
  - A weekly digest (idea 2) gives totals. This gives names and a next action.
- **Biggest risk of being wrong:** `sessions_left` is `["string","null"]` in every session report (`arbox-reports.md` quirk 6). A `null` could mean "unlimited", "not set", or "zero", and the spec does not say which. Showing "0 left" for an unlimited pack would send a wrong renewal message. The two reports also overlap for the same person (a pack and a time plan), so the recipe must not count one person twice.
- **How an eval proves it works (test gym, deterministic asserts):**
  1. Row count per report equals the count shown in Arbox's own expiring view for the same window. Exact match, or the recipe fails.
  2. A seeded pack with exactly 1 session left and no second plan must appear with "sessions left = 1" and "renewal in place = no".
  3. A member with `has_another_plan` set must not appear in the "needs renewal" section.
  4. A cancelled membership must appear only in the "cancelled, check" section.
  5. For every `sessions_left` value, the recipe prints the raw string next to the parsed number, so a `null` is visible and never shown as 0.

### #2 No-show and late-cancel watch (idea 13, with the penalty rule as the threshold)

- **Owner pitch:** "Who booked and didn't come, or cancelled too late, in the last 30 days, and who has crossed the penalty line?"
- **Operations:** `GET /v3/reports/lateCancellationReport`, `GET /v3/reports/bookingCancellationReport`, `GET /v3/reports/absenceReport`. All R0, same date window.
- **Fields used:**
  - `lateCancellationReport`: `full_name`, `phone`, `session_name`, `membership_type_name`, `staff_member`, `start_time`, `cancelled_time`, `hours_before`, `cancelled_by`, `entered_from_standby`, `booking_id`, `location_name`, `allow_sms`. Typed.
  - `bookingCancellationReport`: `user_id`, `full_name`, `class_name`, `date`, `start_time`, `booking_time`, `cancelled_time`, `hours_before`, `cancelled_by`. Typed.
  - `absenceReport`: `full_name`, `phone`, `last_seen`, `future_registration`, `debt`, `membership_name`. Typed, and the no-show proxy (INFERRED: the spec does not define "absence").
- **Output:** per member: count of late cancels, count of cancels overall, count of absences, last event. A member is flagged when they reach the studio's own rule. The Arbox Penalties example is "two absences in seven days" (`arbox-product-2.md` §3d). The recipe uses that as the default and asks the owner to confirm it.
- **Business types served:** strongest in **A** (1:1 appointments: clinics, physiotherapists, beauty, personal trainers, tutors), where a missed slot cannot be resold. Also **G** and **C**.
- **Why it beats the alternatives under this lens:**
  - Late cancellations and no-shows are pick-two options for Pilates (e) and PT (b) in `owner-journey.md` §3, so they are our hypothesis, not validated pains. Arbox's own copy says it aims to "minimize no-shows and cancellations" (`arbox-product.md` §2, marketing), which is the vendor's view of the same pain.
  - Penalties exist in Arbox but only when the owner sets them up and only as an app block or a shortened membership (`arbox-product-2.md` §3d). This recipe shows the pattern for owners who have not set penalties, and shows who is near the line before it is enforced.
- **Biggest risk of being wrong:** `absenceReport` is the only no-show source, and the spec does not say it means "no-show". It may include members who were never booked. The late-cancel rule is set per event (`arbox-product-2.md` §3d, "set in each event's schedule rules"), so `hours_before` must be compared with the event's own rule, not a global number. If the owner already has penalties enabled, the report shows the outcome of blocks the owner already knows about.
- **How an eval proves it works:**
  1. Seed one member with two late cancels and one with a no-show on the test gym. Both must reach the flag threshold.
  2. Every late cancel in `lateCancellationReport` must also appear in `bookingCancellationReport` (subset check). A late cancel missing from the all-cancels list is a failure.
  3. Each flagged row shows `hours_before` next to the event's own cancel-window setting, read from Settings. If they disagree, the row is marked "rule unclear", not flagged.
  4. Spot-check one absence in the UI against `absenceReport`'s `last_seen`.

### #3 Who's drifting, regulars who went quiet (idea 1)

- **Owner pitch:** "Members who used to come every week and haven't been in for three weeks, with the class they used to take and a draft message to each one."
- **Operations:** `GET /v3/reports/regularsReport` (the weekly slot each regular holds), then `GET /v3/reports/absenceReport` (the last visit). Both R0. Optional: `GET /v3/users/searchUser` for a single lookup.
- **Fields used:**
  - `regularsReport` (typed, all 14 fields): `user_id`, `full_name`, `phone`, `day_of_week`, `start_time`, `class_name`, `series_name`, `staff_member`, `membership_status`, `location_name`.
  - `absenceReport` (typed, all 15 fields): `full_name`, `phone`, `email`, `last_seen`, `future_registration`, `latest_registration`, `membership_name`, `debt`, `allow_sms`, `allow_email`.
- **Output:** a list of regulars with `last_seen` older than the threshold (default 21 days, the owner-journey default) and no `future_registration`. Each row carries the consent flags. Drafts are written only for rows where the channel is allowed (`allow_sms` or `allow_email` is "yes").
- **Business types served:** **G** (weekly classes), **C** (weekly courses, `series_name`), **A** (recurring weekly appointments: physiotherapy, personal training, tutoring), and beauty repeat clients (INFERRED).
- **Why it beats the alternatives under this lens:**
  - Drifting members is the most-cited retention option in `owner-journey.md` §3 (Pilates and yoga pick-two menus). Still our hypothesis until an owner confirms it.
  - `absenceReport` alone lists everyone who is quiet, including people who were never regular. Joining it with `regularsReport` is what makes the list about *lost* regulars, which is the owner's actual question.
  - It is a single join with two typed reports, so it is cheap to run and easy to check.
- **Biggest risk of being wrong:** the definition of "regular". `regularsReport` has no cut-off, so "was a regular" is a judgment that the spec does not give. `last_seen` is also undefined. If `last_seen` counts a booking and not an attendance, a member who booked and didn't come looks active. Also, Arbox already shows "clients at risk: not visited or bought from shop recently" in its reports (`arbox-product-2.md` §3c). An owner who already uses that view gets little from this list.
- **How an eval proves it works:**
  1. Pick five members known to have lapsed (seeded or known to the owner). All five must appear.
  2. Pick five current regulars with a booking next week. None may appear.
  3. A member with `future_registration` set must not appear, whatever their `last_seen`.
  4. No row may appear in a draft file without an allowed channel flag.
  5. The recipe's count matches the owner's own count within a stated tolerance, checked once on the test gym.

### #4 Payments to chase and failed charges (idea 6)

- **Owner pitch:** "Who owes money, and whose recurring charge failed this month, in one list, with the amounts."
- **Operations:** `GET /v3/reports/debtReport` (R0) and `GET /v3/reports/transactionsReport` (R0), same window. The finance `failedTransactions` endpoint is an alternative to the second report; it is not a report name, so it is not used here.
- **Fields used:**
  - `debtReport` (typed, 17 fields; list uses `user_id`, `full_name`, `phone`, `email`, `item_name`, `status`, `price`, `debt`, `created_at`, `sale_person_name`, `location_name`, `task_status`).
  - `transactionsReport` (typed, 21 fields; list uses `transaction_id`, `transaction_date`, `full_name`, `phone`, `item_name`, `type`, `amount`, `payments_number`, `status`, `transaction_payment_response_code`, `location_name`). `last_four_digits` is present but is never printed.
- **Output:** one list sorted by `debt`, then a second list of failed transactions. A member appearing in both is marked once, with both facts.
- **Business types served:** all four models. **G** and **C** recurring memberships are the main source. **A** and **V** matter where packs are billed in installments (`payments_number`).
- **Why it beats the alternatives under this lens:**
  - Payments are a documented owner complaint: reviewers wrote about manual card entry and "payment and finance gaps" (`arbox-product.md` §4, Capterra, about 4 reviews).
  - Arbox says a declined recurring charge creates a debt and can block the client from booking (`arbox-product-2.md` §3f). An owner needs to see those blocked clients; the app shows them one at a time.
- **Biggest risk of being wrong:** Arbox already sends automatic overdue reminders and a failed-transaction message to the client (`arbox-product-2.md` §2b, §3f). A recipe that lists the same people can duplicate automation the owner already runs. The `status` and `transaction_payment_response_code` values are untyped, so "failed" must be confirmed against the UI before a row is labelled failed. `debt` type is not checked here (`arbox-reports.md` does not type it).
- **How an eval proves it works:**
  1. Seed one declined recurring charge (test card) and one open debt on the test gym. Both must appear with amounts equal to the UI.
  2. The total of `debt` across the list equals the debt total shown in Arbox for the same filter, to the cent.
  3. The recipe prints no `last_four_digits`, and no full card number, in any output file. Checked by grep on the generated file.
  4. A paid-off debt does not appear.

### #5 Waiver and health-form chaser (idea 16)

- **Owner pitch:** "New clients who haven't signed the waiver or health form yet, before their first session."
- **Operations:** `GET /v3/reports/signedFormsReport` (R0), `GET /v3/digitalForms` (R0, `form_id`, `name`, `active`; do not load `content` into chat, it can be large), and `GET /v3/reports/membersPropertiesReport` (R0, for the presence flags only).
- **Fields used:**
  - `signedFormsReport` (typed, 17 fields): `user_id`, `form_id`, `full_name`, `phone`, `status`, `sign_date`, `type`, `exp_date`, `sent_by`, `allow_email`, `allow_sms`, `lead_owner`.
  - `GET /v3/digitalForms`: `form_id`, `name`, `version`, `active` (`arbox-endpoints.md`).
  - `membersPropertiesReport` (typed as `MembersPropertiesReportSource`, INFERRED by a fuzzy name): `has_waiver`, `medical_cert`, `has_insurance`. Presence only. `injury` is excluded (`arbox-reports.md` H flag; owner-journey Q5 default).
- **Output:** new members in the last 14 days (window on the member's creation) with no signed form of each active type. The owner decides what "new" means; the default is 14 days.
- **Business types served:** **V** (activities: waivers are the only form type the activities page names, `arbox-product-2.md` §1), **A** (clinics: health forms with e-signature, `wellness` page), **G** (CrossFit and gym health declarations). Beauty patch and consent forms are INFERRED only.
- **Why it beats the alternatives under this lens:**
  - Forms are the gate before the first session, so a missing form is a concrete problem on a specific day. A digest hides it. The activities and clinic pages both name digital forms as a feature (`arbox-product-2.md` §1).
  - It covers the verticals with the weakest product coverage (activities, clinics) better than any fitness-specific idea.
- **Biggest risk of being wrong:** `signedFormsReport` has a free-string `type` and does not say which form each row is for, so "no waiver signed" can only be inferred from `has_waiver` and the form list. `medical_cert` is a string in the spec, not a boolean, so presence parsing must be checked. Health-related fields are present, so the output must be held to the flag rules.
- **How an eval proves it works:**
  1. Seed one new test member with no form and one with a signed form. The first appears, the second does not.
  2. Every `type` value in `signedFormsReport` on the test gym matches a `name` in `GET /v3/digitalForms`, or the recipe says "unmatched type" and does not guess.
  3. The output contains booleans and dates for health fields only, checked by a grep of the generated file for `injury` and the values of `medical_cert`.

### #6 New-lead and trial follow-up list, read-only (ideas 9 and 10, without writes)

- **Owner pitch:** "Every lead and trial guest from the last 14 days, where they are in the funnel, and which trials didn't turn into members."
- **Operations:** `GET /v3/reports/leadsInProcessReport` (R0), `GET /v3/reports/trialClassesReport` (R0), and `GET /v3/reports/convertedLeadReport` (R0) for the conversion share. Lookup: `GET /v3/statuses`, `GET /v3/sources` (untyped; read as strings).
- **Fields used:**
  - `leadsInProcessReport` (typed, 22 fields): `user_id`, `full_name`, `phone`, `email`, `lead_status`, `lead_source`, `lead_owner`, `campaign`, `created_at`, `updated_at`, `task_status`, `location_name`, `allow_sms`.
  - `trialClassesReport` (typed, 33 fields): `user_id`, `full_name`, `phone`, `date`, `class_name`, `status`, `days_passed`, `source_name`, `campaign`, `check_in`, `lead_owner`, `lost_reason_name`.
  - `convertedLeadReport`: `created_at`, `converted_at`, `lead_source`, `campaign`, `active`.
- **Output:** a funnel list, grouped by stage (new, in process, trial booked, trial attended, not converted). The conversion share per source is a second table.
- **Business types served:** **A** (consultations for clinics, beauty, tutors), **G** and **C** (trial classes, yoga and CrossFit intro offers), and **V** where trials are a demo session.
- **Why it beats the alternatives under this lens:**
  - Arbox's gym page pitches its sales pipeline as "replacing spreadsheets" (`arbox-product-2.md` §1, gym row), so the vendor assumes leads are tracked in spreadsheets today. We have no owner evidence yet.
  - Arbox's Growth reports already show counts (`arbox-product-2.md` §3c). This recipe adds the per-person list, which is what an owner acts on.
  - Keeping it read-only fits the write policy. The follow-up task (idea 9) is R1, so it moves to v1.1.
- **Biggest risk of being wrong:** the recipe would like to say "not contacted yet", but no report carries a last-contact field. `task_status` is the nearest signal and its values are not documented. `lead_status` and `status` are free strings in the spec, and `GET /v3/statuses` is untyped. If "not contacted" is shown as a fact, the owner will trust a signal the data does not hold.
- **How an eval proves it works:**
  1. Seed three test leads: one with an open task, one with a closed task, one with a trial booked. Each must land in the right stage.
  2. The recipe's "not contacted" label is shown only when `task_status` has a documented meaning. Until confirmed on the test gym, the column is labelled "task status (raw)".
  3. The count of trial guests who did not convert equals the owner's count in the UI.

---

## 2. Three ideas from the 22 that I would cut entirely

1. **#2 Weekly studio digest.** It depends on `bookingsReport`, which is UNTYPED in `arbox-reports.md`, and on `salesReport` and `classesSummaryReport` for totals. A digest is a summary of numbers the owner has to act on anyway, so it gives an answer but no next step. The owner-journey catalog also marks it as "all" in fit, which I do not believe for the 1:1 verticals. Cut for v1; revisit once `bookingsReport` is probed.
2. **#15 Schedule planner.** It depends on `bookingStatisticsReport`, which is UNTYPED, and it produces advice ("add a 7am on Tuesday") from one to two weeks of data. There is no eval oracle for whether the advice is right, so the recipe cannot be checked the way the other five can. It also needs `PATCH /v3/schedule` for any change, which is R2 and out of v1. Cut.
3. **#14 Coach load and popularity.** The spec's `classesSummaryReport` carries a `salary` field, and `employeeAttendanceReport` is staff clock-in and clock-out data (`arbox-reports.md`, S flags). The owner-journey already excludes salary by default, which leaves little of the recipe. The owner pain is not documented in the product research for any vertical except the beauty commission angle, which the spec does not expose cleanly. Cut for v1 for privacy and evidence reasons.

---

## 3. One idea nobody has proposed yet

**New-member first 30 days (intro-offer retention).**

- **Owner pitch:** "Of the people who joined or bought in the last 30 days, who hasn't come back, so I can reach them while they are still deciding."
- **Operations:** `GET /v3/reports/salesReport` (R0, `fromDate` = 30 days ago), joined on `full_name` or `user_id` to `GET /v3/reports/absenceReport` (R0) for `last_seen`. Optional: `GET /v3/reports/activeMembershipsReport`.
- **Fields used:** `salesReport`: `date`, `full_name`, `item_name`, `item_type`, `membership_type_internal_name`, `price`, `discount`, `promo_code`, `start_date`, `lead_source`, `campaign_name`. `absenceReport`: `last_seen`, `future_registration`, `allow_sms`, `allow_email`.
- **Business types served:** the owner-journey's own Round 2 picks name this pain for **G** (yoga intro-offer buyers who don't come back, `owner-journey.md` §3 yoga branch) and CrossFit (members quitting around month 3). It also applies to **C** (course starts) and to **A** when a first visit is a consult.
- **Why it's new and why it matters:** none of the 22 ideas looks at people in their first 30 days. Idea 1 (drifting) catches only those already regular. The owner-journey Round 2 table lists intro-offer buyers (yoga) and month-3 quits (CrossFit) as pick-two options, so the 22 leave two of our own listed pains unserved. These are still hypotheses, so the first owner interview should test them before this recipe is built.
- **Biggest risk:** `promo_code` and `item_type` vocabularies are not documented, so "intro offer" cannot be recognised by a field until the test gym shows what the values look like. `last_seen` is undefined (same risk as #3). The join key between the two reports is not stated in the spec; `full_name` is not unique.
- **Eval:** seed two test purchases after the window start, one with a visit and one without. The second must be flagged. Confirm the join key on the test gym; if only names are shared, the recipe reports "possible duplicates" and does not merge them silently.

---

## 4. Strongest argument AGAINST my #1 (pack and membership renewal watch)

Arbox's own reporting already has a retention group that includes "memberships expiring without renewal" and lets the owner message clients straight from the report (`arbox-product-2.md` §3c). For owners who use that view, my recipe is a duplicate: an export and a draft, not a new decision.

What the recipe adds is pack balance, and that depends on `sessions_left`, which is `["string","null"]` in five session reports and has not been probed on a real account. If the field is unreliable, the recipe's main value (who has one session left) is wrong, and the owner would be better served by the native view they already have. The honest test is therefore not "does the list look right" but "does the list agree with the native Arbox view for the same window, row for row". If it does not, the recipe should be cut, not patched.
