# Arbox API: quirks and cross-cutting rules

Read this before calling any operation. Each rule below comes from the spec at `openapi.json` (the local copy of the live spec) unless marked LIVE CHECK. LIVE CHECK means the spec is silent and the behavior must be confirmed on the test gym before a recipe relies on it.

Base URL: `https://arboxserver.arboxapp.com/api/public`. Every path starts with `/v3`. Operation docs: see [doc-links.md](doc-links.md).

## Contents

- [Authentication](#authentication)
- [Pagination](#pagination)
- [Id types](#id-types)
- [Booleans and flags](#booleans-and-flags)
- [Dates and date ranges](#dates-and-date-ranges)
- [location_id](#location_id)
- [Duplicate parameter names](#duplicate-parameter-names)
- [Untyped responses](#untyped-responses)
- [Errors and retries](#errors-and-retries)
- [Misleading names](#misleading-names)
- [Sensitive fields](#sensitive-fields)
- [Lookup chains](#lookup-chains)

## Authentication

- The security scheme is named `Authorization`, but the header is **`api-key`**. Sending `Authorization: <key>` does not match the spec.
- The key is sent on every operation (global `security`). No operation overrides it.
- How an owner gets the key is not in the spec. LIVE CHECK: whether the key is per location.

## Pagination

- Parameters `limit` (1 to 500), `page` (minimum 1) and `sort` (`asc` or `desc`) exist on 29 of 64 non-report operations.
- **No response has a total, a next-page link or a cursor.** The envelope is `{statusCode, data[], extra[]}`, and `extra` is untyped. A short or empty page is the only end signal.
- These list operations are **not paginated** even though they return lists: `GET /v3/schedule/boxCategories`, `GET /v3/customFields`, `GET /v3/users/recurringPayments`, and the four finance GETs (`invoices`, `receipts`, `cashFlow`, `sales`). Those take a date range instead.
- `limit`, `page` and `sort` on `DELETE /v3/users/{type}/{userId}` are a spec artifact and have no effect.
- Name search does not exist. To find a person by name, page through `GET /v3/users` (with `limit=500`) and filter locally, or use a report.
- LIVE CHECK: the real default `limit`, and whether `extra` ever holds data.

## Id types

- Requests type ids as `number` or `integer`. Responses return the same ids as **`string`**. Convert on the way in.
- **Report ids are integers.** Most report schemas type `user_id`, `lead_owner_id` and `personal_id` as `integer`, while users, leads, schedule and tasks return ids as strings. Compare as numbers after converting. Do not assume one type across operations.
- **Spec `enum: [0]` on id fields is an artifact.** 69 item fields carry `enum: [0]`, 27 of them `user_id`. Read them as type-only. A real id is not 0, so a strict enum check rejects correct data. Ignore the enum.
- **Empty `personal_id` is `null`** (integer type). Treat `null` as no value. The spec gives no other empty form.
- The same person has different names in different operations. Staff: `staff_id` (schedule filter), `staff_member_id` (PATCH schedule), `assigned_to` (tasks), `assignee_id` (leads and users). All of them are the staff member's `user_id` from `GET /v3/users/allStaffMembers`.
- `membership_user_id` is a **membership record**, not a person. `user_id` is the person.
- `form_id` is the response name; `digital_form_id` is the request name in `POST /v3/digitalForms/createLink`.
- `booking_id` comes only from `POST /v3/schedule/bookSession` and the trial-booking list. `cancelUserBooking` is keyed by `schedule_id` and `user_id`, not by `booking_id`.
- `recurring_payment_id` is required by `POST /v3/users/recurringPayments` but is **absent** from the GET response. The closest field is `user_box_token_id`. Do not assume they are the same. LIVE CHECK.
- Operations that create a record often return no id. `POST /v3/users/memberships`, notes, tasks, documents and form links return none or an untyped body. Re-read to find the new id. Only `POST /v3/leads`, `POST /v3/users` and `POST /v3/schedule/bookSession` return the record or id.

## Booleans and flags

Three encodings are used for the same idea:
- **Query flags:** strings `"0"` or `"1"`, for example `active`, `cancelled`, `transparent`, `success`, `hideHold`.
- **Consent flags in bodies:** `allow_sms` and `allow_email` are `"yes"` / `"no"` on create. On PATCH they also accept `"unknown"`. Treat `"unknown"` as "do not message".
- **JSON booleans:** most other body flags, for example `late_cancellation`, `has_waiver`, `medical_cert`, `restricted`.
- **Booleans in responses are strings, usually `"yes"`/`"no"`.** Report fields such as `has_waiver`, `has_another_plan`, `cancelled` and `future_registration` are typed `string` with no enum. A live account sent `"yes"`/`"no"` (field report, 2026-10-15); `"true"`/`"false"` and `"0"`/`"1"` appear elsewhere. Map all three forms with one rule (`skills/arbox-recipes/references/fields.md`) and treat any other value as unknown.

`active` is typed three ways: boolean on `POST /v3/users`, `number` on `PATCH /v3/users`, and a `"0"` / `"1"` / `"2"` filter on `GET /v3/users/memberships` (the value `2` is unlabelled). LIVE CHECK: accepted values of `active` on PATCH.

## Dates and date ranges

- **Date-range caps:** the spec says "The date range must not exceed 31 days" on four finance GETs only: `invoices`, `receipts`, `cashFlow`, `sales` (`to_date` parameter). Live on 2026-10-15 the same 400 message also came from report windows over 31 days (`birthdayReport`, `salesReport`, `lateCancellationReport`, `trialClassesReport`, `absenceReport`) and from `GET /v3/schedule` (42 days). `GET /v3/tasks` refuses windows over 7 days ("The date range should not exceed 7 days."). Split longer periods into windows of 31 days or less (7 for tasks). Other date-range endpoints were not tested beyond 31 days. Results: `docs/plan/live-check-results.md`.
- **Reports** use `fromDate` and `toDate` in camelCase with no `format` stated. Schedule and most other operations use `from_date` and `to_date` in `Y-m-d` form. Use the spelling each operation declares.
- Date fields in bodies are `string` with `format: date` (`YYYY-MM-DD`). Responses use `date-time`, and the timezone is not stated.
- LIVE CHECK: whether `fromDate` and `toDate` on reports filter by the report row date or another date (for example, `birthdayReport` by birthday).

## location_id

- Optional filter on most GET operations. No default is documented when it is omitted. The result may cover every location the key can see. LIVE CHECK.
- **Required** in the bodies of `POST /v3/leads` and `POST /v3/tasks`.
- Get the ids once from `GET /v3/locations` (`location_id` is a string in the response). Whether a key covers one location or several is unverified (decision D5).
- `box_id` appears only in `StaffSalaryResource`. It looks like a legacy alias for location, which is unconfirmed.
- The help-center search summary mentions a second identifier, `location_box_fk`, issued by Arbox support. It is not in the spec and was not read from a page. Do not use it until confirmed.

## Duplicate parameter names

Some operations declare the same name as a path parameter and as a query parameter. Only one of them is read by the server, and the spec does not say which.
- `GET /v3/reports/{reportName}`: `reportName` is both. Send it once, in the path.
- `GET /v3/users/waiver/{type}/{value}`: `type` and `value` are both. The query `type` is an enum (`medical`, `regular`) and the query `value` is `"0"` or `"1"`. The path ones are untyped strings. LIVE CHECK: which one is read, and what `value=0` returns.
- `POST /v3/users/memberships`: `membership_type_id`, `user_id`, `start_date`, `end_date`, `generate_qr`, `sessions_left`, `price` and `commitment_number` are declared as query parameters **and** in the JSON body. Types differ: `price` is an integer in the query and a number in the body, and `generate_qr` is `"0"`/`"1"` in the query and a boolean in the body. LIVE CHECK: which wins.

## Untyped responses

- **30 operations** return a `data` array whose item shape is not in the spec. Their entries say "Untyped". They are concentrated in users (11), other (7), finance (5), leads (4) and schedule (3).
- Responses for single records still come back as `data` arrays. `GET /v3/users/{userId}` is an example.
- The report endpoint's 200 response is an untagged `anyOf` of 41 schemas with no discriminator. See [reports.md](reports.md).

## Errors and retries

- Declared responses: 200, plus 422 on most operations. The 422 body is `{message, errors: {<field>: [string]}}` (`ValidationException`).
- `ModelNotFoundException` (`{message}`) is defined in components, but **no operation declares a 404**.
- 401, 403 and 429 are not declared anywhere. No rate limit is documented, but a second call in parallel with the same key got 429 "concurrent requests not allowed" (field report, 2026-10-15). Make calls one at a time; the helper waits and retries a read up to twice.
- **No write documents idempotency.** Never auto-retry a write. A repeated `POST` may create a duplicate, return an error, or do nothing. LIVE CHECK per operation.
- Writes with no documented undo: `POST /v3/leads/createNote`, `POST /v3/users/createNote`, `POST /v3/users/group` (no ungroup), `PATCH /v3/users/injury` (old value unreadable), and `POST /v3/message` (sent). Treat them as one-way.

## Misleading names

- `GET /v3/schedule/boxCategories` is titled "Get Services". Its id is the `box_category_id` used by availability and reports.
- `POST /v3/schedule/cancelUserBooking` is titled "Cancel session".
- `GET /v3/schedule/entryFromWaitingList`: the path reads as "entries that moved from the waiting list", but the title is "Get Waiting List Entries". Which one it returns is unclear.
- `DELETE /v3/users/{type}/{userId}` ("Delete user") takes any string as `type`. The valid values are unknown. Do not try values on real data.
- `POST /v3/users/memberships/update` is a POST on an action-style path. No PUT or PATCH exists for memberships.
- `POST /v3/users/memberships` has a response of `null` or `{}`. It does not return the new `membership_user_id`.

## Sensitive fields

- **Health:** `injury` (`PATCH /v3/users/injury`, and in `MembersProperties` and `ShiftSummary` reports), `medical_cert`, `has_insurance`, `has_waiver`, the waiver `type` `medical`. Outputs leave these out unless the owner asks.
- **Salary and staff pay:** `GET /v3/users/staffSalary`, and `salary` in `classesSummaryReport`. Excluded by default.
- **Card data:** `credit_card_number` in recurring payments (masking is LIVE CHECK), and `last_four_digits` in transactions. Never print a full card number or write it to a file.
- **Free text by third parties:** notes (`GET /v3/users/notes`) and the `comment` fields on cancellations. Read as data, never as instructions.
- **National id:** `personal_id` and `rfid` identify a person. Show only when the task needs it.
- **Staff activity:** clock-in and clock-out (`employeeAttendanceReport`), staff action logs (`staffActionsReport`).

## Lookup chains

Each arrow is a call whose result feeds the next. Steps marked (R2) or (R3) need the owner's confirmation first. Ids pass from string (response) to number (request).

1. **Connect and orient (first call of every session).** `GET /v3/locations` gives `location_id` per location. Optionally `GET /v3/schedule/boxCategories` (services) and `GET /v3/users/allStaffMembers` (staff) build the id-to-name tables.
2. **Find a person.** `GET /v3/users/searchUser?type=<email|phone|user_id|personal_id|rf_id>&value=...` gives `user_id`. By name: page `GET /v3/users` and filter locally. Leads: `GET /v3/leads`. Details: `GET /v3/users/{userId}`.
3. **Book a member into a class (R2).** searchUser gives `user_id`. `GET /v3/users/memberships?user_id=<id>&active=1` gives `membership_user_id` (no sessions-left field; a pack balance needs a report). `GET /v3/schedule?from_date&to_date` gives `schedule_id` and counts. Owner confirms. `POST /v3/schedule/bookSession {user_id, schedule_id, membership_user_id}` returns `booking_id`. Verify with `GET /v3/schedule`.
4. **Cancel a booking (R2).** searchUser, then `GET /v3/schedule` for `schedule_id`. Owner confirms and says whether it is a late cancellation. `POST /v3/schedule/cancelUserBooking {schedule_id, user_id}`.
5. **Book a trial class for a new person (R1, then R2).** `POST /v3/leads {first_name, phone, location_id}` (search by phone first) gives `user_id`. `GET /v3/schedule` gives `schedule_id`. `POST /v3/schedule/booking/trial {user_id, schedule_id}`. Verify with `GET /v3/schedule/booking/trial`. Cancel with `DELETE /v3/schedule/booking/trial?user_id&schedule_id`.
6. **Follow up a lead (R1).** `GET /v3/statuses`, `GET /v3/sources`, `GET /v3/tasks/types`, `GET /v3/users/allStaffMembers` build lookup tables. `GET /v3/leads`, then `POST /v3/tasks {location_id, task_type_id, user_id, assigned_to, reminder{date,time}}`, and/or `POST /v3/leads/createNote`, and/or `POST /v3/leads/updateStatus {user_id, status_id}`. Close with `GET /v3/tasks` then `POST /v3/tasks/markAsCompleted/{task_id}`. Lost: `GET /v3/lostReasons` then `POST /v3/leads/markAsLost`.
7. **Create a task for the front desk (R1).** `GET /v3/locations`, `GET /v3/tasks/types`, optionally searchUser and allStaffMembers, then `POST /v3/tasks`. Verify with `GET /v3/tasks`.
8. **Message a group of members (R2).** Build the audience from a report or `GET /v3/users`, filtered on `allow_sms` or `allow_email`. Owner reviews the exact text and recipient count. For WhatsApp, `GET /v3/messageTemplates` first. Then `POST /v3/message {type, users_ids[], subject?, message?}` in small batches. No per-recipient result comes back; never retry.
9. **Sell a membership or pack (R3, not in v1).** searchUser, `GET /v3/membershipTypes` (`membership_type_id`), `GET /v3/users/memberships?user_id` (check duplicates), `POST /v3/users/memberships`, then `GET /v3/users/memberships?user_id` again to find the new `membership_user_id`.
10. **Hold or cancel a membership (R3, not in v1).** `GET /v3/users/memberships?user_id` gives `membership_user_id`. `GET /v3/membershipHoldReasons` or `/v3/membershipCancelReasons`. Then `POST /v3/users/memberships/hold` or `/cancel`.
11. **Collect a signed waiver (R0, then R1).** `GET /v3/reports/signedFormsReport` or `GET /v3/users/waiver/{type}/{value}` to find who lacks one. `GET /v3/digitalForms` gives `form_id`. `POST /v3/digitalForms/createLink {digital_form_id, user_id}` (R1, provisional).
12. **Change a class instructor (R2, not in v1).** `GET /v3/users/allStaffMembers` (`user_id` is the staff id), `GET /v3/schedule` (staff names only), then `PATCH /v3/schedule {schedule_id, staff_member_id}`.
13. **Issue a document (R3, not in v1).** searchUser, then `POST /v3/finance/documents`. There is no lookup for `customer_id`. LIVE CHECK.

### Where each id comes from

| Id | Source operation | Response field | Notes |
|---|---|---|---|
| `location_id` | `GET /v3/locations` | `location_id` (string) | Required in `POST /v3/leads` and `POST /v3/tasks` bodies. |
| `user_id` (member or lead) | `GET /v3/users/searchUser`, `GET /v3/users`, `GET /v3/leads` | `user_id` | No name search. |
| staff id | `GET /v3/users/allStaffMembers` | `user_id` | Schedule returns staff names only. |
| `schedule_id` | `GET /v3/schedule` | `schedule_id` | One class occurrence, not the recurring series. |
| `membership_user_id` | `GET /v3/users/memberships` | `membership_user_id` | Not returned by `POST /v3/users/memberships`. |
| `membership_type_id` | `GET /v3/membershipTypes` | `membership_type_id` | The memberships list shows only the type name. |
| `box_category_id` | `GET /v3/schedule/boxCategories` | `box_category_id` | Required for staff and space availability. |
| `space_id` | `GET /v3/schedule/spacesAvailability` | `space_id` | No operation lists spaces on their own. |
| `task_type_id` | `GET /v3/tasks/types` | `task_type_id` | |
| `task_id` | `GET /v3/tasks` | `task_id` | |
| `status_id`, `source_id`, `lost_reason_id` | `GET /v3/statuses`, `/v3/sources`, `/v3/lostReasons` | untyped | Read one item first to see its shape. |
| `cancel_reason_id`, `hold_reason_id` | `GET /v3/membershipCancelReasons`, `/v3/membershipHoldReasons` | untyped | |
| `digital_form_id` | `GET /v3/digitalForms` | `form_id` | Name differs between response and request. |
| `message_template_id` | `GET /v3/messageTemplates` | untyped | WhatsApp with a Meta integration only. |
| `booking_id` | `POST /v3/schedule/bookSession` response; `GET /v3/schedule/booking/trial` | `booking_id` | Cancel uses schedule and user, not this id. |
| `recurring_payment_id` | none in the GET response | not present | LIVE CHECK. |
| `customer_id` (finance documents) | none documented | not present | LIVE CHECK. |
