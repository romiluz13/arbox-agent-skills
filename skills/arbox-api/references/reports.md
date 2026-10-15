# Arbox API: reports (`GET /v3/reports/{reportName}`)

All 47 `reportName` values for the single report endpoint. Each entry gives the owner question, the mapping label, the key fields, flags and the business types that care.

Tier key: **R0** read-only (every report is R0). Data key: **S1** contact data; **S2** health, finance or staff-private fields inside the row. Flags below mark which fields need the privacy defaults.

## Contents

- [activeMembersReport](#activemembersreport)
- [inactiveMembersReport](#inactivemembersreport)
- [expiringMembershipsReport](#expiringmembershipsreport)
- [expiredMembershipsReport](#expiredmembershipsreport)
- [canceledMembershipsReport](#canceledmembershipsreport)
- [membersOnHoldReport](#membersonholdreport)
- [membersPropertiesReport](#memberspropertiesreport)
- [restrictedMembersReport](#restrictedmembersreport)
- [transparentMembershipsReport](#transparentmembershipsreport)
- [transparentSessionsReport](#transparentsessionsreport)
- [renewalsReport](#renewalsreport)
- [futureMembershipsReport](#futuremembershipsreport)
- [allClientsReport](#allclientsreport)
- [birthdayReport](#birthdayreport)
- [leadsInProcessReport](#leadsinprocessreport)
- [allLeadsReport](#allleadsreport)
- [lostLeadsReport](#lostleadsreport)
- [convertedLeadReport](#convertedleadreport)
- [sessionsReport](#sessionsreport)
- [expiringSessionsReport](#expiringsessionsreport)
- [expiredSessionsReport](#expiredsessionsreport)
- [activeMembershipsReport](#activemembershipsreport)
- [futureSessionsReport](#futuresessionsreport)
- [groupMembersCoordinatorReport](#groupmemberscoordinatorreport)
- [inactiveHeadMembersReport](#inactiveheadmembersreport)
- [regularsReport](#regularsreport)
- [signedFormsReport](#signedformsreport)
- [debtReport](#debtreport)
- [transactionsReport](#transactionsreport)
- [salesReport](#salesreport)
- [bookingStatisticsReport](#bookingstatisticsreport)
- [classesSummaryReport](#classessummaryreport)
- [cancelledSessionsReport](#cancelledsessionsreport)
- [bookingCancellationReport](#bookingcancellationreport)
- [lateCancellationReport](#latecancellationreport)
- [bookingsReport](#bookingsreport)
- [attendanceExternalMembersReport](#attendanceexternalmembersreport)
- [employeeAttendanceReport](#employeeattendancereport)
- [staffActionsReport](#staffactionsreport)
- [trialClassesReport](#trialclassesreport)
- [absenceReport](#absencereport)
- [entranceReport](#entrancereport)
- [hugimBookingReport](#hugimbookingreport)
- [activeHugimReport](#activehugimreport)
- [hugimRevenueReport](#hugimrevenuereport)
- [hugimRevenueByReceiptReport](#hugimrevenuebyreceiptreport)
- [revenueAnalysisReport](#revenueanalysisreport)

## How to call

`GET /v3/reports/{reportName}` · Tier R0 · Data varies by report

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports

- Path `reportName` (required): one of the 47 names listed below.
- Optional query: `fromDate`, `toDate` (camelCase; the spec gives no format, while other endpoints use `Y-m-d`, so confirm with one live call), `location_id`, `limit` (max 500), `page`, and the filters in *Shared facts*.
- Example: `GET /v3/reports/absenceReport?fromDate=2026-09-14&toDate=2026-10-14&group_by=user&limit=500&page=1` (`absenceReport` requires `group_by`; the window is within the 31-day cap)
- Response: envelope `{statusCode, data[], extra[]}`. The 200 schema is an untagged union with no discriminator, so the item shape comes from the name-to-schema mapping label in each entry, not from the response.
- No total or next-page field. A short or empty page is the only end signal.
- `reportName` is also repeated as an optional query parameter. Send it once, in the path.

## Server also accepts (not in the spec's 47)

Checked live on 2026-10-15 on a test gym. The server's own `reportName` list (from its 400 message) has 53 names: the spec's 47 plus these seven. Their parameters are not verified, so they are UNDOCUMENTED here and no entry is written for them:

- `activeMembers`
- `activePlanMembers`
- `activeSessionMembers`
- `externalMembershipsReport`
- `getMissingMembers`
- `shiftSummaryReport`
- `workshopsBookingReport`

What the server did with them: each name passes the name check. Without parameters, six return 400 asking for dates (`getMissingMembers` asks only for `fromDate`). With dates, five of them return HTTP 500 "An unexpected server error occurred." (`getMissingMembers` returned the same 500 with `fromDate` only). `workshopsBookingReport` returns that 500 with no parameters. Treat these seven as unavailable until a later check gets a 200.

`revenueAnalysisReport` is in the spec's 47, but the server refuses it (400 "reportName must be one of ..."). Do not use it.

## Shared facts

**Query parameters.** The spec gives all 47 the same parameter list. It does not say which parameters apply to which report, so per-report applicability is UNKNOWN. Likely-relevant parameters are marked INFERRED in each entry.

| Param | Type | Notes |
|---|---|---|
| `reportName` | path, required, enum of 47 | Also repeated as an optional query param (duplicate name, see Quirks) |
| `fromDate`, `toDate` | string, camelCase, no `format` | Date filter. Description says only "FromDate"/"ToDate". A 31-day cap is observed on several reports (see *Date-range caps*) |
| `location_id` | integer | Location filter |
| `user_id` | integer | Member filter |
| `membership_type_id` | integer | Membership type filter |
| `status`, `status_id` | string / integer | Status filters. Values not documented |
| `source_id`, `lost_reason_id`, `sale_person_id`, `assignee_id`, `coach_id`, `box_category_id`, `space_id` | integer | Entity filters |
| `type` | string | Not documented in the spec. Observed on `bookingStatisticsReport` only, which accepts two values (see its entry) |
| `sessions_left` | integer | Filter by remaining sessions |
| `group_by` | string enum: `membership_user`, `membership_user_fk`, `user`, `user_fk` | Grouping. Which reports honor it: UNKNOWN |
| `hideFutureCancel`, `hideHold` | string enum `"0"` / `"1"` | Example `"1"` |
| `success` | string enum `"0"` / `"1"` | Not described. Probably irrelevant to reports (it appears to be a shared parameter) |
| `page`, `limit`, `sort` | integer, integer (max 500), `asc`/`desc` | Pagination. Response has no total or next-page field |

**Required parameters:** the path `reportName`, plus whatever the entry's Params line says. Several reports need dates (observed 2026-10-15: `absenceReport`, `allLeadsReport`, `bookingsReport`, `bookingStatisticsReport`, `classesSummaryReport`, `expiredMembershipsReport`, `expiringMembershipsReport`, `expiringSessionsReport`, `hugimRevenueReport`, `hugimRevenueByReceiptReport`, `inactiveMembersReport`, `convertedLeadReport`, `lostLeadsReport`, `salesReport`, `trialClassesReport`; without them, HTTP 400). `signedFormsReport` needs `toDate`. The spec does not say which reports need what.

**Date-range caps:** the spec states the 31-day cap on four finance GETs only (invoices, receipts, cashFlow, sales; see `finance.md`). On 2026-10-15 the reports also refused windows over 31 days, with the same message ("The date range should not exceed 31 days."): `birthdayReport` (a full year), `salesReport` (60 days), `lateCancellationReport` (60 days), `trialClassesReport` (44 days), `absenceReport` (90 days); the membership reports too (field report, 2026-10-15). Keep every report window at 31 days or less. Reports not listed here were not tested beyond 31 days. Live results: `docs/plan/live-check-results.md`.

**Responses:** 200, 404, 422. No error schema. `data` is always an array, even for single-object cases.

**Flag values:** string flags come back as `"yes"`/`"no"` on a live account (`has_waiver`, `cancelled`, `has_another_plan`, `has_another_session`, `future_registration`), not `"true"`/`"false"` or `"0"`/`"1"` (field report, 2026-10-15). Recipes read them with one rule: `skills/arbox-recipes/references/fields.md`.

**One call at a time:** two parallel calls with the same key got HTTP 429 "concurrent requests not allowed" (field report, 2026-10-15). The helper retries a read after a short wait; run calls one after another.

**Flags used in the field lists**
- **P**: personal data. Names, contact details, age, gender, birthday, address, national ID (`personal_id`).
- **H**: health or injury. `injury`, `medical_cert`, `has_insurance`, `has_waiver` (waiver is a form, usually a health declaration).
- **F**: money. Price, paid, debt, refund, LTV, card last four.
- **S**: staff-private. Salary, staff clock-in/out, staff audit logs. Staff are not the owner's customers, and some of this is labor-law-sensitive.
- **A**: physical access or presence log. Entry gate and entry/exit times.

**Default exclusions:** `injury`, `medical_cert`, waiver `medical`, `salary` and staff pay stay out of outputs unless the owner asks for them.

## activeMembersReport

- **Schema:** `ActiveMembersReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 28): `full_name`, `user_type`, `email`, `phone`, `age`, `gender`, `created_at`, `active_memberships_count`, `future_memberships_count`, `union_name`, `location_name`, `lead_owner`, `allow_sms`, `allow_email`, `custom_field_value`.
- **Flags:** P.
- **Owner question:** "Who is an active member right now, and how many plans does each hold?"
- **Business types:** all.
- **Quirks:** `union_name`/`union_id` (meaning unclear, possibly a membership group). `active_memberships_count` is the strongest filter for "active".

## inactiveMembersReport

- **Schema:** `InactiveMembersReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate`. Date cap: 31-day windows accepted; longer windows not tested.
- **Key fields** (15 of 30): `full_name`, `user_type`, `email`, `phone`, `inactive_from`, `active_memberships_count`, `future_memberships_count`, `active_charges`, `created_at`, `age`, `gender`, `lead_owner`, `location_name`, `allow_sms`, `allow_email`.
- **Flags:** P, F (`active_charges`).
- **Owner question:** "Which members no longer have an active membership, and since when?"
- **Business types:** all.
- **Quirks:** `inactive_from` is the only date that dates the lapse. Not the same as "not visited recently", which is `absenceReport`.

## expiringMembershipsReport

- **Schema:** `ExpiringMembershipsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate`, which filter on `end_date`. Date cap: 31 days (field report, 2026-10-15).
- **Key fields** (15 of 24): `full_name`, `phone`, `email`, `membership_type_name`, `membership_user_id`, `start_date`, `end_date`, `price`, `cancelled`, `cancel_reason`, `has_another_session`, `has_another_plan`, `group_leader`, `location_name`, `lead_owner`.
- **Flags:** P, F.
- **Owner question:** "Whose time-based membership ends soon, and has it already been cancelled?"
- **Business types:** fitness, Pilates, yoga, clinic (monthly plans), beauty (monthly plans).
- **Quirks:** `has_another_plan` / `has_another_session` tell you whether a renewal is already in place. Use them before drafting a renewal message. They and `cancelled` are `"yes"`/`"no"` (field report, 2026-10-15).

## expiredMembershipsReport

- **Schema:** `ExpiredMembershipsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate` (400 without them), which filter on `end_date`. Date cap: 31 days (field report, 2026-10-15).
- **Key fields** (15 of 28): `full_name`, `phone`, `email`, `membership_type_name`, `membership_user_id`, `start_date`, `end_date`, `ending_reason`, `client_status`, `price`, `active_charges`, `ltv`, `lead_owner`, `location_name`, `task_status`.
- **Flags:** P, F (`ltv`, `active_charges`).
- **Owner question:** "Which memberships ended, why did they end, and did they owe money?"
- **Business types:** all.
- **Quirks:** `ending_reason` is free text in practice (not enumerated in the spec).

## canceledMembershipsReport

- **Schema:** `CanceledMembershipsReportResource`. INFERRED (exact; spelling matches "canceled" in both).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 25): `full_name`, `phone`, `email`, `membership_type_name`, `purchase_date`, `end_date`, `cancelled_time`, `cancel_reason`, `cancelled_by`, `comment`, `refund`, `sale_person_name`, `active`, `location_name`, `lead_owner`.
- **Flags:** P, F (`refund`). **`comment` is free text and may hold health or personal notes.** Treat it as sensitive unless the owner says otherwise.
- **Owner question:** "Who cancelled their membership, when, why, and did they get a refund?"
- **Business types:** all.
- **Quirks:** That is wrong: the schema is typed. Only the enum-to-schema link is INFERRED.

## membersOnHoldReport

- **Schema:** `MembersOnHoldReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 17): `full_name`, `phone`, `user_id`, `membership_user_id`, `membership_hold_id`, `membership_type_name`, `start_suspend_time`, `end_suspend_time`, `total_days`, `suspend_reason`, `start_membership_time`, `end_membership_time`, `price`, `task_status`, `location_name`.
- **Flags:** P, F (`price`).
- **Owner question:** "Who has paused their membership, and when does the pause end?"
- **Business types:** all.
- **Quirks:** `suspend_reason` is free text in practice.

## membersPropertiesReport

- **Schema:** `MembersPropertiesReportSource`. INFERRED (**fuzzy**: the schema ends `Source`, not `Resource`; the only such name in the union).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 31): `full_name`, `gender`, `age`, `personal_id`, `membership_type_name`, `department_name`, `has_waiver`, `medical_cert`, `has_insurance`, `restricted`, `injury`, `has_image`, `allow_sms`, `allow_email`, `custom_field_value`.
- **Flags:** P (`personal_id`, `age`, `gender`), **H** (`injury`, `medical_cert`, `has_insurance`, `has_waiver`).
- **Owner question:** "Which member profiles are incomplete (no waiver, no medical certificate, no insurance, no photo)?"
- **Business types:** fitness and clinic most of all (medical certs and waivers). Beauty partly (has_image).
- **Quirks:** the `Source` suffix is the only one in the union. Probably a typo in the spec for `Resource`, but it cannot be confirmed.

## restrictedMembersReport

- **Schema:** `RestrictedMembersReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (all 7): `user_id`, `full_name`, `first_name`, `last_name`, `email`, `phone`, `last_seen`.
- **Flags:** P.
- **Owner question:** "Which members are restricted (blocked from booking or entering), and when were they last seen?"
- **Business types:** all.
- **Quirks:** the spec does not say what "restricted" means (manual ban, debt, injury, or a waiver rule). The schema body has `restricted` and `restricted_time` on `MembersPropertiesReport`, so the flag exists on the profile. Meaning of the reason: UNKNOWN.

## transparentMembershipsReport

- **Schema:** `TransparentMembershipsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 23): `user_id`, `full_name`, `user_role`, `email`, `phone`, `department_name`, `membership_type_name`, `status`, `price`, `paid`, `start_date`, `end_date`, `created_at`, `location_name`, `city`.
- **Flags:** P, F.
- **Owner question:** UNKNOWN. The spec does not define "transparent". Meaning: UNKNOWN; ask Arbox before writing a recipe.
- **Business types:** UNKNOWN.
- **Quirks:** the name is not defined anywhere in the spec.

## transparentSessionsReport

- **Schema:** `TransparentSessionsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 21): `user_id`, `name`, `email`, `phone`, `department_name`, `membership_type_name`, `status`, `price`, `paid`, `start_date`, `end_date`, `sessions_left`, `future_schedules`, `count_session`, `lead_owner`.
- **Flags:** P, F.
- **Owner question:** UNKNOWN (same as #9, but for session packs).
- **Business types:** UNKNOWN.
- **Quirks:** uses `name`, not `full_name`. Same undefined "transparent" concept.

## renewalsReport

- **Schema:** `RenewalsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 16): `user_id`, `full_name`, `first_name`, `last_name`, `email`, `phone`, `membership_type_name`, `created_at`, `referrer`, `sale_person_name`, `location_name`, `lead_owner`, `lead_owner_id`, `allow_sms`, `allow_email`.
- **Flags:** P. Exclude `personal_id`.
- **Owner question:** "Who renewed their membership, on which plan, and who sold it?"
- **Business types:** all.
- **Quirks:** the rows look like new purchase records (`created_at`, `referrer`, `sale_person_name`), which may mean the report lists renewal sales rather than renewal status. INFERRED from field set; confirm with a live call.

## futureMembershipsReport

- **Schema:** `FutureMembershipsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 24): `user_id`, `full_name`, `email`, `phone`, `department_name`, `membership_type_name`, `membership_status`, `price`, `debt`, `start_date`, `end_date`, `created_at`, `location_name`, `lead_owner`, `allow_sms`.
- **Flags:** P, F (`price`, `debt`).
- **Owner question:** "Which memberships start later, and which of those already owe money?"
- **Business types:** all.
- **Quirks:** none beyond the shared ones.

## allClientsReport

- **Schema:** `AllClientsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (all 14): `user_id`, `full_name`, `first_name`, `last_name`, `email`, `phone`, `gender`, `age`, `created_at`, `location_name`, `address`, `allow_email`, `allow_sms`, `last_purchase`.
- **Flags:** P (`address`, `age`, `gender`). Largest personal-data report.
- **Owner question:** "Give me every client, with their last purchase date."
- **Business types:** all.
- **Quirks:** `last_purchase` is the only "activity" field here. Use `absenceReport` for attendance.

## birthdayReport

- **Schema:** `BirthdayReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required parameters: not tested without dates. Date cap: 31 days (observed 2026-10-15: a full-year window returned 400).
- **Key fields** (15 of 16): `user_id`, `full_name`, `first_name`, `last_name`, `birthday`, `age`, `status`, `user_role`, `phone`, `email`, `allow_sms`, `allow_email`, `location_name`, `lead_owner`, `lead_owner_id`. Exclude `personal_id`.
- **Flags:** P (`birthday`, `age`).
- **Owner question:** "Whose birthday is coming up so I can send a wish?"
- **Business types:** all.
- **Quirks:** the spec does not say whether `fromDate`/`toDate` filter by birthday (month-day) or by the report date. Confirm with a live call. The `allow_*` fields are the consent gate for any message.

## leadsInProcessReport

- **Schema:** `LeadsInProcessReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 23): `user_id`, `full_name`, `email`, `phone`, `lead_status`, `lead_source`, `lead_owner`, `lead_owner_id`, `campaign`, `created_at`, `updated_at`, `task_status`, `city`, `location_name`, `allow_sms`.
- **Flags:** P.
- **Owner question:** "Which leads are open right now, at what stage, and who owns them?"
- **Business types:** all, especially fitness and beauty (lead-driven sales).
- **Quirks:** `user_id` here is the lead's id.

## allLeadsReport

- **Schema:** `AllLeadsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate` (400 without them) (field report, 2026-10-15). Date cap: not tested beyond 31 days.
- **Key fields** (15 of 21): `user_id`, `full_name`, `email`, `phone`, `status`, `lead_source`, `created_at`, `updated_at`, `trial_class`, `lead_owner`, `campaign`, `task_status`, `location_name`, `allow_sms`, `lost_reason_name`.
- **Flags:** P.
- **Owner question:** "Every lead we have, its status and where it came from."
- **Business types:** all.
- **Quirks:** `status` is free text here, but the lead-statuses operation (`GET /v3/statuses`) exists. Check that the values match.

## lostLeadsReport

- **Schema:** `LostLeadsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate` (400 without them) (field report, 2026-10-15). Date cap: not tested beyond 31 days.
- **Key fields** (15 of 18): `lead_id`, `full_name`, `email`, `phone`, `created_at`, `lost_date`, `lost_reason_name`, `source_name`, `campaign`, `lead_owner`, `task_status`, `location_name`, `allow_sms`, `allow_email`, `custom_field_value`.
- **Flags:** P.
- **Owner question:** "Which leads did we lose, when, and why?"
- **Business types:** all.
- **Quirks:** uses `lead_id`, where the other lead reports use `user_id`.

## convertedLeadReport

- **Schema:** `ConvertedLeadsReportResource`. INFERRED (**fuzzy**: plural `Leads` in schema, singular in report name).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate`. Date cap: 31-day windows accepted; longer windows not tested.
- **Key fields** (15 of 22): `lead_id`, `full_name`, `email`, `phone`, `created_at`, `converted_at`, `converted_by`, `lead_source`, `campaign`, `membership_type_name`, `active`, `lead_owner`, `location_name`, `allow_sms`, `allow_email`.
- **Flags:** P.
- **Owner question:** "Which leads became paying clients, how long did it take, and from which source?"
- **Business types:** all.
- **Quirks:** the time-to-convert is `converted_at − created_at`, which must be computed.

## sessionsReport

- **Schema:** `SessionsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 27): `user_id`, `name`, `user_role`, `email`, `phone`, `membership_type_name`, `membership_type_internal_name`, `status`, `purchase_date`, `price_on_purchase`, `paid`, `start_date`, `end_date`, `sessions_left`, `count_session`. (`total_sessions` and `future_schedules` also present.)
- **Flags:** P, F.
- **Owner question:** "How many sessions has each member used from their pack, and how many are left?"
- **Business types:** fitness (class packs), clinic (session packs), education (course passes), beauty (treatment packs).
- **Quirks:** uses `name`, not `full_name`. `sessions_left` was an integer on all 7 rows seen on 2026-10-15; the earlier `string|null` note is not seen on this account.

## expiringSessionsReport

- **Schema:** `ExpiringSessionsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate`. Date cap: 31-day windows accepted; longer windows not tested.
- **Key fields** (15 of 29): `user_id`, `full_name`, `email`, `phone`, `group_leader`, `membership_type_name`, `start_date`, `end_date`, `sessions_left`, `future_schedules`, `count_session`, `price`, `cancelled`, `cancel_reason`, `has_another_session`.
- **Flags:** P, F.
- **Owner question:** "Which session packs are about to run out, and how many sessions are left?"
- **Business types:** fitness, Pilates, yoga, clinic, beauty (packs), education (course passes).
- **Quirks:** `sessions_left` was an integer on the 1 row seen on 2026-10-15; no null seen yet. Filter by numeric value after casting.

## expiredSessionsReport

- **Schema:** `ExpiredSessionsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 25): `user_id`, `full_name`, `email`, `phone`, `age`, `gender`, `membership_type_name`, `start_date`, `end_date`, `deactivate_date`, `ending_reason`, `sessions_left`, `client_status`, `task_status`, `location_name`.
- **Flags:** P.
- **Owner question:** "Which session packs ended, when, and did they use them up?"
- **Business types:** all.
- **Quirks:** A natural pair with `expiringSessionsReport`.

## activeMembershipsReport

- **Schema:** `ActiveMembershipsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 32): `user_id`, `full_name`, `email`, `phone`, `membership_type_name`, `membership_type_internal_name`, `membership_user_id`, `purchase_date`, `start_date`, `end_date`, `status`, `price`, `paid`, `open_charges`, `ltv`.
- **Flags:** P, F (`open_charges`, `ltv`, `price`, `paid`).
- **Owner question:** "Which memberships are active, what did each pay, and what does each still owe?"
- **Business types:** all.
- **Quirks:** `leg` is present, meaning UNKNOWN. `ltv` is a computed lifetime value and needs a definition before use.

## futureSessionsReport

- **Schema:** `FutureSessionsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 28): `user_id`, `full_name`, `email`, `phone`, `membership_type_name`, `membership_status`, `price`, `paid`, `start_date`, `end_date`, `sessions_left`, `future_schedules`, `sessions`, `created_at`, `location_name`.
- **Flags:** P, F.
- **Owner question:** "Which session packs start later, and how many scheduled sessions does each have?"
- **Business types:** fitness, clinic, education.
- **Quirks:** Would be the forward-looking pair with `expiringSessionsReport`.

## groupMembersCoordinatorReport

- **Schema:** `GroupMembersCoordinatorReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (all 13): `user_id`, `full_name`, `first_name`, `last_name`, `phone`, `department_name`, `membership_name`, `num_of_members`, `start_date`, `end_date`, `price`, `paid`, `custom_field_value`.
- **Flags:** P, F.
- **Owner question:** "Who coordinates each group membership (family, team, company), and how many people are in it?"
- **Business types:** activities and education (family/school groups), fitness (team plans, company plans). INFERRED.
- **Quirks:** `num_of_members` is a count but not documented as one. Compare with `inactiveHeadMembersReport` (see #27), which is probably the "head member" variant.

## inactiveHeadMembersReport

- **Schema:** UNTYPED. No schema in the union matches. Closest name: `InactiveMembersReportResource` (#2), which is not a valid mapping because "head members" is a group concept.
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields:** none (no schema).
- **Flags:** P (expected; UNKNOWN until confirmed).
- **Owner question:** INFERRED: "Which group-membership heads (coordinators) are inactive?" Confirm with a live call.
- **Business types:** same as #24. INFERRED.
- **Quirks:** UNTYPED. Do not use `inactiveMembersReport`'s fields as a stand-in.

## regularsReport

- **Schema:** `RegularsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (all 14): `user_id`, `full_name`, `first_name`, `last_name`, `phone`, `start_date`, `start_time`, `end_time`, `day_of_week`, `class_name`, `series_name`, `staff_member`, `location_name`, `membership_status`.
- **Flags:** P.
- **Owner question:** "Who attends the same class on the same day every week?"
- **Business types:** fitness (weekly classes), education (weekly courses), clinic (recurring appointments).
- **Quirks:** the report gives a regular's slot, not their attendance history. Pair with `absenceReport` for "regular who stopped".

## signedFormsReport

- **Schema:** `SignedFormsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required: `toDate` (without it, 400 "'to date' is required", observed 2026-10-15). `fromDate` is optional. Observed 2026-10-15: `toDate` alone returned 200 with 6 rows; `fromDate` 2026-09-15 with `toDate` 2026-10-15 returned 200 with 0 rows, so `fromDate` narrows the result. Date cap: not tested beyond 31 days.
- **Key fields** (15 of 18): `user_id`, `form_id`, `full_name`, `phone`, `email`, `status`, `type`, `sign_date`, `exp_date`, `sent_by`, `user_role`, `allow_email`, `allow_sms`, `lead_owner`, `lead_owner_id`. Exclude `personal_id`.
- **Flags:** P. **Possibly H** if `type` is a health declaration. Form content is not in this report.
- **Owner question:** "Who signed which form (waiver or health declaration), and when does it expire?"
- **Business types:** all, especially fitness, clinic, beauty (treatments).
- **Quirks:** `type` values seen: `HASWAIVER` (waiver) and `MEDICALCERT` (field report, 2026-10-15). That `MEDICALCERT` is the health declaration rather than a doctor's certificate is not documented (LIVE CHECK). `form_id` is the signature record's id, not the `GET /v3/digitalForms` `form_id`, so form names cannot be joined.

## debtReport

- **Schema:** `DebtReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 17): `user_id`, `full_name`, `phone`, `email`, `user_role`, `item_name`, `status`, `price`, `debt`, `created_at`, `referrer`, `sale_person_name`, `location_name`, `task_status`, `custom_field_value`.
- **Flags:** P, F.
- **Owner question:** "Who owes money, for what, and how much?"
- **Business types:** all.
- **Quirks:** `debt` and `price` are numbers, not strings. `status` values seen: `Incompatible Status`, `inactive`; meaning not documented. `task_status` seen: `taskNone` (field report, 2026-10-15).

## transactionsReport

- **Schema:** `TransactionsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 21): `transaction_id`, `transaction_date`, `user_id`, `full_name`, `phone`, `item_name`, `type`, `amount`, `payments_number`, `last_four_digits`, `status`, `transaction_payment_response_code`, `sale_person_name`, `receipt`, `location_name`.
- **Flags:** P, F, and the card's last four digits (low risk, but do not print full card data).
- **Owner question:** "Which payments went through, which failed, and for what?"
- **Business types:** all.
- **Quirks:** Overlaps with the finance `failedTransactions` endpoint. `payments_number` is the number of installments.

## salesReport

- **Schema:** `SalesReportResource` (the one in the report union, **not** `App.Http.Resources.PublicApiV3.Invoice.SalesReportResource`). INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate`. Date cap: 31 days (observed 2026-10-15: a 60-day window returned 400).
- **Key fields** (15 of 39): `date`, `full_name`, `item_name`, `item_type`, `price`, `discount`, `paid`, `debt`, `status`, `action`, `sub_action`, `sale_person_name`, `lead_source`, `campaign_name`, `promo_code`. Also present, and returned live: `medical_cert`, `has_waiver`, `personal_id` (strip them before anything is written), plus `has_image`, `membership_type_internal_name`.
- **Flags:** P, F, **H** (`medical_cert`, `has_waiver` present in the schema, not in the key list).
- **Owner question:** "What did I sell this period, at what price, and how much was paid?"
- **Business types:** all.
- **Quirks:** name collision noted above. `action` and `sub_action` are always filled on a live account (field report, 2026-10-15): `action` `New purchase`, `Renew`, `Purchase`, `Lead converted purchase`; `sub_action` `Separated Payment`, `Debt`, `Free`, `Purchase Occasion`. A filter on empty `action` matches nothing. How refunds look is not known. The spec states its 31-day cap on `/v3/finance/reports/sales`, but this report refuses windows over 31 days too.

## bookingStatisticsReport

- **Schema:** UNTYPED. No schema in the union matches the name.
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate`, `type`. `type` accepts `summary_attendance_by_customer` or `summary_attendance_by_membership` (other values return 400, observed 2026-10-15). Date cap: not tested beyond 31 days.
- **Key fields:** none (no schema).
- **Flags:** P, possibly none. UNKNOWN until confirmed.
- **Business types:** fitness, Pilates, yoga, CrossFit, education. INFERRED.
- **Quirks:** UNTYPED. Confirm the shape with a live call before relying on it.

## classesSummaryReport

- **Schema:** `ClassesSummaryReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate` (400 without them) (field report, 2026-10-15). Date cap: not tested beyond 31 days.
- **Key fields** (15 of 33): `schedule_id`, `date`, `day_of_week`, `start_time`, `end_time`, `class_name`, `staff_member`, `space`, `status`, `registration_count`, `registration_percentage`, `check_in`, `check_in_percentage`, `standby_members`, `late_cancellation`.
- **Flags:** **S** (`salary` is in the schema; exclude by default). P is present (`full_name`, `phone`) but not needed for a class summary.
- **Owner question:** "How full was each class, and how many people actually came?"
- **Business types:** fitness, Pilates, yoga, CrossFit, education (courses), activities (group sessions).
- **Quirks:** on a live account, one row per class with `registration_count` and `salary` (staff pay per class, flag S) (field report, 2026-10-15). It lists cancelled classes that `GET /v3/schedule` leaves out, and has no `cancelled_status` field. `registration_percentage` and `check_in_percentage` are strings or numbers (unclear).

## cancelledSessionsReport

- **Schema:** `CancelledSessionsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 16): `schedule_id`, `date`, `day_of_week`, `start_time`, `end_time`, `class_name`, `full_name`, `space`, `category_group`, `staff_member`, `cancelled_time`, `cancelled_by`, `status`, `location_name`, `last_name`.
- **Flags:** P.
- **Owner question:** "Which classes did we cancel, when, and who cancelled them?"
- **Business types:** all.
- **Quirks:** this is a class-level cancel (the whole session), not a member's booking cancel. Do not confuse it with #34 or #35.

## bookingCancellationReport

- **Schema:** `BookingCancellationReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 18): `user_id`, `full_name`, `phone`, `email`, `schedule_id`, `class_name`, `staff_member`, `date`, `start_time`, `booking_time`, `cancelled_time`, `hours_before`, `cancelled_by`, `location_name`, `allow_sms`.
- **Flags:** P.
- **Owner question:** "Which members cancelled a booking, and how far ahead of the class?"
- **Business types:** all.
- **Quirks:** `hours_before` is the cancel lead time. Overlaps with `lateCancellationReport` (#36). Use this one for "all cancels" and #36 for "late cancels only".

## lateCancellationReport

- **Schema:** `LateCancellationReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: 31 days (observed 2026-10-15: a 60-day window returned 400).
- **Key fields** (15 of 19): `booking_id`, `full_name`, `phone`, `email`, `session_name`, `membership_type_name`, `membership_user_id`, `staff_member`, `start_time`, `cancelled_time`, `hours_before`, `cancelled_by`, `entered_from_standby`, `location_name`, `allow_sms`.
- **Flags:** P.
- **Owner question:** "Who cancelled too late, and how late?"
- **Business types:** fitness, Pilates, yoga, clinic, beauty.
- **Quirks:** `late_cancellation` on the `cancelUserBooking` request is a boolean. This report has no such field. Use `hours_before` and the studio's late-cancel rule. The rule itself is UNKNOWN.

## bookingsReport

- **Schema:** UNTYPED. No schema matches. Closest by name: none. Not `BookingCancellationReportResource` (cancels, not bookings).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate`. Date cap: 31-day windows accepted; longer windows not tested.
- **Key fields:** none.
- **Flags:** P (expected).
- **Owner question:** INFERRED: "All bookings in a period." Confirm with a live call.
- **Business types:** all. INFERRED.

## attendanceExternalMembersReport

- **Schema:** `AttendanceExternalMembersReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 20): `user_id`, `full_name`, `phone`, `membership_type_name`, `location_name`, `age`, `gender`, `class_name`, `class_date`, `class_time`, `booking_time`, `hours_before`, `staff_member`, `booking_status`, `cancelled_by`.
- **Flags:** P.
- **Owner question:** INFERRED: "Who attended as an external (non-member) guest, such as a trial or drop-in?" The spec does not define "external".
- **Business types:** fitness, activities. INFERRED.
- **Quirks:** "external" is undefined. Confirm with a known drop-in before relying on it.

## employeeAttendanceReport

- **Schema:** `EmployeeAttendanceReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (all 12): `staff_member`, `full_name`, `first_name`, `last_name`, `entrance_time`, `exit_time`, `day_of_week`, `total_hours`, `placemark`, `placemark_exit`, `entrance_platform`, `exit_platform`.
- **Flags:** **S** (clock-in/out, location of punch, hours). Also A-like (`placemark` may be a location or a device).
- **Owner question:** "When did each staff member clock in and out, and how many hours did they work?"
- **Business types:** all.
- **Quirks:** `placemark` and `placemark_exit` are free strings. If they hold GPS, that is a stronger privacy concern (UNKNOWN). Recipes should only report totals to the owner, not raw punch locations, unless the owner asks.

## staffActionsReport

- **Schema:** `StaffActionsReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (all 11): `time`, `day_of_week`, `staff_member`, `staff_member_id`, `action`, `sub_action`, `user_role`, `user_id`, `full_name`, `first_name`, `last_name`.
- **Flags:** **S** (audit trail of staff activity on members).
- **Owner question:** "What did each staff member do in the system, and to whom?"
- **Business types:** all.
- **Quirks:** It is an audit log, so use it only when an owner asks.

## trialClassesReport

- **Schema:** `TrialClassesReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate`. Date cap: 31 days (observed 2026-10-15: a 44-day window returned 400).
- **Key fields** (15 of 33): `user_id`, `full_name`, `email`, `phone`, `date`, `start_time`, `class_name`, `status`, `days_passed`, `source_name`, `campaign`, `lead_owner`, `check_in`, `staff_member`, `lost_reason_name`.
- **Flags:** P.
- **Owner question:** "Who tried a class, and who joined afterwards?"
- **Business types:** fitness, Pilates, yoga, CrossFit, education.
- **Quirks:** `status` and `platform` are free strings. `days_passed` is the funnel gap.

## absenceReport

- **Schema:** `AbsenceReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate`, `group_by` (one of `membership_user`, `membership_user_fk`, `user`, `user_fk`; `user` returned 200 on 2026-10-15). Date cap: 31 days (observed 2026-10-15: a 90-day window returned 400).
- **Key fields** (all 15): `full_name`, `first_name`, `last_name`, `phone`, `email`, `last_seen`, `future_registration`, `latest_registration`, `memberships`, `membership_name`, `debt`, `task_status`, `location_name`, `allow_sms`, `allow_email`.
- **Flags:** P, F (`debt`).
- **Owner question:** "Who hasn't come in for a while, and do they have a future booking?"
- **Business types:** all.
- **Quirks:** `memberships` is nested and untyped inside the row. No `user_id`; the row's `id` matches no user id, so join by phone, and phones mix `05x` and `+972` formats (normalize to digits, drop a leading `00`, leading `972` to `0`). The dates do not filter on `last_seen`. `future_registration` is `"no"` when nothing is booked, not empty (field report, 2026-10-15).

## entranceReport

- **Schema:** `EntranceReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 18): `user_id`, `full_name`, `phone`, `email`, `entrance_time`, `exit_time`, `membership_type_name`, `end_membership_time`, `sessions_left`, `chip_entrance`, `gate_name`, `exit_gate_name`, `user_role`, `location_name`, `custom_field_value`. Exclude `personal_id`.
- **Flags:** **A** (physical presence and gate log), P.
- **Owner question:** "Who came in, when, and through which gate?"
- **Business types:** fitness (gym floor), activities. Clinic and beauty rarely.
- **Quirks:** This report is a read. `chip_entrance` is a string.

## hugimBookingReport

- **Schema:** `HugimBookingReportResource`. INFERRED (exact).
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields** (15 of 22): `user_id`, `full_name`, `phone`, `email`, `age`, `course_name`, `course_type`, `is_fully_booked`, `category_group`, `space_name`, `staff_member`, `debt`, `membership_status`, `start_date`, `end_date`.
- **Flags:** P, F (`debt`). Age of a child is P.
- **Owner question:** "Who is enrolled in each course, and is the course full?"
- **Business types:** education (kids' courses), fitness (multi-week courses), activities.
- **Quirks:** "hugim" is Hebrew for after-school courses (חוגים). Relevant to the Hebrew-first market (see `arbox-product.md`).

## activeHugimReport

- **Schema:** UNTYPED. No schema matches. Closest by name: `HugimBookingReportResource` (#43), which is not used as a mapping.
- **Params:** shared set (see *Shared facts*). None required. Date cap: none documented.
- **Key fields:** none.
- **Flags:** P (expected).
- **Owner question:** INFERRED: "Which courses are currently running?" Confirm with a live call.
- **Business types:** education, fitness, activities. INFERRED.
- **Quirks:** UNTYPED.

## hugimRevenueReport

- **Schema:** UNTYPED. No schema matches.
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate`. Date cap: 31-day windows accepted; longer windows not tested.
- **Key fields:** none.
- **Flags:** F (expected).
- **Owner question:** INFERRED: "How much revenue does each course bring in?" Confirm with a live call.
- **Business types:** education, fitness, activities. INFERRED.
- **Quirks:** UNTYPED.

## hugimRevenueByReceiptReport

- **Schema:** UNTYPED. The name suggests `ReceiptReportResource`, but that schema is the finance receipts endpoint's, untyped (`data: array<?>`), and is not in the report union. Not used as a mapping.
- **Params:** shared set (see *Shared facts*). Required: `fromDate`, `toDate`. Date cap: 31-day windows accepted; longer windows not tested.
- **Key fields:** none.
- **Flags:** F (expected).
- **Owner question:** INFERRED: "Course revenue, one row per receipt." Confirm with a live call.
- **Business types:** education, fitness, activities. INFERRED.
- **Quirks:** UNTYPED.

## revenueAnalysisReport

- **Schema:** UNTYPED. No schema matches.
- **Params:** not usable. The server refuses this name on 2026-10-15 (400 "reportName must be one of ..."), although it is in the spec's enum of 47.
- **Key fields:** none.
- **Flags:** F (expected).
- **Owner question:** INFERRED: "Revenue broken down by something (product, membership type, period). Confirm the dimension with a live call."
- **Business types:** all. INFERRED.
- **Quirks:** UNTYPED.

---
