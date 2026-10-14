# Arbox reports: all 47 `reportName` values

Research date: 2026-10-14. Task T3. Advisory, no code.
Companion to `docs/research/arbox-api.md` (API map) and `docs/research/arbox-product.md` (product map).

**Count: 47 report names** (`spec:/components/schemas/ReportName/enum`). The API map says 46; that count is wrong (see Corrections).

**Mapping labels**
- **LINKED**: the spec ties this report name to its response schema. **None of the 47 are LINKED.** The `GET /v3/reports/{reportName}` 200 response is an untagged `anyOf` with no discriminator and no per-value mapping, so every name-to-schema pairing is a judgment.
- **INFERRED**: a schema exists in the endpoint's `anyOf` whose name matches the report name. "exact" means the stem is identical. "fuzzy" means a plural, suffix or spelling difference.
- **UNTYPED**: no schema in the union matches the name. A near-name may exist (noted per entry), but it is not used as a mapping.

**Result: 40 INFERRED (38 exact, 2 fuzzy), 0 LINKED, 7 UNTYPED. 38 + 2 + 7 = 47.** Fuzzy: `convertedLeadReport` (→ `ConvertedLeadsReportResource`, plural) and `membersPropertiesReport` (→ `MembersPropertiesReportSource`, `Source` suffix).

All names are `camelCase` values of one path parameter. Every report is an `application/json` response with envelope `{statusCode: 200|204, data: [...], extra: [...]}`. Per-report `data` item fields are below. `extra` is untyped in every schema.

---

## Shared facts (apply to all 47)

**Query parameters.** The spec gives all 47 the same parameter list. It does not say which parameters apply to which report, so per-report applicability is UNKNOWN. Likely-relevant parameters are marked INFERRED in each entry.

| Param | Type | Notes |
|---|---|---|
| `reportName` | path, required, enum of 47 | Also repeated as an optional query param (duplicate name, see Quirks) |
| `fromDate`, `toDate` | string, camelCase, no `format` | Date filter. Description says only "FromDate"/"ToDate". No cap documented on this endpoint |
| `location_id` | integer | Location filter |
| `user_id` | integer | Member filter |
| `membership_type_id` | integer | Membership type filter |
| `status`, `status_id` | string / integer | Status filters. Values not documented |
| `source_id`, `lost_reason_id`, `sale_person_id`, `assignee_id`, `coach_id`, `box_category_id`, `space_id` | integer | Entity filters |
| `type` | string, free | Not documented |
| `sessions_left` | integer | Filter by remaining sessions |
| `group_by` | string enum: `membership_user`, `membership_user_fk`, `user`, `user_fk` | Grouping. Which reports honor it: UNKNOWN |
| `hideFutureCancel`, `hideHold` | string enum `"0"` / `"1"` | Example `"1"` |
| `success` | string enum `"0"` / `"1"` | Not described. Probably irrelevant to reports (it appears to be a shared parameter) |
| `page`, `limit`, `sort` | integer, integer (max 500), `asc`/`desc` | Pagination. Response has no total or next-page field |

**Required parameters:** none beyond the path `reportName`. Every filter is optional.

**Date-range caps:** none documented on this endpoint. The "31 days" cap in `arbox-api.md` applies only to four `/v3/finance/reports/*` GETs (invoices, receipts, cashFlow, sales). It does not apply to `salesReport` here. Whether any report enforces a cap is UNKNOWN (live check L7).

**Responses:** 200, 404, 422. No error schema. `data` is always an array, even for single-object cases.

**Flags used in the field lists**
- **P**: personal data. Names, contact details, age, gender, birthday, address, national ID (`personal_id`).
- **H**: health or injury. `injury`, `medical_cert`, `has_insurance`, `has_waiver` (waiver is a form, usually a health declaration).
- **F**: money. Price, paid, debt, refund, LTV, card last four.
- **S**: staff-private. Salary, staff clock-in/out, staff audit logs. Staff are not the owner's customers, and some of this is labor-law-sensitive.
- **A**: physical access or presence log. Entry gate and entry/exit times.

**Default exclusions proposed in `owner-journey.md` Q5 apply:** `injury`, `medical_cert`, waiver `medical`, `salary`, and staff pay.

---

## Quirks that affect every report

1. **Schema count is off in the API map.** `arbox-api.md` says the 200 `anyOf` has 44 schemas. It has **41** (40 `*ReportResource` plus `MembersPropertiesReportSource`). The 44 `*ReportResource` schemas include 4 not in the `anyOf` (see below).
2. **Name collision on `SalesReportResource`.** Two schemas share this name: the plain `SalesReportResource` (in the report `anyOf`) and `App.Http.Resources.PublicApiV3.Invoice.SalesReportResource` (not in the report `anyOf`, wired to `/v3/finance/reports/sales`, `data` untyped). Do not map `salesReport` to the Invoice one.
3. **Finance schemas are not reports.** `CashFlowReportResource`, `InvoiceReportResource` and `ReceiptReportResource` are linked to the finance GETs (`cashFlow`, `invoices`, `receipts`), and their `data` is `array<?>`. Untyped. Finance data needs live probing.
4. **Orphan schema:** `ShiftSummaryReportResource` is in the `anyOf` but no enum value maps to it. Its name suggests a `shiftSummaryReport` that the enum does not have. It may be unreachable.
5. **Inconsistent field names:** most reports use `full_name`, but `SessionsReportResource` and `TransparentSessionsReportResource` use `name`. Probe before relying on either.
6. **Type mismatches seen in the spec:** `sessions_left` is `["string","null"]` in all five session reports, while the request filter `sessions_left` is `integer`. `debt` is `["string","null"]` in `AbsenceReportResource`, and `medical_cert` and `restricted` are `string` in `MembersPropertiesReportSource`. Treat money and counts as strings until probed.
7. **Dates:** time fields are `date-time` in the spec, with no timezone stated.
8. **Untagged union.** The `anyOf` has no `discriminator`, so a client cannot choose a schema from the response. The mapping above is by name only. Live probe needed for every report.

---

## Per-report entries

Format: schema and label, then key fields (all fields if the schema has 15 or fewer, otherwise the 15 most owner-relevant), flags, owner question, business types, quirks. Field counts are from the `data` item's `properties`.

### Members and memberships

#### 1. `activeMembersReport`
- **Schema:** `ActiveMembersReportResource`. INFERRED (exact).
- **Key fields** (15 of 28): `full_name`, `user_type`, `email`, `phone`, `age`, `gender`, `created_at`, `active_memberships_count`, `future_memberships_count`, `union_name`, `location_name`, `lead_owner`, `allow_sms`, `allow_email`, `custom_field_value`.
- **Flags:** P.
- **Owner question:** "Who is an active member right now, and how many plans does each hold?"
- **Business types:** all.
- **Quirks:** `union_name`/`union_id` (meaning unclear, possibly a membership group). `active_memberships_count` is the strongest filter for "active".

#### 2. `inactiveMembersReport`
- **Schema:** `InactiveMembersReportResource`. INFERRED (exact).
- **Key fields** (15 of 30): `full_name`, `user_type`, `email`, `phone`, `inactive_from`, `active_memberships_count`, `future_memberships_count`, `active_charges`, `created_at`, `age`, `gender`, `lead_owner`, `location_name`, `allow_sms`, `allow_email`.
- **Flags:** P, F (`active_charges`).
- **Owner question:** "Which members no longer have an active membership, and since when?"
- **Business types:** all.
- **Quirks:** `inactive_from` is the only date that dates the lapse. Not the same as "not visited recently", which is `absenceReport`.

#### 3. `expiringMembershipsReport`
- **Schema:** `ExpiringMembershipsReportResource`. INFERRED (exact).
- **Key fields** (15 of 24): `full_name`, `phone`, `email`, `membership_type_name`, `membership_user_id`, `start_date`, `end_date`, `price`, `cancelled`, `cancel_reason`, `has_another_session`, `has_another_plan`, `group_leader`, `location_name`, `lead_owner`.
- **Flags:** P, F.
- **Owner question:** "Whose time-based membership ends soon, and has it already been cancelled?"
- **Business types:** fitness, Pilates, yoga, clinic (monthly plans), beauty (monthly plans).
- **Quirks:** `has_another_plan` / `has_another_session` tell you whether a renewal is already in place. Use them before drafting a renewal message.

#### 4. `expiredMembershipsReport`
- **Schema:** `ExpiredMembershipsReportResource`. INFERRED (exact).
- **Key fields** (15 of 28): `full_name`, `phone`, `email`, `membership_type_name`, `membership_user_id`, `start_date`, `end_date`, `ending_reason`, `client_status`, `price`, `active_charges`, `ltv`, `lead_owner`, `location_name`, `task_status`.
- **Flags:** P, F (`ltv`, `active_charges`).
- **Owner question:** "Which memberships ended, why did they end, and did they owe money?"
- **Business types:** all.
- **Quirks:** `ending_reason` is free text in practice (not enumerated in the spec).

#### 5. `canceledMembershipsReport`
- **Schema:** `CanceledMembershipsReportResource`. INFERRED (exact; spelling matches "canceled" in both).
- **Key fields** (15 of 25): `full_name`, `phone`, `email`, `membership_type_name`, `purchase_date`, `end_date`, `cancelled_time`, `cancel_reason`, `cancelled_by`, `comment`, `refund`, `sale_person_name`, `active`, `location_name`, `lead_owner`.
- **Flags:** P, F (`refund`). **`comment` is free text and may hold health or personal notes.** Treat it as sensitive unless the owner says otherwise.
- **Owner question:** "Who cancelled their membership, when, why, and did they get a refund?"
- **Business types:** all.
- **Quirks:** the `owner-journey.md` idea 17 says this report's "row shape is untyped here". That is wrong: the schema is typed. Only the enum-to-schema link is INFERRED.

#### 6. `membersOnHoldReport`
- **Schema:** `MembersOnHoldReportResource`. INFERRED (exact).
- **Key fields** (15 of 17): `full_name`, `phone`, `user_id`, `membership_user_id`, `membership_hold_id`, `membership_type_name`, `start_suspend_time`, `end_suspend_time`, `total_days`, `suspend_reason`, `start_membership_time`, `end_membership_time`, `price`, `task_status`, `location_name`.
- **Flags:** P, F (`price`).
- **Owner question:** "Who has paused their membership, and when does the pause end?"
- **Business types:** all.
- **Quirks:** `suspend_reason` is free text in practice.

#### 7. `membersPropertiesReport`
- **Schema:** `MembersPropertiesReportSource`. INFERRED (**fuzzy**: the schema ends `Source`, not `Resource`; the only such name in the union).
- **Key fields** (15 of 31): `full_name`, `gender`, `age`, `personal_id`, `membership_type_name`, `department_name`, `has_waiver`, `medical_cert`, `has_insurance`, `restricted`, `injury`, `has_image`, `allow_sms`, `allow_email`, `custom_field_value`.
- **Flags:** P (`personal_id`, `age`, `gender`), **H** (`injury`, `medical_cert`, `has_insurance`, `has_waiver`). **Default-exclude H** per `owner-journey.md` Q5.
- **Owner question:** "Which member profiles are incomplete (no waiver, no medical certificate, no insurance, no photo)?"
- **Business types:** fitness and clinic most of all (medical certs and waivers). Beauty partly (has_image).
- **Quirks:** the `Source` suffix is the only one in the union. Probably a typo in the spec for `Resource`, but it cannot be confirmed.

#### 8. `restrictedMembersReport`
- **Schema:** `RestrictedMembersReportResource`. INFERRED (exact).
- **Key fields** (all 7): `user_id`, `full_name`, `first_name`, `last_name`, `email`, `phone`, `last_seen`.
- **Flags:** P.
- **Owner question:** "Which members are restricted (blocked from booking or entering), and when were they last seen?"
- **Business types:** all.
- **Quirks:** the spec does not say what "restricted" means (manual ban, debt, injury, or a waiver rule). The schema body has `restricted` and `restricted_time` on `MembersPropertiesReport`, so the flag exists on the profile. Meaning of the reason: UNKNOWN.

#### 9. `transparentMembershipsReport`
- **Schema:** `TransparentMembershipsReportResource`. INFERRED (exact).
- **Key fields** (15 of 23): `user_id`, `full_name`, `user_role`, `email`, `phone`, `department_name`, `membership_type_name`, `status`, `price`, `paid`, `start_date`, `end_date`, `created_at`, `location_name`, `city`.
- **Flags:** P, F.
- **Owner question:** UNKNOWN. The spec does not define "transparent". The API map lists a `transparent` query flag on other endpoints. Meaning: UNKNOWN; ask Arbox before writing a recipe.
- **Business types:** UNKNOWN.
- **Quirks:** the name is not defined anywhere in the spec.

#### 10. `transparentSessionsReport`
- **Schema:** `TransparentSessionsReportResource`. INFERRED (exact).
- **Key fields** (15 of 21): `user_id`, `name`, `email`, `phone`, `department_name`, `membership_type_name`, `status`, `price`, `paid`, `start_date`, `end_date`, `sessions_left`, `future_schedules`, `count_session`, `lead_owner`.
- **Flags:** P, F.
- **Owner question:** UNKNOWN (same as #9, but for session packs).
- **Business types:** UNKNOWN.
- **Quirks:** uses `name`, not `full_name`. Same undefined "transparent" concept.

#### 11. `renewalsReport`
- **Schema:** `RenewalsReportResource`. INFERRED (exact).
- **Key fields** (15 of 16): `user_id`, `full_name`, `first_name`, `last_name`, `email`, `phone`, `membership_type_name`, `created_at`, `referrer`, `sale_person_name`, `location_name`, `lead_owner`, `lead_owner_id`, `allow_sms`, `allow_email`.
- **Flags:** P. Exclude `personal_id`.
- **Owner question:** "Who renewed their membership, on which plan, and who sold it?"
- **Business types:** all.
- **Quirks:** the rows look like new purchase records (`created_at`, `referrer`, `sale_person_name`), which may mean the report lists renewal sales rather than renewal status. INFERRED from field set; probe.

#### 12. `futureMembershipsReport`
- **Schema:** `FutureMembershipsReportResource`. INFERRED (exact).
- **Key fields** (15 of 24): `user_id`, `full_name`, `email`, `phone`, `department_name`, `membership_type_name`, `membership_status`, `price`, `debt`, `start_date`, `end_date`, `created_at`, `location_name`, `lead_owner`, `allow_sms`.
- **Flags:** P, F (`price`, `debt`).
- **Owner question:** "Which memberships start later, and which of those already owe money?"
- **Business types:** all.
- **Quirks:** none beyond the shared ones.

#### 13. `allClientsReport`
- **Schema:** `AllClientsReportResource`. INFERRED (exact).
- **Key fields** (all 14): `user_id`, `full_name`, `first_name`, `last_name`, `email`, `phone`, `gender`, `age`, `created_at`, `location_name`, `address`, `allow_email`, `allow_sms`, `last_purchase`.
- **Flags:** P (`address`, `age`, `gender`). Largest personal-data report.
- **Owner question:** "Give me every client, with their last purchase date."
- **Business types:** all.
- **Quirks:** `last_purchase` is the only "activity" field here. Use `absenceReport` for attendance.

#### 14. `birthdayReport`
- **Schema:** `BirthdayReportResource`. INFERRED (exact).
- **Key fields** (15 of 16): `user_id`, `full_name`, `first_name`, `last_name`, `birthday`, `age`, `status`, `user_role`, `phone`, `email`, `allow_sms`, `allow_email`, `location_name`, `lead_owner`, `lead_owner_id`. Exclude `personal_id`.
- **Flags:** P (`birthday`, `age`).
- **Owner question:** "Whose birthday is coming up so I can send a wish?"
- **Business types:** all.
- **Quirks:** the spec does not say whether `fromDate`/`toDate` filter by birthday (month-day) or by the report date. Probe (L7). The `allow_*` fields are the consent gate for any message.

#### 15. `leadsInProcessReport`
- **Schema:** `LeadsInProcessReportResource`. INFERRED (exact).
- **Key fields** (15 of 23): `user_id`, `full_name`, `email`, `phone`, `lead_status`, `lead_source`, `lead_owner`, `lead_owner_id`, `campaign`, `created_at`, `updated_at`, `task_status`, `city`, `location_name`, `allow_sms`.
- **Flags:** P.
- **Owner question:** "Which leads are open right now, at what stage, and who owns them?"
- **Business types:** all, especially fitness and beauty (lead-driven sales).
- **Quirks:** `user_id` here is the lead's id. Compare with `leads` operations in the API map.

#### 16. `allLeadsReport`
- **Schema:** `AllLeadsReportResource`. INFERRED (exact).
- **Key fields** (15 of 21): `user_id`, `full_name`, `email`, `phone`, `status`, `lead_source`, `created_at`, `updated_at`, `trial_class`, `lead_owner`, `campaign`, `task_status`, `location_name`, `allow_sms`, `lost_reason_name`.
- **Flags:** P.
- **Owner question:** "Every lead we have, its status and where it came from."
- **Business types:** all.
- **Quirks:** `status` is free text here, but the lead-statuses operation (`GET /v3/statuses`) exists. Check that the values match.

#### 17. `lostLeadsReport`
- **Schema:** `LostLeadsReportResource`. INFERRED (exact).
- **Key fields** (15 of 18): `lead_id`, `full_name`, `email`, `phone`, `created_at`, `lost_date`, `lost_reason_name`, `source_name`, `campaign`, `lead_owner`, `task_status`, `location_name`, `allow_sms`, `allow_email`, `custom_field_value`.
- **Flags:** P.
- **Owner question:** "Which leads did we lose, when, and why?"
- **Business types:** all.
- **Quirks:** uses `lead_id`, where the other lead reports use `user_id`. Unused by any owner-journey idea (see the map).

#### 18. `convertedLeadReport`
- **Schema:** `ConvertedLeadsReportResource`. INFERRED (**fuzzy**: plural `Leads` in schema, singular in report name).
- **Key fields** (15 of 22): `lead_id`, `full_name`, `email`, `phone`, `created_at`, `converted_at`, `converted_by`, `lead_source`, `campaign`, `membership_type_name`, `active`, `lead_owner`, `location_name`, `allow_sms`, `allow_email`.
- **Flags:** P.
- **Owner question:** "Which leads became paying clients, how long did it take, and from which source?"
- **Business types:** all.
- **Quirks:** the time-to-convert is `converted_at − created_at`, which must be computed.

#### 19. `sessionsReport`
- **Schema:** `SessionsReportResource`. INFERRED (exact).
- **Key fields** (15 of 27): `user_id`, `name`, `user_role`, `email`, `phone`, `membership_type_name`, `membership_type_internal_name`, `status`, `purchase_date`, `price_on_purchase`, `paid`, `start_date`, `end_date`, `sessions_left`, `count_session`. (`total_sessions` and `future_schedules` also present.)
- **Flags:** P, F.
- **Owner question:** "How many sessions has each member used from their pack, and how many are left?"
- **Business types:** fitness (class packs), clinic (session packs), education (course passes), beauty (treatment packs).
- **Quirks:** uses `name`, not `full_name`. `sessions_left` is `string|null`. Used in owner-journey idea 8 (milestones), which is ASSUMED derivable.

#### 20. `expiringSessionsReport`
- **Schema:** `ExpiringSessionsReportResource`. INFERRED (exact).
- **Key fields** (15 of 29): `user_id`, `full_name`, `email`, `phone`, `group_leader`, `membership_type_name`, `start_date`, `end_date`, `sessions_left`, `future_schedules`, `count_session`, `price`, `cancelled`, `cancel_reason`, `has_another_session`.
- **Flags:** P, F.
- **Owner question:** "Which session packs are about to run out, and how many sessions are left?"
- **Business types:** fitness, Pilates, yoga, clinic, beauty (packs), education (course passes).
- **Quirks:** `sessions_left` is `string|null`. Filter by numeric value after casting.

#### 21. `expiredSessionsReport`
- **Schema:** `ExpiredSessionsReportResource`. INFERRED (exact).
- **Key fields** (15 of 25): `user_id`, `full_name`, `email`, `phone`, `age`, `gender`, `membership_type_name`, `start_date`, `end_date`, `deactivate_date`, `ending_reason`, `sessions_left`, `client_status`, `task_status`, `location_name`.
- **Flags:** P.
- **Owner question:** "Which session packs ended, when, and did they use them up?"
- **Business types:** all.
- **Quirks:** not used by any owner-journey idea. A natural pair with `expiringSessionsReport`.

#### 22. `activeMembershipsReport`
- **Schema:** `ActiveMembershipsReportResource`. INFERRED (exact).
- **Key fields** (15 of 32): `user_id`, `full_name`, `email`, `phone`, `membership_type_name`, `membership_type_internal_name`, `membership_user_id`, `purchase_date`, `start_date`, `end_date`, `status`, `price`, `paid`, `open_charges`, `ltv`.
- **Flags:** P, F (`open_charges`, `ltv`, `price`, `paid`).
- **Owner question:** "Which memberships are active, what did each pay, and what does each still owe?"
- **Business types:** all.
- **Quirks:** `leg` is present, meaning UNKNOWN. `ltv` is a computed lifetime value and needs a definition before use.

#### 23. `futureSessionsReport`
- **Schema:** `FutureSessionsReportResource`. INFERRED (exact).
- **Key fields** (15 of 28): `user_id`, `full_name`, `email`, `phone`, `membership_type_name`, `membership_status`, `price`, `paid`, `start_date`, `end_date`, `sessions_left`, `future_schedules`, `sessions`, `created_at`, `location_name`.
- **Flags:** P, F.
- **Owner question:** "Which session packs start later, and how many scheduled sessions does each have?"
- **Business types:** fitness, clinic, education.
- **Quirks:** not used by any owner-journey idea. Would be the forward-looking pair with `expiringSessionsReport`.

#### 24. `groupMembersCoordinatorReport`
- **Schema:** `GroupMembersCoordinatorReportResource`. INFERRED (exact).
- **Key fields** (all 13): `user_id`, `full_name`, `first_name`, `last_name`, `phone`, `department_name`, `membership_name`, `num_of_members`, `start_date`, `end_date`, `price`, `paid`, `custom_field_value`.
- **Flags:** P, F.
- **Owner question:** "Who coordinates each group membership (family, team, company), and how many people are in it?"
- **Business types:** activities and education (family/school groups), fitness (team plans, company plans). INFERRED.
- **Quirks:** `num_of_members` is a count but not documented as one. Compare with `inactiveHeadMembersReport` (see #27), which is probably the "head member" variant.

#### 25. `inactiveHeadMembersReport`
- **Schema:** UNTYPED. No schema in the union matches. Closest name: `InactiveMembersReportResource` (#2), which is not a valid mapping because "head members" is a group concept.
- **Key fields:** none (no schema).
- **Flags:** P (expected, UNKNOWN until probed).
- **Owner question:** INFERRED: "Which group-membership heads (coordinators) are inactive?" Probe.
- **Business types:** same as #24. INFERRED.
- **Quirks:** UNTYPED. Do not use `inactiveMembersReport`'s fields as a stand-in.

#### 26. `regularsReport`
- **Schema:** `RegularsReportResource`. INFERRED (exact).
- **Key fields** (all 14): `user_id`, `full_name`, `first_name`, `last_name`, `phone`, `start_date`, `start_time`, `end_time`, `day_of_week`, `class_name`, `series_name`, `staff_member`, `location_name`, `membership_status`.
- **Flags:** P.
- **Owner question:** "Who attends the same class on the same day every week?"
- **Business types:** fitness (weekly classes), education (weekly courses), clinic (recurring appointments).
- **Quirks:** the report gives a regular's slot, not their attendance history. Pair with `absenceReport` for "regular who stopped".

#### 27. `signedFormsReport`
- **Schema:** `SignedFormsReportResource`. INFERRED (exact).
- **Key fields** (15 of 18): `user_id`, `form_id`, `full_name`, `phone`, `email`, `status`, `type`, `sign_date`, `exp_date`, `sent_by`, `user_role`, `allow_email`, `allow_sms`, `lead_owner`, `lead_owner_id`. Exclude `personal_id`.
- **Flags:** P. **Possibly H** if `type` is a health declaration. Form content is not in this report.
- **Owner question:** "Who signed which form (waiver or health declaration), and when does it expire?"
- **Business types:** all, especially fitness, clinic, beauty (treatments).
- **Quirks:** `type` is a free string. Its values are UNKNOWN. Pair with `GET /v3/digitalForms` (API map) to resolve.

#### 28. `debtReport`
- **Schema:** `DebtReportResource`. INFERRED (exact).
- **Key fields** (15 of 17): `user_id`, `full_name`, `phone`, `email`, `user_role`, `item_name`, `status`, `price`, `debt`, `created_at`, `referrer`, `sale_person_name`, `location_name`, `task_status`, `custom_field_value`.
- **Flags:** P, F.
- **Owner question:** "Who owes money, for what, and how much?"
- **Business types:** all.
- **Quirks:** owner-journey idea 6 uses this and also `failedTransactions`, which is a separate finance endpoint.

#### 29. `transactionsReport`
- **Schema:** `TransactionsReportResource`. INFERRED (exact).
- **Key fields** (15 of 21): `transaction_id`, `transaction_date`, `user_id`, `full_name`, `phone`, `item_name`, `type`, `amount`, `payments_number`, `last_four_digits`, `status`, `transaction_payment_response_code`, `sale_person_name`, `receipt`, `location_name`.
- **Flags:** P, F, and the card's last four digits (low risk, but do not print full card data).
- **Owner question:** "Which payments went through, which failed, and for what?"
- **Business types:** all.
- **Quirks:** not used by any owner-journey idea, but it is the most direct payments view in the union. Overlaps with the finance `failedTransactions` endpoint. `payments_number` is the number of installments.

#### 30. `salesReport`
- **Schema:** `SalesReportResource` (the one in the report union, **not** `App.Http.Resources.PublicApiV3.Invoice.SalesReportResource`). INFERRED (exact).
- **Key fields** (15 of 39): `date`, `full_name`, `item_name`, `item_type`, `price`, `discount`, `paid`, `debt`, `status`, `action`, `sub_action`, `sale_person_name`, `lead_source`, `campaign_name`, `promo_code`. Also present: `medical_cert`, `has_waiver`, `has_image`, `personal_id`, `membership_type_internal_name`.
- **Flags:** P, F, **H** (`medical_cert`, `has_waiver` present in the schema, not in the key list).
- **Owner question:** "What did I sell this period, at what price, and how much was paid?"
- **Business types:** all.
- **Quirks:** name collision noted above. `action`/`sub_action` are free strings. The 31-day cap in `arbox-api.md` belongs to `/v3/finance/reports/sales`, not to this report; do not assume it applies here.

### Classes, schedule and bookings

#### 31. `bookingStatisticsReport`
- **Schema:** UNTYPED. No schema in the union matches the name. Owner-journey ideas 3 and 15 depend on it.
- **Key fields:** none (no schema).
- **Flags:** P, possibly none. UNKNOWN until probed.
- **Owner question:** INFERRED from the name and from ideas 3 and 15: "How much demand does each class, time slot or course have?" Probe.
- **Business types:** fitness, Pilates, yoga, CrossFit, education. INFERRED.
- **Quirks:** UNTYPED. The biggest blocker for the class-fill and schedule-planner ideas. Live probe (L7) is required before building either.

#### 32. `classesSummaryReport`
- **Schema:** `ClassesSummaryReportResource`. INFERRED (exact).
- **Key fields** (15 of 33): `schedule_id`, `date`, `day_of_week`, `start_time`, `end_time`, `class_name`, `staff_member`, `space`, `status`, `registration_count`, `registration_percentage`, `check_in`, `check_in_percentage`, `standby_members`, `late_cancellation`.
- **Flags:** **S** (`salary` is in the schema; exclude by default). P is present (`full_name`, `phone`) but not needed for a class summary.
- **Owner question:** "How full was each class, and how many people actually came?"
- **Business types:** fitness, Pilates, yoga, CrossFit, education (courses), activities (group sessions).
- **Quirks:** one row per member per class, so counts need grouping. `registration_percentage` and `check_in_percentage` are strings or numbers (unclear).

#### 33. `cancelledSessionsReport`
- **Schema:** `CancelledSessionsReportResource`. INFERRED (exact).
- **Key fields** (15 of 16): `schedule_id`, `date`, `day_of_week`, `start_time`, `end_time`, `class_name`, `full_name`, `space`, `category_group`, `staff_member`, `cancelled_time`, `cancelled_by`, `status`, `location_name`, `last_name`.
- **Flags:** P.
- **Owner question:** "Which classes did we cancel, when, and who cancelled them?"
- **Business types:** all.
- **Quirks:** this is a class-level cancel (the whole session), not a member's booking cancel. Do not confuse it with #34 or #35.

#### 34. `bookingCancellationReport`
- **Schema:** `BookingCancellationReportResource`. INFERRED (exact).
- **Key fields** (15 of 18): `user_id`, `full_name`, `phone`, `email`, `schedule_id`, `class_name`, `staff_member`, `date`, `start_time`, `booking_time`, `cancelled_time`, `hours_before`, `cancelled_by`, `location_name`, `allow_sms`.
- **Flags:** P.
- **Owner question:** "Which members cancelled a booking, and how far ahead of the class?"
- **Business types:** all.
- **Quirks:** `hours_before` is the cancel lead time. Overlaps with `lateCancellationReport` (#36). Use this one for "all cancels" and #36 for "late cancels only".

#### 35. `lateCancellationReport`
- **Schema:** `LateCancellationReportResource`. INFERRED (exact).
- **Key fields** (15 of 19): `booking_id`, `full_name`, `phone`, `email`, `session_name`, `membership_type_name`, `membership_user_id`, `staff_member`, `start_time`, `cancelled_time`, `hours_before`, `cancelled_by`, `entered_from_standby`, `location_name`, `allow_sms`.
- **Flags:** P.
- **Owner question:** "Who cancelled too late, and how late?"
- **Business types:** fitness, Pilates, yoga, clinic, beauty.
- **Quirks:** `late_cancellation` on the `cancelUserBooking` request is a boolean. This report has no such field. Use `hours_before` and the studio's late-cancel rule. The rule itself is UNKNOWN.

#### 36. `bookingsReport`
- **Schema:** UNTYPED. No schema matches. Closest by name: none. Not `BookingCancellationReportResource` (cancels, not bookings).
- **Key fields:** none.
- **Flags:** P (expected).
- **Owner question:** INFERRED: "All bookings in a period." Probe.
- **Business types:** all. INFERRED.
- **Quirks:** owner-journey ideas 2 and 8 depend on this, and both ideas are therefore not grounded in a typed schema yet.

#### 37. `attendanceExternalMembersReport`
- **Schema:** `AttendanceExternalMembersReportResource`. INFERRED (exact).
- **Key fields** (15 of 20): `user_id`, `full_name`, `phone`, `membership_type_name`, `location_name`, `age`, `gender`, `class_name`, `class_date`, `class_time`, `booking_time`, `hours_before`, `staff_member`, `booking_status`, `cancelled_by`.
- **Flags:** P.
- **Owner question:** INFERRED: "Who attended as an external (non-member) guest, such as a trial or drop-in?" The spec does not define "external".
- **Business types:** fitness, activities. INFERRED.
- **Quirks:** "external" is undefined. Probe with a known drop-in before writing a recipe.

#### 38. `employeeAttendanceReport`
- **Schema:** `EmployeeAttendanceReportResource`. INFERRED (exact).
- **Key fields** (all 12): `staff_member`, `full_name`, `first_name`, `last_name`, `entrance_time`, `exit_time`, `day_of_week`, `total_hours`, `placemark`, `placemark_exit`, `entrance_platform`, `exit_platform`.
- **Flags:** **S** (clock-in/out, location of punch, hours). Also A-like (`placemark` may be a location or a device).
- **Owner question:** "When did each staff member clock in and out, and how many hours did they work?"
- **Business types:** all.
- **Quirks:** `placemark` and `placemark_exit` are free strings. If they hold GPS, that is a stronger privacy concern (UNKNOWN). Recipes should only report totals to the owner, not raw punch locations, unless the owner asks.

#### 39. `staffActionsReport`
- **Schema:** `StaffActionsReportResource`. INFERRED (exact).
- **Key fields** (all 11): `time`, `day_of_week`, `staff_member`, `staff_member_id`, `action`, `sub_action`, `user_role`, `user_id`, `full_name`, `first_name`, `last_name`.
- **Flags:** **S** (audit trail of staff activity on members).
- **Owner question:** "What did each staff member do in the system, and to whom?"
- **Business types:** all.
- **Quirks:** not used by any owner-journey idea. It is an audit log, so use it only when an owner asks.

#### 40. `trialClassesReport`
- **Schema:** `TrialClassesReportResource`. INFERRED (exact).
- **Key fields** (15 of 33): `user_id`, `full_name`, `email`, `phone`, `date`, `start_time`, `class_name`, `status`, `days_passed`, `source_name`, `campaign`, `lead_owner`, `check_in`, `staff_member`, `lost_reason_name`.
- **Flags:** P.
- **Owner question:** "Who tried a class, and who joined afterwards?"
- **Business types:** fitness, Pilates, yoga, CrossFit, education.
- **Quirks:** `status` and `platform` are free strings. `days_passed` is the funnel gap.

#### 41. `absenceReport`
- **Schema:** `AbsenceReportResource`. INFERRED (exact).
- **Key fields** (all 15): `full_name`, `first_name`, `last_name`, `phone`, `email`, `last_seen`, `future_registration`, `latest_registration`, `memberships`, `membership_name`, `debt`, `task_status`, `location_name`, `allow_sms`, `allow_email`.
- **Flags:** P, F (`debt`).
- **Owner question:** "Who hasn't come in for a while, and do they have a future booking?"
- **Business types:** all.
- **Quirks:** `memberships` is nested and untyped inside the row. The schema is the best single source for "drifting members" (owner-journey idea 1).

#### 42. `entranceReport`
- **Schema:** `EntranceReportResource`. INFERRED (exact).
- **Key fields** (15 of 18): `user_id`, `full_name`, `phone`, `email`, `entrance_time`, `exit_time`, `membership_type_name`, `end_membership_time`, `sessions_left`, `chip_entrance`, `gate_name`, `exit_gate_name`, `user_role`, `location_name`, `custom_field_value`. Exclude `personal_id`.
- **Flags:** **A** (physical presence and gate log), P.
- **Owner question:** "Who came in, when, and through which gate?"
- **Business types:** fitness (gym floor), activities. Clinic and beauty rarely.
- **Quirks:** tied to the access-control hardware, which the API map and the product map list as UI-only (not in the API spec as a write). This report is a read. `chip_entrance` is a string. Not used by any owner-journey idea.

#### 43. `hugimBookingReport`
- **Schema:** `HugimBookingReportResource`. INFERRED (exact).
- **Key fields** (15 of 22): `user_id`, `full_name`, `phone`, `email`, `age`, `course_name`, `course_type`, `is_fully_booked`, `category_group`, `space_name`, `staff_member`, `debt`, `membership_status`, `start_date`, `end_date`.
- **Flags:** P, F (`debt`). Age of a child is P.
- **Owner question:** "Who is enrolled in each course, and is the course full?"
- **Business types:** education (kids' courses), fitness (multi-week courses), activities.
- **Quirks:** "hugim" is Hebrew for after-school courses (חוגים). INFERRED from the field set (`course_name`, `course_type`, `is_fully_booked`); this confirms the owner-journey ASSUMED meaning. Not used by any owner-journey idea. Relevant to the Hebrew-first market (see `arbox-product.md`).

#### 44. `activeHugimReport`
- **Schema:** UNTYPED. No schema matches. Closest by name: `HugimBookingReportResource` (#43), which is not used as a mapping.
- **Key fields:** none.
- **Flags:** P (expected).
- **Owner question:** INFERRED: "Which courses are currently running?" Probe.
- **Business types:** education, fitness, activities. INFERRED.
- **Quirks:** UNTYPED. Not used by any owner-journey idea.

#### 45. `hugimRevenueReport`
- **Schema:** UNTYPED. No schema matches.
- **Key fields:** none.
- **Flags:** F (expected).
- **Owner question:** INFERRED: "How much revenue does each course bring in?" Probe.
- **Business types:** education, fitness, activities. INFERRED.
- **Quirks:** UNTYPED. Not used by any owner-journey idea.

#### 46. `hugimRevenueByReceiptReport`
- **Schema:** UNTYPED. The name suggests `ReceiptReportResource`, but that schema is the finance receipts endpoint's, untyped (`data: array<?>`), and is not in the report union. Not used as a mapping.
- **Key fields:** none.
- **Flags:** F (expected).
- **Owner question:** INFERRED: "Course revenue, one row per receipt." Probe.
- **Business types:** education, fitness, activities. INFERRED.
- **Quirks:** UNTYPED. Not used by any owner-journey idea.

#### 47. `revenueAnalysisReport`
- **Schema:** UNTYPED. No schema matches.
- **Key fields:** none.
- **Flags:** F (expected).
- **Owner question:** INFERRED: "Revenue broken down by something (product, membership type, period). Probe for the dimension."
- **Business types:** all. INFERRED.
- **Quirks:** UNTYPED. Used by owner-journey idea 5, which is therefore not grounded in a typed schema yet.

---

## Report → recipe idea map

The 22 ideas are from `docs/design/owner-journey.md` section 2. Reports are listed per idea. "U" marks an UNTYPED report.

| # | Idea | Reports used (enum) | Typed? |
|---|---|---|---|
| 1 | Who's drifting | `absenceReport`, `inactiveMembersReport`, `regularsReport` | All typed |
| 2 | Weekly studio digest | `classesSummaryReport`, `bookingsReport` (U), `salesReport`, `canceledMembershipsReport`, `activeMembersReport` | One U |
| 3 | Class-fill finder | `classesSummaryReport`, `bookingStatisticsReport` (U) | One U |
| 4 | Waiting-list pressure | none (uses `GET /v3/schedule/entryFromWaitingList`) | n/a |
| 5 | Revenue snapshot | `salesReport`, `revenueAnalysisReport` (U) + finance endpoints (untyped data) | One U; finance untyped |
| 6 | Payments to chase | `debtReport` (+ finance `failedTransactions`) | Typed |
| 7 | Pack and membership expiry | `expiringSessionsReport`, `expiringMembershipsReport`, `expiredMembershipsReport`, `renewalsReport` | All typed |
| 8 | Birthday and milestones | `birthdayReport`, `sessionsReport` (milestones, ASSUMED), `bookingsReport` (U) | One U |
| 9 | Lead follow-up | `leadsInProcessReport` | Typed |
| 10 | Trial-class tracker | `trialClassesReport`, `convertedLeadReport` | Typed |
| 11 | Where customers come from | `allLeadsReport`, `convertedLeadReport`, `salesReport` | Typed |
| 12 | Local dashboard | ideas 1, 2, 3, 5 (inherits their U) | Inherits |
| 13 | Late-cancel and no-show | `lateCancellationReport`, `bookingCancellationReport`, `cancelledSessionsReport`, `absenceReport` | Typed |
| 14 | Coach load | `classesSummaryReport`, `employeeAttendanceReport` (+ `GET /v3/users/allStaffMembers`) | Typed (salary excluded) |
| 15 | Schedule planner | `bookingStatisticsReport` (U) | One U |
| 16 | Waiver and form chaser | `signedFormsReport` | Typed |
| 17 | Why people leave | `canceledMembershipsReport`, `membersOnHoldReport`, `expiringMembershipsReport` (cancel reason field) | Typed |
| 18 | Ask your studio anything | none (uses user and schedule operations) | n/a |
| 19 | Daily briefing | `birthdayReport`, `expiringSessionsReport` | Typed |
| 20 | Data tidy-up | `membersPropertiesReport` | Typed (fuzzy name) |
| 21 | Compare branches | ideas 2 and 5 per key | Inherits |
| 22 | Membership mix | `activeMembershipsReport`, `salesReport` | Typed |

**Ideas with an UNTYPED dependency:** 2, 3, 5, 8, 15. Five of 22. These are the ones where the owner-journey's "probe it" note matters most. The map cannot be trusted for those until the live probe (L7) runs.

### Reports no idea uses yet (18)

Also check: the enum has 47 values, the ideas use 29, so 18 are unused. (The owner-journey text says 46 values; see Corrections.)

**Unused reports (18), by the regex check against the owner-journey text:**

| Report | Schema | What it would answer | Candidate use |
|---|---|---|---|
| `lostLeadsReport` | Typed | Which leads were lost, when, why | Lead follow-up or lost-lead reasons |
| `expiredSessionsReport` | Typed | Which packs ended and whether they were used up | Pack-expiry pair with idea 7 |
| `entranceReport` | Typed (A flag) | Who came in, when, through which gate | Gym-floor attendance; needs access-control confirmation |
| `allClientsReport` | Typed (P heavy) | Full client list with last purchase | Data tidy-up or a client roster |
| `hugimBookingReport` | Typed | Course enrollment and fill | **Kids' and course businesses (ASSUMED in owner-journey)**; strong candidate for a course idea |
| `groupMembersCoordinatorReport` | Typed | Group-membership coordinators and group size | Family or company group owners |
| `inactiveHeadMembersReport` | **U** | Probably inactive group heads | Probe first |
| `transactionsReport` | Typed | Payments succeeded or failed, by item | Payments to chase (idea 6) could use it instead of or alongside `debtReport` |
| `staffActionsReport` | Typed (S flag) | Staff audit trail | Only on owner request; privacy review |
| `restrictedMembersReport` | Typed | Restricted members | Safety or access review; meaning UNKNOWN |
| `transparentMembershipsReport` | Typed | Membership type "transparent" | **Meaning UNKNOWN**; ask Arbox |
| `transparentSessionsReport` | Typed | Session type "transparent" | **Meaning UNKNOWN**; ask Arbox |
| `futureMembershipsReport` | Typed | Memberships starting later | Forward-looking revenue |
| `futureSessionsReport` | Typed | Session packs starting later | Forward-looking pack planning |
| `attendanceExternalMembersReport` | Typed | External (guest/drop-in) attendance | "External" undefined; probe |
| `activeHugimReport` | **U** | Running courses | Probe; pairs with `hugimBookingReport` |
| `hugimRevenueReport` | **U** | Course revenue | Probe |
| `hugimRevenueByReceiptReport` | **U** | Course revenue per receipt | Probe |

**Notes for the lead (not decisions):**
- The four `hugim*` reports (`hugimBookingReport`, `activeHugimReport`, `hugimRevenueReport`, `hugimRevenueByReceiptReport`) have no owner-journey idea. The catalog's "Kids / courses" branch in `owner-journey.md` Round 2 has no matching recipe. Two of the four are UNTYPED.
- `transactionsReport` and `staffActionsReport` are the two most data-rich unused reports. One is directly useful to the payments pain point. The other is a privacy hazard.
- `transparent*` cannot be used until the meaning is known. Do not build a recipe on the name.

---

## Corrections to other docs

1. **`arbox-api.md` line 107 / `owner-journey.md` line 107:** "46 values". The enum has **47**. (`spec:/components/schemas/ReportName/enum`.)
2. **`arbox-api.md` "Reports" section:** "Its 200 response is an `anyOf` of 44 `*ReportResource` schemas". The `anyOf` has **41** entries. There are 44 `*ReportResource` schemas in the components, of which 40 are in the `anyOf` and 4 are not (`App.Http.Resources.PublicApiV3.Invoice.SalesReportResource`, `CashFlowReportResource`, `InvoiceReportResource`, `ReceiptReportResource`). The other `anyOf` entry is `MembersPropertiesReportSource`, a `Source` rather than `Resource`.
3. **`owner-journey.md` idea 17:** says `canceledMembershipsReport` has an "untyped" row shape. Wrong. Its schema `CanceledMembershipsReportResource` is typed. Only the enum-to-schema link is INFERRED.
4. **`owner-journey.md` idea 2 and idea 8:** use `bookingsReport`, which is UNTYPED. Idea 2 and idea 8 should note this.
5. **`owner-journey.md` section 2, "Hugim" ASSUMED:** the field set in `HugimBookingReportResource` supports the course reading. Upgrade from ASSUMED to INFERRED, with the field evidence.
6. **`owner-journey.md` idea 5:** names `GET /v3/finance/reports/sales` with a "31-day cap". That cap is correct for the finance endpoint. The finance `sales` response is `App.Http.Resources.PublicApiV3.Invoice.SalesReportResource`, **untyped**, so the idea's revenue fields are not spec-backed either.

---

## Live checks needed (for L7)

For each UNTYPED report, and each INFERRED mapping that the recipe depends on:
1. Call the report with the test-gym key, with and without the date params, and record the field names.
2. Check whether `fromDate`/`toDate` filter by report date or by a row date (especially `birthdayReport`).
3. Check whether `limit=500` truncates silently, and whether `extra` ever holds data.
4. Confirm `transparent*` and `restricted` meanings with Arbox.
5. Confirm what `placemark` holds in `employeeAttendanceReport`.

## Method and counts

- Enum: `components.schemas.ReportName.enum`, 47 values, read with `python3 -I`.
- Endpoint: `paths./v3/reports/{reportName}.get`. 25 parameters: 1 path (`reportName`) and 24 query, including a duplicate `reportName` query param. 200 response `anyOf`: 41 entries.
- Schemas: 45 report-named (`*ReportResource` or `*ReportSource`) in components. Each `data.items.properties` listed.
- Enum-to-schema: name matching, exact or fuzzy, as labeled. The 7 UNTYPED names have no schema with a matching stem.
- Usage: a regex over `docs/design/owner-journey.md` for each enum value. 29 used, 18 unused. `sessionsReport` is used in idea 8.
- Probes run: none. Read-only analysis; no API calls made.
- Stop rule: within the 60-minute budget.
