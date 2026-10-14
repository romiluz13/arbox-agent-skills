# Arbox API: the 64 non-report operations, one by one

Owner: Matt | Route: Research | Author: Sonnet (T4) | 2026-10-14

Source: `docs/research/arbox-openapi.json` (the live `https://arboxserver.arboxapp.com/docs/api.json`, same content). The 47 report variants of `GET /v3/reports/{reportName}` are covered separately (T3). This file feeds the `arbox-api` skill references.

**Coverage: 64 of 64 non-report operations (36 GET reads, 28 writes), each with a risk tier.** Counts by tag: Users 23, Schedule 12, Leads 10, Finance 6, Membership Types 3, Tasks 4, Message 2, Digital Forms 2, Custom Fields 1, Locations 1.

Facts below come from the spec. Everything the spec does not say is marked **LIVE CHECK** and is not inferred. Nothing here was run against the live API; no request was sent (see Verification).

## How to read an entry

- **Tier** uses the definitions in `docs/design/owner-journey.md`: **R0** read-only. **R1** reversible internal write (notes, tasks, lead status, create a lead). **R2** member-facing or hard to undo (messages, bookings, instructor change, edits to a person). **R3** money, identity or delete: never agent-executed in v1.
- **Data** = sensitivity of what the call returns or writes: **S0** studio configuration, **S1** personal contact data, **S2** health, national ID, salary, payment or finance data. S1 and S2 reads stay out of chat and go to files by default.
- **Tier caveat:** most R1/R2 writes in this API have no undo operation (no delete note, delete task, ungroup, unhold). "Reversible" below means reversible by another documented call; where none exists the entry says so.
- Types: requests take ids as `number`/`integer`; responses return the same ids as `string`. Convert on the way in. Path ids are strings.
- `limit` max 500; `page` min 1; `sort` asc|desc on the paginated lists. The envelope has no total or next-page field, so a short or empty page is the only end signal.

## Cross-cutting facts verified in this pass

1. **Error shapes are documented for 422, contrary to `arbox-api.md` ("No error schema is defined").** `components.responses.ValidationException` = `{message: string, errors: {<field>: [string]}}`. `ModelNotFoundException` = `{message}` also exists in components, but **none of the 64 operations references a 404** (only 200 and 422 are declared). 401, 403 and 429 are declared nowhere.
2. Operations declaring **no 422**: `GET /v3/customFields`, `POST /v3/tasks/markAsCompleted/{task_id}`, `GET /v3/users/{userId}`. Their failure behavior is unknown.
3. Pagination params (`limit`, `page`, `sort`) appear on 29 of 64 operations. **Not paginated although they return lists:** GET /v3/schedule/boxCategories, GET /v3/customFields, GET /v3/users/recurringPayments and the four GET /v3/finance/reports/{invoices,receipts,cashFlow,sales} (these take a date range instead). Pagination params also sit on `DELETE /v3/users/{type}/{userId}`, where they are meaningless (spec artifact).
4. Responses are mostly typed per resource, but **30 operations return an untyped `data` array** (marked "Untyped" below). Single-record endpoints still return `data` as an array.
5. **Idempotency is documented for none of the 28 writes.** The "safe to retry" column in the matrix near the end is therefore all LIVE CHECK. Rule for the executor: never auto-retry a write.
6. **No operation returns the id of what it just created, except** POST /v3/leads, POST /v3/users (both return the record) and POST /v3/schedule/bookSession (returns `booking_id`). Tasks, notes, memberships, documents and form links do not (or are untyped); re-read to find them.
7. **Id naming drift for the same person or staff member:** `user_id` (person), `staff_id` / `staff_member_id` / `assigned_to` / `assignee_id` (staff = a person `user_id`), `head_user_id`, `member_user_ids`, `users_ids`. `membership_user_id` is a membership record, not a person. `form_id` (responses) vs `digital_form_id` (request).

### Tier summary

| Tier | Count | Operations |
|---|---|---|
| R0 | 36 | all 36 GET operations |
| R1 | 9 | `POST /v3/digitalForms/createLink`; `POST /v3/leads`; `POST /v3/leads/updateStatus`; `POST /v3/leads/markAsLost`; `POST /v3/leads/createNote`; `POST /v3/tasks`; `POST /v3/tasks/markAsCompleted/{task_id}`; `POST /v3/users/memberships/qr`; `POST /v3/users/createNote` |
| R2 | 11 | `POST /v3/message`; `POST /v3/schedule/booking/trial`; `DELETE /v3/schedule/booking/trial`; `PATCH /v3/schedule`; `POST /v3/schedule/bookSession`; `POST /v3/schedule/cancelUserBooking`; `POST /v3/users/memberships/document`; `POST /v3/users`; `PATCH /v3/users`; `PATCH /v3/users/injury`; `POST /v3/users/profileImage` |
| R3 | 8 | `POST /v3/finance/documents`; `POST /v3/users/memberships/cancel`; `POST /v3/users/memberships/update`; `POST /v3/users/memberships/hold`; `POST /v3/users/memberships`; `POST /v3/users/recurringPayments`; `POST /v3/users/group`; `DELETE /v3/users/{type}/{userId}` |

---

## Users (23)

### GET `/v3/users`

**operationId:** Get All Users | **Tier: R0** | **Data: S1** | **Purpose:** List people in the studio, one page at a time (use it to browse or to build an audience).

Parameters:
- query `active`, **optional**, enum '0'|'1' - Filter by active status (example `1`)
- query `location_id`, **optional**, integer - Location ID
- query `only_clients`, **optional**, enum '0'|'1' - Only clients (example `1`)
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `UsersResource` envelope `{statusCode, data[], extra[]}`. Item fields: `allow_sms`, `allow_email`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `active`, `gender`, `user_role`, `image_url`, `custom_field_value`.

Preconditions: None. `location_id` from GET /v3/locations only if the key spans several locations.

Quirks:
- No name or date filters: finding 'Dana' means paging through everyone and filtering locally.
- `only_clients=1` is the only role filter; its exact meaning is not described.
- Response has no membership, birthday or last-visit fields. Use `/v3/users/memberships` or reports for those.
- `active` is a '0'/'1' string here.

LIVE CHECK:
- Does omitting `only_clients` include leads and staff? Values of `user_role`.
- Default `limit` and what `sort` sorts by.
- How to detect the last page (no total in the envelope).

### PATCH `/v3/users`

**operationId:** Update user | **Tier: R2** | **Data: S1** | **Purpose:** Change a member's details (contact info, status, consent flags, assignee).

Pagination: none.
Body (JSON, required):
- `user_id` **required**, integer
- `first_name`, string
- `last_name`, string
- `assignee_id`, number|null
- `location_id`, number
- `email`, string|null
- `active`, number
- `phone`, string|null
- `additional_phone`, string|null
- `gender`, enum 'male'|'female'|'other'
- `personal_id`, string|null
- `birthday`, string|null (date)
- `allow_sms`, enum 'yes'|'no'|'unknown' or null
- `allow_email`, enum 'yes'|'no'|'unknown' or null
- `has_waiver`, boolean|null
- `medical_cert`, boolean|null
- `restricted`, boolean|null
- `restricted_time`, string|null
- `address`, string|null
- `city`, string|null
- `country`, string|null
- `rfid`, string|null
- `customFields`, array|null
Response 200: `UsersResource` envelope `{statusCode, data[], extra[]}`. Item fields: `allow_sms`, `allow_email`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `active`, `gender`, `user_role`, `image_url`, `custom_field_value`.

Preconditions: `user_id` (searchUser). Read the current record first (GET /v3/users/{userId}) and keep the old values so the change can be reverted by hand.

Quirks:
- Only `user_id` is required, which suggests a partial update, but the spec does not say.
- `active` is a `number` (not boolean, not '0'/'1' string). Accepted values undocumented.
- `allow_sms` / `allow_email` accept 'unknown' here only.
- `email`, `phone`, `birthday` etc. are nullable: sending null may clear a value.
- Only on this endpoint: `rfid`, `assignee_id`.
- v1 policy suggestion: never agent-set consent flags (`allow_*`), `active`, `email` or `phone` without an explicit owner instruction naming the person and the field.

LIVE CHECK:
- Partial vs full replace; omitted vs null handling.
- Accepted values of `active`.
- Whether re-sending the same body is a harmless no-op (idempotency).

### POST `/v3/users`

**operationId:** Create New User | **Tier: R2** | **Data: S1** | **Purpose:** Create a member record.

Pagination: none.
Body (JSON, required):
- `first_name` **required**, string
- `last_name` **required**, string
- `location_id`, number|null
- `email`, string
- `active`, boolean|null
- `phone`, string|null
- `additional_phone`, string|null
- `gender`, enum 'male'|'female'|'other'
- `personal_id`, string|null
- `birthday`, string|null (date)
- `allow_sms`, enum 'yes'|'no' or null
- `allow_email`, enum 'yes'|'no' or null
- `has_waiver`, boolean|null
- `medical_cert`, boolean|null
- `restricted`, boolean|null
- `restricted_time`, string|null
- `address`, string|null
- `city`, string|null
- `country`, string|null
- `send_welcome_email`, boolean|null
- `customFields`, array|null
Response 200: `UsersResource` envelope `{statusCode, data[], extra[]}`. Item fields: `allow_sms`, `allow_email`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `active`, `gender`, `user_role`, `image_url`, `custom_field_value`.

Preconditions: `location_id` from GET /v3/locations. Run GET /v3/users/searchUser (type=email, then phone) first to avoid a duplicate.

Quirks:
- `last_name` and `email` are required here but optional on lead create.
- `active` is boolean here but `number` in PATCH /v3/users.
- `allow_sms` / `allow_email` take 'yes'/'no' (not booleans, not 'unknown').
- `send_welcome_email` (boolean) is member-facing: set it explicitly, never leave it to a default.
- `customFields` is an untyped array (item shape undefined); camelCase unlike the other fields.
- Response is `UsersResource`, so `data[0].user_id` is the new id (string).

LIVE CHECK:
- Behavior when the email or phone already exists (duplicate, 422, or merge). This is also the idempotency answer.
- Default of `send_welcome_email` and whether it is sent immediately.
- Whether `location_id: null` falls back to the key's location.

### GET `/v3/users/allStaffMembers`

**operationId:** Get staff members | **Tier: R0** | **Data: S1** | **Purpose:** List coaches and staff.

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `StaffMemberResource` envelope `{statusCode, data[], extra[]}`. Item fields: `user_id`, `first_name`, `last_name`, `email`, `birthday`, `created_at`, `phone`, `location_id`, `active`, `gender`, `user_role`, `image_url`, `allow_sms`, `allow_email`.

Preconditions: None.

Quirks:
- Staff `user_id` is the id other endpoints call `staff_id` (GET /v3/schedule, staffAvailability), `staff_member_id` (PATCH /v3/schedule), `assigned_to` (POST /v3/tasks) and `assignee_id` (leads, users). Same number, five names.
- `user_role` values undocumented.

LIVE CHECK:
- Whether inactive staff are included (no `active` filter param).
- `user_role` values.

### POST `/v3/users/createNote`

**operationId:** Create user note | **Tier: R1** | **Data: S1** | **Purpose:** Add an internal note to a member's record.

Pagination: none.
Body (JSON, required):
- `description` **required**, string
- `user_id` **required**, number
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `user_id` (searchUser).

Quirks:
- Append-only as far as the API goes: there is no delete or edit note operation, so a wrong note cannot be undone through the API.
- Read back with GET /v3/users/notes (needs `user_id`).
- Same body as POST /v3/leads/createNote.

LIVE CHECK:
- Whether the note is visible to the member.
- Whether a lead id works here, or only leads/createNote.
- Duplicate notes on retry (no idempotency documented).

### POST `/v3/users/group`

**operationId:** Group users | **Tier: R3** | **Data: S1** | **Purpose:** Link members into a group under one head member (e.g. a family).

Pagination: none.
Body (JSON, required):
- `head_user_id` **required**, number
- `membership_user_id`, number|null
- `ignore_grouped_users`, boolean|null
- `member_user_ids` **required**, array of number
Response 200: `GroupResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: All ids from searchUser; its response shows `group_id` and `is_head_of_group` to detect existing groups.

Quirks:
- Body: `head_user_id`, `member_user_ids` (number[], no maxItems), optional `membership_user_id` (number|null) and `ignore_grouped_users`.
- Response `GroupResource` is untyped.
- No ungroup operation exists in the API, so the action cannot be reversed through it. `membership_user_id` here is a membership record id, not a person id.

LIVE CHECK:
- Whether grouping merges billing or memberships.
- What `ignore_grouped_users` skips.
- Reversibility.

### PATCH `/v3/users/injury`

**operationId:** Create or update injury | **Tier: R2** | **Data: S2** | **Purpose:** Set a member's injury note.

Pagination: none.
Body (JSON, required):
- `user_id` **required**, number
- `injury` **required**, string
Response 200: `UserInjuryResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `user_id`. There is no endpoint to read the current injury, so the previous text cannot be saved first.

Quirks:
- 'Create or update': likely overwrites. Because the old value is unreadable through the API, treat as an unrecoverable overwrite.
- Health data. Out of v1 scope by privacy default (owner-journey Q5).

LIVE CHECK:
- Overwrite vs append.
- Whether the note is visible to the member or only to staff.

### GET `/v3/users/memberships`

**operationId:** Get User Memberships | **Tier: R0** | **Data: S1** | **Purpose:** List a person's memberships and packs (or everyone's).

Parameters:
- query `active`, **optional**, enum '0'|'1'|'2' - Filter by active status
- query `location_id`, **optional**, integer - Location ID
- query `type`, **optional**, string - Type
- query `user_id`, **optional**, integer - User id
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `MembershipUserResource` envelope `{statusCode, data[], extra[]}`. Item fields: `membership_user_id`, `membership_type_name`, `type`, `price`, `debt`, `start_time`, `end_time`, `user_id`, `full_name`, `phone`, `email`, `active`, `created_at`, `cancelled`.

Preconditions: `user_id` (searchUser) to scope it.

Quirks:
- Response has `membership_user_id`, `membership_type_name`, `type`, `price`, `debt`, `start_time`, `end_time`, `active`, `cancelled`. **No sessions-left field and no `membership_type_id`.** Pack balances need a report (expiringSessionsReport etc.).
- `membership_user_id` is the id used by bookSession, update, cancel, hold, qr and document.
- `active` filter takes '0', '1' or '2' (the third value is unlabelled).
- `type` filter is an untyped string.

LIVE CHECK:
- Meaning of `active=2` and of the `type` filter.
- Whether omitting `user_id` returns the whole studio (and how many).

### POST `/v3/users/memberships`

**operationId:** Create User Membership | **Tier: R3** | **Data: S2** | **Purpose:** Sell or assign a membership or pack to a person.

Parameters:
- query `commitment_number`, **optional**, string - Commitment number
- query `end_date`, **optional**, string - End date
- query `generate_qr`, **optional**, enum '0'|'1' - Generate qr (example `1`)
- query `membership_type_id`, **required**, integer - Membership type id
- query `price`, **optional**, integer - Price
- query `sessions_left`, **optional**, integer - Sessions left
- query `start_date`, **optional**, string - Start date
- query `user_id`, **required**, integer - User id
Pagination: none.
Body (JSON, required):
- `membership_type_id` **required**, integer
- `user_id` **required**, integer
- `start_date`, string (date)
- `end_date`, string (date)
- `generate_qr`, boolean
- `sessions_left`, number|null
- `price`, number|null
- `commitment_number`, string|null
Response 200: anyOf `null` / `{}`: **no response shape is documented**

Preconditions: `membership_type_id` from GET /v3/membershipTypes; `user_id` from searchUser. Before calling, read GET /v3/users/memberships?user_id= to see what they already hold.

Quirks:
- **Parameters are defined twice**: as query params AND in the JSON body (same names: membership_type_id, user_id, start_date, end_date, generate_qr, sessions_left, price, commitment_number). Types differ: query `price` is integer, body `price` is number; query `generate_qr` is '0'/'1', body is boolean.
- Only `membership_type_id` and `user_id` are required. Whether `price` / `sessions_left` override the membership type's own values when given is not stated.
- Response schema is `null | {}`: the new `membership_user_id` is not returned. Re-read GET /v3/users/memberships?user_id= to find it.

LIVE CHECK:
- Whether query or body wins, and whether both are needed.
- Whether it charges a card, creates an invoice or changes `debt`.
- Duplicate behavior if called twice (idempotency).

### POST `/v3/users/memberships/cancel`

**operationId:** Cancel user membership | **Tier: R3** | **Data: S2** | **Purpose:** Cancel a membership on a chosen date, with a reason.

Pagination: none.
Body (JSON, required):
- `membership_user_id` **required**, number
- `cancellation_date` **required**, string (date)
- `cancel_reason_id` **required**, number
- `comment`, string|null
- `billing_cycle`, number|null
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `membership_user_id` (GET memberships); `cancel_reason_id` from GET /v3/membershipCancelReasons.

Quirks:
- Required: `membership_user_id`, `cancellation_date` (date), `cancel_reason_id`. Optional: `comment`, `billing_cycle` (number|null, meaning undocumented).
- Whether a future date schedules the cancel or applies immediately is not stated.

LIVE CHECK:
- Future-dated vs immediate effect.
- Meaning of `billing_cycle`.
- Whether a cancelled membership can be reinstated through the API.

### POST `/v3/users/memberships/document`

**operationId:** Attach commitment document to membership | **Tier: R2** | **Data: S2** | **Purpose:** Attach a signed commitment document to a membership.

Pagination: none.
Body (JSON, required):
- `membership_user_id` **required**, integer - Membership to attach the document to.
- `form_id` **required**, integer - Commitment document to attach, as returned by the signed forms report.
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `membership_user_id` (GET memberships); `form_id` from the signedFormsReport, per the field description.

Quirks:
- Both ids are `integer` here.
- `GET /v3/digitalForms` also returns a `form_id`. The description says this one comes from the **signed forms report**; whether the two ids are the same kind is unknown.

LIVE CHECK:
- Which `form_id` is accepted (form template vs signed instance).
- Reversibility (no detach operation exists).

### POST `/v3/users/memberships/hold`

**operationId:** Suspend user membership | **Tier: R3** | **Data: S2** | **Purpose:** Freeze a membership between two dates, with a reason.

Pagination: none.
Body (JSON, required):
- `membership_user_id` **required**, number
- `hold_start_date` **required**, string (date)
- `hold_end_date` **required**, string (date)
- `hold_reason_id` **required**, number
- `comment`, string|null
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `membership_user_id` (GET memberships); `hold_reason_id` from GET /v3/membershipHoldReasons.

Quirks:
- Required: `membership_user_id`, `hold_start_date`, `hold_end_date`, `hold_reason_id`. Optional `comment`.
- No 'unhold' operation exists; the way to end a hold early is unknown (maybe the update endpoint).

LIVE CHECK:
- How to end or shorten a hold.
- Effect on billing and on already-booked classes.

### POST `/v3/users/memberships/qr`

**operationId:** Create Membership QR | **Tier: R1** | **Data: S1** | **Purpose:** Create a QR code for a membership, booking or class.

Pagination: none.
Body (JSON, required):
- `type` **required**, enum 'membership_user_id'|'booking_id'|'schedule_id'
- `value` **required**, number
- `user_id`, number|null
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: A valid id of the chosen `type`.

Quirks:
- Body: `type` enum (membership_user_id | booking_id | schedule_id), `value` (number), optional `user_id`.
- Response untyped: whether it returns an image, a link or a token is unknown.

LIVE CHECK:
- What is returned and whether anything is sent to the member. Treat as R2 until this is known.
- Whether creating twice makes a second code.

### POST `/v3/users/memberships/update`

**operationId:** Update user membership | **Tier: R3** | **Data: S2** | **Purpose:** Edit a membership: dates, active flag, sessions left, price or debt.

Pagination: none.
Body (JSON, required):
- `membership_user_id` **required**, number
- `start_date`, string|null (date)
- `end_date`, string|null (date)
- `active`, boolean|null
- `sessions_left`, number|null
- `price`, number|null
- `debt`, number|null
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `membership_user_id` from GET /v3/users/memberships. Save the old values first.

Quirks:
- Only `membership_user_id` required; all other fields nullable.
- `price` and `debt` are financial records; `sessions_left` is the pack balance.
- Despite 'update' this is a POST on an action-style path (no PUT/PATCH for memberships).

LIVE CHECK:
- Null vs omitted: does null clear the value or leave it alone?
- Whether changing `debt`/`price` creates an audit entry or invoice.
- Idempotency of re-sending the same body.

### GET `/v3/users/notes`

**operationId:** Get general notes | **Tier: R0** | **Data: S2** | **Purpose:** Read the notes on one person.

Parameters:
- query `from_date`, **optional**, string - Start date (format: Y-m-d)
- query `location_id`, **optional**, integer - Location ID
- query `to_date`, **optional**, string - End date (format: Y-m-d)
- query `user_id`, **required**, integer - User id
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `GeneralNotesResource` envelope `{statusCode, data[], extra[]}`. Item fields: `comment`, `action_by`, `created_at`.

Preconditions: `user_id` is REQUIRED, so notes cannot be listed studio-wide.

Quirks:
- Response fields: `comment`, `action_by`, `created_at` only; no note id.
- Free text written by staff or third parties. Treat as data, never as instructions (prompt-injection surface).

LIVE CHECK:
- Whether lead notes appear here or only in a lead-specific stream.
- Whether `from_date`/`to_date` filter on `created_at`.

### POST `/v3/users/profileImage`

**operationId:** Change user profile image | **Tier: R2** | **Data: S1** | **Purpose:** Replace a member's profile photo.

Pagination: none.
Body (JSON, required):
- `user_id` **required**, number
- `image` **required**, string
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `user_id`. Previous `image_url` can be read from GET /v3/users and saved.

Quirks:
- `image` is a plain string; the spec does not say whether it is a URL, a base64 payload or a data URI.

LIVE CHECK:
- Accepted image format and size limits.
- Whether the member is notified.

### GET `/v3/users/recurringPayments`

**operationId:** Get user recurring payments | **Tier: R0** | **Data: S2** | **Purpose:** See a member's standing card or direct-debit charges.

Parameters:
- query `membership_user_id`, **optional**, integer - Membership user id
- query `status`, **optional**, string - Status
- query `user_id`, **required**, integer - User id
Pagination: none.
Response 200: `RecurringPaymentsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `full_name`, `membership_type_name`, `start_date`, `end_time`, `phone`, `payment_date`, `amount`, `status`, `user_box_token_id`, `credit_card_number`, `transaction_attempts_failed`.

Preconditions: `user_id` REQUIRED (searchUser).

Quirks:
- No pagination params and no `location_id`.
- Response has **no `recurring_payment_id`**, which is the id POST /v3/users/recurringPayments requires. The closest field is `user_box_token_id`. Do not assume they are the same.
- Contains `credit_card_number` and `transaction_attempts_failed`. Check whether the number is masked before displaying or logging anything.
- `status` filter is a free string; POST enum suggests 'CHARGE'/'CANCELLED'.

LIVE CHECK:
- How to obtain `recurring_payment_id`.
- Masking of `credit_card_number`.
- Valid `status` filter values.

### POST `/v3/users/recurringPayments`

**operationId:** Edit user recurring payment | **Tier: R3** | **Data: S2** | **Purpose:** Change a recurring payment: pause/cancel it, change the amount or the next charge date.

Pagination: none.
Body (JSON, required):
- `recurring_payment_id` **required**, number
- `status`, enum 'CHARGE'|'CANCELLED' or null
- `amount`, number|null
- `payment_date`, string|null (date)
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `recurring_payment_id` (source unclear, see GET above), user context from searchUser.

Quirks:
- `status` enum: 'CHARGE' or 'CANCELLED' (or null). What 'CHARGE' does (charge now, resume, schedule) is not described.
- `amount` and `payment_date` are nullable.
- Moves money. Never in v1.

LIVE CHECK:
- Meaning of 'CHARGE'.
- Reversibility and whether the member is notified.

### GET `/v3/users/searchUser`

**operationId:** Search user | **Tier: R0** | **Data: S2** | **Purpose:** Find one person by phone, email, national ID or access card.

Parameters:
- query `location_id`, **optional**, integer - Location ID
- query `type`, **required**, enum 'email'|'phone'|'user_id'|'personal_id'|'rf_id' - Type
- query `value`, **required**, string - Value
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `SearchUsersResource` envelope `{statusCode, data[], extra[]}`. Item fields: `user_id`, `first_name`, `last_name`, `email`, `phone`, `box_name`, `location_name`, `birthday`, `gender`, `additional_phone`, `active`, `allow_sms`, `allow_email`, `has_waiver`, `medical_cert`, `user_type`, `personal_id`, `deleted_at`, `user_role`, `status_name`, `country`, `state`, `address`, `has_nutrition_counseling`, `has_professional_meeting`, `campaign`, `status`, `lost_reason_name`, `lead_source`, `rfid`, `group_id`, `is_head_of_group`, `image_public_id_cloudinary`, `suspended`, `restricted`, `weight`, `height`, `employee_id`, `role_name`, `profile_link`, `custom_field_value`.

Preconditions: None.

Quirks:
- **No name search.** `type` is an enum: email, phone, user_id, personal_id, rf_id. To find someone by name you must page through GET /v3/users (or a report) and filter locally.
- `rf_id` here but `rfid` in the response and in PATCH /v3/users.
- Richest user record in the API: leads and staff fields too (`status_name`, `lost_reason_name`, `lead_source`, `role_name`), `group_id`, `is_head_of_group`, `deleted_at`, `suspended`, `restricted`, `weight`, `height`, `personal_id`. Display only what the task needs.
- `value` is a string for every `type`.

LIVE CHECK:
- Phone normalization (05x vs +972, spaces, dashes).
- Exact vs partial match; whether it returns several people.
- Whether it returns deleted people (`deleted_at` is in the response).

### GET `/v3/users/staffSalary`

**operationId:** Get Staff Salary | **Tier: R0** | **Data: S2** | **Purpose:** Read a staff member's pay tiers per class type.

Parameters:
- query `location_id`, **optional**, integer - Location ID
- query `user_id`, **required**, integer - User id
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `StaffSalaryResource` envelope `{statusCode, data[], extra[]}`. Item fields: `salary_id`, `box_id`, `box_category_id`, `box_category_name`, `min_participants`, `max_participants`, `salary`, `created_at`, `updated_at`.

Preconditions: `user_id` REQUIRED, from allStaffMembers.

Quirks:
- Fields: `box_category_id`, `min_participants`, `max_participants`, `salary`. Looks like a pay-per-class-size table; the meaning is inferred from field names only.
- `box_id` appears here only; probably a legacy alias of location (unconfirmed).
- Salary data: excluded by default (owner-journey Q5).

LIVE CHECK:
- Meaning of the min/max participants tiers.
- Whether `box_id` equals `location_id`.

### GET `/v3/users/waiver/{type}/{value}`

**operationId:** Get users with waiver | **Tier: R0** | **Data: S2** | **Purpose:** List people who have (or lack) a signed waiver or medical certificate.

Parameters:
- path `type`, **required**, string
- path `value`, **required**, string
- query `active`, **optional**, enum '0'|'1' - Filter by active status (example `1`)
- query `location_id`, **optional**, integer - Location ID
- query `type`, **required**, enum 'medical'|'regular' - Type
- query `value`, **required**, enum '0'|'1' - Value (example `1`)
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `UsersResource` envelope `{statusCode, data[], extra[]}`. Item fields: `allow_sms`, `allow_email`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `active`, `gender`, `user_role`, `image_url`, `custom_field_value`.

Preconditions: None.

Quirks:
- **Duplicate params**: `type` and `value` are both path params (untyped strings) and required query params (`type` enum medical|regular, `value` enum '0'|'1'). The URL needs the path segments, so the first thing to try is the same values in both places. That is a candidate to test, not a documented fact.
- Returns the generic `UsersResource` (no waiver date, no document link).
- `active` filter is a '0'/'1' string.

LIVE CHECK:
- Which of path/query the server reads, and whether they must agree.
- Whether `value=0` lists people WITHOUT a waiver (the obvious use) or something else.
- Meaning of 'regular' vs 'medical'.

### DELETE `/v3/users/{type}/{userId}`

**operationId:** Delete user | **Tier: R3** | **Data: S1** | **Purpose:** Delete a person record.

Parameters:
- path `type`, **required**, string
- path `userId`, **required**, string
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `userId` from searchUser. `type` is unknown (see LIVE CHECK).

Quirks:
- `type` is a free-form string path param. The spec gives no enum and no description.
- The spec attaches list params (`limit`, `page`, `sort`) to this DELETE; they look like a copy-paste artifact and mean nothing here.
- `searchUser` returns a `deleted_at` field, which suggests soft deletion exists. That is an observation, not a confirmed behavior.
- No endpoint restores or lists deleted people through the documented API.

LIVE CHECK:
- Valid values and meaning of `type`. Test only on a disposable record in the test gym, never on real data.
- Soft vs hard delete, and what happens to the person's memberships, bookings and invoices.
- Response when the user is already gone.

### GET `/v3/users/{userId}`

**operationId:** Get user by id | **Tier: R0** | **Data: S1** | **Purpose:** Get one person's basic record by id.

Parameters:
- path `userId`, **required**, string
Pagination: none.
Response 200: `UsersResource` envelope `{statusCode, data[], extra[]}`. Item fields: `allow_sms`, `allow_email`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `active`, `gender`, `user_role`, `image_url`, `custom_field_value`.

Preconditions: `userId` from searchUser, GET /v3/users or a report.

Quirks:
- `data` is an array even for one record.
- Spec declares no 422 and no 404 for this operation.
- Same fields as the list: no memberships, no birthday.

LIVE CHECK:
- What an unknown id returns (empty array, 404 with `ModelNotFoundException`, or 422).
- Whether a lead id works here.

## Schedule (12)

### GET `/v3/schedule`

**operationId:** Get Schedule | **Tier: R0** | **Data: S0** | **Purpose:** See the class schedule between two dates, with how full each class is.

Parameters:
- query `box_category_id`, **optional**, integer - Box category ID
- query `cancelled`, **optional**, enum '0'|'1' - Cancelled (example `1`)
- query `from_date`, **required**, string - Start date (format: Y-m-d)
- query `location_id`, **optional**, integer - Location ID
- query `registration_count`, **optional**, enum '0'|'1' - Include registration count (example `1`)
- query `registration_details`, **optional**, enum '0'|'1' - Include registration details (example `1`)
- query `staff_id`, **optional**, integer - Staff id
- query `to_date`, **required**, string - End date (format: Y-m-d)
- query `transparent`, **optional**, enum '0'|'1' - Transparent (example `1`)
- query `waiting_list_count`, **optional**, enum '0'|'1' - Include waiting list count (example `1`)
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `ScheduleResource` envelope `{statusCode, data[], extra[]}`. Item fields: `color`, `max_participants`, `space_name`, `is_transparent`, `session_name`, `custom_field_value`, `schedule_id`, `date`, `start_time`, `end_time`, `location_name`, `staff_member`, `second_staff_member`, `waiting_list_count`, `registration_count`, `cancelled_status`, `cancelled_by_id`, `cancelled_by_name`, `cancellation_time`.

Preconditions: `from_date` and `to_date` are required. Optional filters: `staff_id` (allStaffMembers), `box_category_id` (boxCategories), `location_id`.

Quirks:
- Dates are plain `string` here (format Y-m-d), not `format: date`.
- `registration_count` / `waiting_list_count` / `registration_details` are opt-in '0'/'1' flags. Without them the counts are not in the response.
- Response has `max_participants`, `registration_count`, `waiting_list_count` as strings, and `staff_member` / `second_staff_member` as NAMES, not ids.
- **`registration_details=1` is accepted but `ScheduleResource` has no field for the registrants**: where the names appear is unknown (maybe `extra`).
- No documented maximum date range. `cancelled` and `transparent` meaning is not described (`is_transparent` is in the response).

LIVE CHECK:
- Where `registration_details` data appears.
- Whether `cancelled=1` returns only cancelled classes or includes them.
- What 'transparent' means.
- Maximum range per call; page through weeks until proven otherwise.

### PATCH `/v3/schedule`

**operationId:** Update Class Schedule | **Tier: R2** | **Data: S0** | **Purpose:** Change the instructor of one class occurrence.

Pagination: none.
Body (JSON, required):
- `schedule_id` **required**, number
- `staff_member_id` **required**, number
- `second_staff_member_id`, number
Response 200: `ScheduleResource` envelope `{statusCode, data[], extra[]}`. Item fields: `color`, `max_participants`, `space_name`, `is_transparent`, `session_name`, `custom_field_value`, `schedule_id`, `date`, `start_time`, `end_time`, `location_name`, `staff_member`, `second_staff_member`, `waiting_list_count`, `registration_count`, `cancelled_status`, `cancelled_by_id`, `cancelled_by_name`, `cancellation_time`.

Preconditions: `schedule_id` (GET /v3/schedule); `staff_member_id` from GET /v3/users/allStaffMembers.

Quirks:
- Body: `schedule_id`, `staff_member_id` (both required), `second_staff_member_id`.
- GET /v3/schedule returns staff NAMES only, so the previous staff id cannot be read back from it to revert; match names against allStaffMembers (names may collide).
- Tier note: owner-journey.md idea 15 called this R3 for v1. By the tier definitions it is R2 (member- and staff-facing, no money/identity/delete). Keeping it out of v1 is a policy choice, not the tier.

LIVE CHECK:
- Whether members and the coach are notified.
- Whether it applies to one occurrence or the whole series.

### POST `/v3/schedule/bookSession`

**operationId:** Book Session | **Tier: R2** | **Data: S1** | **Purpose:** Book a member into a class.

Pagination: none.
Body (JSON, required):
- `user_id` **required**, number
- `schedule_id` **required**, number
- `membership_user_id` **required**, number
Response 200: `ScheduleUserResource` envelope `{statusCode, data[], extra[]}`. Item fields: `booking_id`, `schedule_id`, `date`, `start_time`, `end_time`, `location_name`, `staff_member`, `session_name`, `user_id`, `full_name`, `email`, `phone`, `additional_phone`, `booking_time`, `booked_by`.

Preconditions: `user_id` (searchUser), `schedule_id` (GET /v3/schedule), `membership_user_id` (GET /v3/users/memberships?user_id=).

Quirks:
- All three ids are required numbers in the body but strings in responses: convert.
- Response `ScheduleUserResource` includes `booking_id`.
- Lookup chain: searchUser -> memberships -> schedule -> bookSession (see chains).
- Cancel is keyed by `schedule_id`+`user_id`, not by `booking_id`.

LIVE CHECK:
- Whether it deducts a session or charges.
- Full class: error, waiting list or overbook.
- Booking the same person twice (idempotency).
- Whether the member is notified.

### DELETE `/v3/schedule/booking/trial`

**operationId:** Cancel Trial Booking | **Tier: R2** | **Data: S1** | **Purpose:** Cancel a trial booking.

Parameters:
- query `user_id`, **required**, number
- query `schedule_id`, **required**, number
- query `force`, **optional**, boolean
Pagination: none.
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `user_id`, `schedule_id` (both REQUIRED, as query params).

Quirks:
- Parameters travel in the query string, not a body. Optional `force` (boolean): meaning undocumented.

LIVE CHECK:
- What `force` does.
- Response when no such booking exists.

### GET `/v3/schedule/booking/trial`

**operationId:** Get Trial Class Bookings | **Tier: R0** | **Data: S1** | **Purpose:** List booked trial classes.

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `ScheduleUserResource` envelope `{statusCode, data[], extra[]}`. Item fields: `booking_id`, `schedule_id`, `date`, `start_time`, `end_time`, `location_name`, `staff_member`, `session_name`, `user_id`, `full_name`, `email`, `phone`, `additional_phone`, `booking_time`, `booked_by`.

Preconditions: None.

Quirks:
- Only `location_id` plus pagination: no date filter. Filter on `date` locally or use the trialClassesReport.
- Fields include `booking_id`, `booked_by`, `booking_time`.

LIVE CHECK:
- Default ordering (use `sort`).

### POST `/v3/schedule/booking/trial`

**operationId:** Book Trial Class | **Tier: R2** | **Data: S1** | **Purpose:** Book a lead or new person into a trial class.

Pagination: none.
Body (JSON, required):
- `user_id` **required**, number
- `schedule_id` **required**, number
- `force`, boolean
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `user_id` (a lead from POST /v3/leads or GET /v3/leads), `schedule_id`.

Quirks:
- `force` (boolean, optional): meaning undocumented. Do not set it.

LIVE CHECK:
- What `force` overrides.
- Whether the trial consumes a free-trial entitlement.
- Whether the person is notified.

### GET `/v3/schedule/boxCategories`

**operationId:** Get Services | **Tier: R0** | **Data: S0** | **Purpose:** List the studio's services (class types and appointment types).

Parameters:
- query `service_type`, **optional**, enum '1'|'2'|'4' - Service type
Pagination: none.
Response 200: `BoxCategoriesResource` envelope `{statusCode, data[], extra[]}`. Item fields: `box_category_id`, `name`, `type`, `length`, `participants_count`, `price`, `description`, `box_category_group`, `box_category_group_id`.

Preconditions: None.

Quirks:
- Titled 'Get Services' but the path says 'boxCategories'; a `box_category_id` is a class/service type.
- No `location_id`, no pagination params.
- `service_type` filter enum is '1', '2', '4' with no labels. Do not guess which is class vs private.

LIVE CHECK:
- Meaning of service types 1, 2 and 4.

### GET `/v3/schedule/boxScheduleSettings`

**operationId:** Get Schedule Settings | **Tier: R0** | **Data: S0** | **Purpose:** Read the studio's booking and cancellation rules.

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `BoxScheduleSettingsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `showing_classes_week_ago`, `showing_classes_day_ago`, `showing_classes_time_ago`, `schedule_swapping_time`, `schedule_swapping_standby_time`, `standby_time_to_approve`, `standby_cancellation_time`, `availability_time_cancellation`, `availability_enable_late_cancellation`, `cancellation_policy`.

Preconditions: None.

Quirks:
- All values are strings with units not stated: `showing_classes_week_ago`, `schedule_swapping_time`, `standby_time_to_approve`, `standby_cancellation_time`, `availability_time_cancellation`, `availability_enable_late_cancellation`, `cancellation_policy`.
- Useful to explain 'late cancellation' to the owner.

LIVE CHECK:
- Units of each time value (minutes? hours?).

### POST `/v3/schedule/cancelUserBooking`

**operationId:** Cancel session | **Tier: R2** | **Data: S1** | **Purpose:** Cancel a member's booking.

Pagination: none.
Body (JSON, required):
- `schedule_id` **required**, number
- `user_id` **required**, number
- `late_cancellation`, boolean|null
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `schedule_id`, `user_id` (both required, numbers).

Quirks:
- Titled 'Cancel session'. `late_cancellation` (boolean|null) is the only option.
- Response untyped.

LIVE CHECK:
- What `late_cancellation` does (marks it late and keeps the session charged?).
- Whether a normal cancel refunds the session.
- What happens to the waiting list.

### GET `/v3/schedule/entryFromWaitingList`

**operationId:** Get Waiting List Entries | **Tier: R0** | **Data: S1** | **Purpose:** See waiting-list entries.

Parameters:
- query `confirm`, **optional**, enum '0'|'1' - Confirm (example `1`)
- query `from_date`, **optional**, string - Start date (format: Y-m-d)
- query `location_id`, **optional**, integer - Location ID
- query `to_date`, **optional**, string - End date (format: Y-m-d)
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `ScheduleStandByResource` envelope `{statusCode, data[], extra[]}`. Item fields: `waitlist_id`, `schedule_id`, `date`, `start_time`, `staff_member`, `session_name`, `user_id`, `full_name`, `phone`, `additional_phone`, `app_link`, `time_to_approval`, `entry_time`.

Preconditions: None. `from_date` / `to_date` are optional here (no default stated).

Quirks:
- The path name reads as 'entries that moved from the waiting list'; the operationId says 'Get Waiting List Entries'. **Which one it returns is unclear**, and the journey's 'waiting-list pressure' idea depends on it.
- `confirm` ('0'/'1') meaning unknown.
- Fields: `waitlist_id`, `schedule_id`, `user_id`, `time_to_approval`, `entry_time`, `app_link`.

LIVE CHECK:
- Whether it lists people currently waiting or people who were promoted.
- Meaning of `confirm`.
- To count waiting-list size per class, GET /v3/schedule `waiting_list_count=1` is the safer source until this is settled.

### GET `/v3/schedule/spacesAvailability`

**operationId:** Get Space Availability | **Tier: R0** | **Data: S0** | **Purpose:** Find free rooms or spaces for a service.

Parameters:
- query `box_category_id`, **required**, integer - Box category ID
- query `from_date`, **required**, string - Start date (format: Y-m-d)
- query `location_id`, **optional**, integer - Location ID
- query `space_id`, **optional**, integer - Space id
- query `to_date`, **required**, string - End date (format: Y-m-d)
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `SpacesAvailabilityResource` envelope `{statusCode, data[], extra[]}`. Item fields: `space_id`, `space_name`, `location_name`, `location_id`, `phone`, `address`, `date`, `start_time`, `end_time`, `session_length`, `service_type`.

Preconditions: `box_category_id`, `from_date`, `to_date` REQUIRED.

Quirks:
- `space_id` filter exists but no operation lists spaces: ids only appear in this response.
- Response includes the space's `phone` and `address`.

LIVE CHECK:
- Whether rows are free slots only.

### GET `/v3/schedule/staffAvailability`

**operationId:** Get Staff Availability | **Tier: R0** | **Data: S1** | **Purpose:** Find open appointment slots for staff for a given service.

Parameters:
- query `box_category_id`, **required**, integer - Box category ID
- query `from_date`, **required**, string - Start date (format: Y-m-d)
- query `location_id`, **optional**, integer - Location ID
- query `staff_id`, **optional**, integer - Staff id
- query `to_date`, **required**, string - End date (format: Y-m-d)
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `StaffAvailabilityResource` envelope `{statusCode, data[], extra[]}`. Item fields: `user_id`, `first_name`, `last_name`, `phone`, `email`, `location_name`, `location_id`, `date`, `start_time`, `end_time`, `session_length`, `service_type`.

Preconditions: `box_category_id` REQUIRED (boxCategories), `from_date`, `to_date` REQUIRED.

Quirks:
- Response carries `session_length` and `service_type` but no booked/free marker, so whether rows are free slots or all slots is unknown.
- Includes staff phone and email.

LIVE CHECK:
- Whether rows are open slots only.
- How a slot found here is booked (no appointment-booking operation is documented).

## Leads (10)

### GET `/v3/leads`

**operationId:** Get All Leads | **Tier: R0** | **Data: S1** | **Purpose:** List leads (people in the sales pipeline).

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

Preconditions: None.

Quirks:
- A lead's `user_id` is a person id usable in lead operations.
- Response has `lead_source` and `lead_status` as NAMES, no ids, and **no created date**: new leads this week cannot be derived from this call. Use leadsInProcessReport / allLeadsReport.
- No date or status filters.

LIVE CHECK:
- Whether converted/lost leads are included.
- Whether the lead's `user_id` stays the same after they join.

### POST `/v3/leads`

**operationId:** Create New Lead | **Tier: R1** | **Data: S1** | **Purpose:** Add a new lead.

Pagination: none.
Body (JSON, required):
- `first_name` **required**, string
- `last_name`, string|null
- `email`, string|null
- `phone` **required**, string
- `additional_phone`, string|null
- `gender`, enum 'male'|'female'|'other'
- `location_id` **required**, number
- `source_id`, number|null
- `status_id`, number|null
- `campaign`, string|null
- `assignee_id`, number|null
- `comment`, string|null
- `birthday`, string|null (date)
- `address`, string|null
- `city`, string|null
- `country`, string|null
- `allow_sms`, enum 'yes'|'no' or null
- `allow_email`, enum 'yes'|'no' or null
- `customFields`, array|null
Response 200: `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

Preconditions: `location_id` (GET /v3/locations). Optional ids: `source_id` (GET /v3/sources), `status_id` (GET /v3/statuses), `assignee_id` (allStaffMembers). Search by phone first to avoid a duplicate.

Quirks:
- Required: `first_name`, `phone`, `location_id`.
- `allow_sms`/`allow_email` are 'yes'/'no'. `gender` enum male|female|other. `customFields` untyped.
- Response `LeadsResource`: new `user_id`.

LIVE CHECK:
- Duplicate phone behavior (and so retry safety).
- Default status and source when omitted.
- Whether a lead can be removed through the API (only DELETE /v3/users, R3).

### GET `/v3/leads/converted`

**operationId:** Get Converted Leads | **Tier: R0** | **Data: S1** | **Purpose:** List leads who became members.

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

Preconditions: None.

Quirks:
- Same `LeadsResource` shape as GET /v3/leads: no conversion date. Use convertedLeadReport for dates and revenue.

LIVE CHECK:
- Whether it returns all-time or a window.

### POST `/v3/leads/createNote`

**operationId:** Add Note to Lead | **Tier: R1** | **Data: S1** | **Purpose:** Add an internal note to a lead.

Pagination: none.
Body (JSON, required):
- `description` **required**, string
- `user_id` **required**, number
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `user_id` (lead).

Quirks:
- Same body as POST /v3/users/createNote (`description`, `user_id`). Append-only through the API.

LIVE CHECK:
- Where the note is read back (GET /v3/users/notes?user_id= for a lead id?).
- Duplicate notes on retry.

### GET `/v3/leads/lost`

**operationId:** Get Lost Leads | **Tier: R0** | **Data: S1** | **Purpose:** List leads marked lost.

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

Preconditions: None.

Quirks:
- Same `LeadsResource` shape; the lost reason is not a field. Use lostLeadsReport.

LIVE CHECK:
- Whether it returns all-time or a window.

### POST `/v3/leads/markAsLost`

**operationId:** Mark Lead as Lost | **Tier: R1** | **Data: S1** | **Purpose:** Mark a lead as lost, with a reason.

Pagination: none.
Body (JSON, required):
- `user_id` **required**, number
- `lost_reason_id` **required**, number
- `comment`, string|null
Response 200: `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

Preconditions: `user_id`; `lost_reason_id` from GET /v3/lostReasons.

Quirks:
- Body: `user_id`, `lost_reason_id` (required), `comment`.
- Provisional tier: promote to R2 if it proves not reversible via updateStatus.

LIVE CHECK:
- Whether a lost lead can be reopened via updateStatus.
- Whether it cancels the lead's future trial bookings or tasks.

### POST `/v3/leads/updateStatus`

**operationId:** Update Lead Status | **Tier: R1** | **Data: S1** | **Purpose:** Move a lead to another pipeline status.

Pagination: none.
Body (JSON, required):
- `user_id` **required**, number
- `status_id` **required**, number
- `comment`, string|null
Response 200: `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

Preconditions: `user_id` (lead); `status_id` from GET /v3/statuses.

Quirks:
- Body: `user_id`, `status_id` (required), `comment`.
- Response `LeadsResource`.

LIVE CHECK:
- Whether 'converted' and 'lost' statuses can be set here or only through their own operations.
- Idempotency of re-sending the same status.

### GET `/v3/lostReasons`

**operationId:** Get Lead Lost Reasons | **Tier: R0** | **Data: S0** | **Purpose:** List reasons a lead can be marked lost.

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: None.

Quirks:
- Untyped `data`. Ids go into markAsLost `lost_reason_id`.

LIVE CHECK:
- Item shape.

### GET `/v3/sources`

**operationId:** Get Lead Sources | **Tier: R0** | **Data: S0** | **Purpose:** List lead sources (where leads come from).

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: None.

Quirks:
- Untyped `data`. Source ids go into POST /v3/leads `source_id`.

LIVE CHECK:
- Item shape.

### GET `/v3/statuses`

**operationId:** Get Lead Statuses | **Tier: R0** | **Data: S0** | **Purpose:** List the lead pipeline statuses (to translate names to ids).

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: None.

Quirks:
- Spec types `data` as an untyped array: **field names are not documented** (likely an id and a name). Probe before depending on them.

LIVE CHECK:
- Item shape.

## Finance (6)

### POST `/v3/finance/documents`

**operationId:** Create Document | **Tier: R3** | **Data: S2** | **Purpose:** Issue an invoice, receipt, refund invoice or price quote.

Pagination: none.
Body (JSON, required):
- `document_type` **required**, enum 'tax_invoice'|'tax_invoice_receipt'|'receipt'|'refund_invoice'|'transaction_account'|'price_quote'|'payment_receipt'
- `user_id`, integer|null - Arbox member ID. Use with customer_id or when customer_id exists for the member.
- `customer_id`, integer|null - customer unique identifier. Required unless user_id has customer_id.
- `invoice_name` **required**, string - Customer name on the document.
- `personal_id`, string|null - Customer ID number on the document.
- `amount` **required**, number - Invoice total amount.
- `comment`, string|null - Document comments.
- `email`, string|null (email) - Email to send the document to.
- `location_id`, integer|null - Location ID. Defaults to the API user's location.
- `items` **required**, array of objects - Line items on the document.
- `items[].item_number`, string|null - Product number.
- `items[].description` **required**, string - Item description.
- `items[].quantity` **required**, integer - Item quantity. Must be a positive whole number.
- `items[].item_price` **required**, number - Unit price per item.
- `items[].vat`, enum 'include_vat'|'exempt'
- `payments`, array|null - Required for tax_invoice_receipt, receipt, and payment_receipt. Each object is one payment line.
Response 200: `CreatedDocumentResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: A customer: either `user_id` (searchUser) or `customer_id` (no operation lists customer ids).

Quirks:
- `document_type` enum: tax_invoice, tax_invoice_receipt, receipt, refund_invoice, transaction_account, price_quote, payment_receipt.
- Required: `document_type`, `invoice_name`, `amount`, `items` (each needs `description`, `quantity` as a positive integer, `item_price`; optional `item_number`, `vat` = include_vat|exempt).
- `payments` is required for tax_invoice_receipt, receipt and payment_receipt, but its item shape is not defined.
- `email` sends the document to the customer. `location_id` defaults to the API user's location.
- Response is untyped: the document number or link is not guaranteed to come back.
- Legally meaningful documents. Never in v1.

LIVE CHECK:
- Whether `amount` must equal the sum of `items`.
- Whether a document can be voided or must be offset with a refund invoice.
- The `payments` item shape.
- What `customer_id` is and where to find it.

### GET `/v3/finance/reports/cashFlow`

**operationId:** Get Cash Flow Report | **Tier: R0** | **Data: S2** | **Purpose:** See money in and out for a period.

Parameters:
- query `from_date`, **required**, string (date) - Start date (format: Y-m-d).
- query `to_date`, **required**, string (date) - End date (format: Y-m-d). The date range must not exceed 31 days.
- query `location_id`, **optional**, number|null - Location ID.
- query `project_id`, **optional**, string|null - Arbox Invoice project number.
Pagination: none.
Response 200: `CashFlowReportResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: None beyond the date range.

Quirks:
- Both dates REQUIRED and the range must not exceed 31 days (stated on `to_date`). Walk longer periods month by month.
- **No pagination params** and the response `data` is an untyped array: field names and row volume are unknown.
- `location_id` is `number|null` here (integer elsewhere). `project_id` is a string described as 'Arbox Invoice project number'; its meaning is not explained.

LIVE CHECK:
- Row shape (fields) of the response.
- Whether the 31-day cap is enforced and what the error looks like.
- What `project_id` selects.
- What 'cash flow' includes.

### GET `/v3/finance/reports/failedTransactions`

**operationId:** Get Failed Transactions | **Tier: R0** | **Data: S2** | **Purpose:** List payments that failed.

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `FailedTransactionsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `user_id`, `full_name`, `first_name`, `last_name`, `phone`, `membership_user_id`, `membership_type_name`, `location_id`, `location_name`, `membership_location`, `department_name`, `amount`, `last_four_digits`, `custom_field_value`.

Preconditions: None.

Quirks:
- No date params: it returns whatever the system treats as current failures.
- Fields: `amount`, `last_four_digits`, `membership_user_id`, `membership_type_name`, `location_id`.
- Pagination params exist (unlike the other finance reports).

LIVE CHECK:
- How far back it goes and whether resolved failures drop out.

### GET `/v3/finance/reports/invoices`

**operationId:** Get Invoices Report | **Tier: R0** | **Data: S2** | **Purpose:** List invoices issued in a period.

Parameters:
- query `from_date`, **required**, string (date) - Start date (format: Y-m-d).
- query `to_date`, **required**, string (date) - End date (format: Y-m-d). The date range must not exceed 31 days.
- query `location_id`, **optional**, number|null - Location ID.
- query `project_id`, **optional**, string|null - Arbox Invoice project number.
Pagination: none.
Response 200: `InvoiceReportResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: None beyond the date range.

Quirks:
- Both dates REQUIRED and the range must not exceed 31 days (stated on `to_date`). Walk longer periods month by month.
- **No pagination params** and the response `data` is an untyped array: field names and row volume are unknown.
- `location_id` is `number|null` here (integer elsewhere). `project_id` is a string described as 'Arbox Invoice project number'; its meaning is not explained.

LIVE CHECK:
- Row shape (fields) of the response.
- Whether the 31-day cap is enforced and what the error looks like.
- What `project_id` selects.

### GET `/v3/finance/reports/receipts`

**operationId:** Get Receipts Report | **Tier: R0** | **Data: S2** | **Purpose:** List receipts issued in a period.

Parameters:
- query `from_date`, **required**, string (date) - Start date (format: Y-m-d).
- query `to_date`, **required**, string (date) - End date (format: Y-m-d). The date range must not exceed 31 days.
- query `location_id`, **optional**, number|null - Location ID.
- query `project_id`, **optional**, string|null - Arbox Invoice project number.
Pagination: none.
Response 200: `ReceiptReportResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: None beyond the date range.

Quirks:
- Both dates REQUIRED and the range must not exceed 31 days (stated on `to_date`). Walk longer periods month by month.
- **No pagination params** and the response `data` is an untyped array: field names and row volume are unknown.
- `location_id` is `number|null` here (integer elsewhere). `project_id` is a string described as 'Arbox Invoice project number'; its meaning is not explained.

LIVE CHECK:
- Row shape (fields) of the response.
- Whether the 31-day cap is enforced and what the error looks like.
- What `project_id` selects.

### GET `/v3/finance/reports/sales`

**operationId:** Get Sales By Invoice Report | **Tier: R0** | **Data: S2** | **Purpose:** See sales grouped by invoice for a period.

Parameters:
- query `from_date`, **required**, string (date) - Start date (format: Y-m-d).
- query `to_date`, **required**, string (date) - End date (format: Y-m-d). The date range must not exceed 31 days.
- query `location_id`, **optional**, number|null - Location ID.
- query `project_id`, **optional**, string|null - Arbox Invoice project number.
Pagination: none.
Response 200: `App.Http.Resources.PublicApiV3.Invoice.SalesReportResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: None beyond the date range.

Quirks:
- Both dates REQUIRED and the range must not exceed 31 days (stated on `to_date`). Walk longer periods month by month.
- **No pagination params** and the response `data` is an untyped array: field names and row volume are unknown.
- `location_id` is `number|null` here (integer elsewhere). `project_id` is a string described as 'Arbox Invoice project number'; its meaning is not explained.

LIVE CHECK:
- Row shape (fields) of the response.
- Whether the 31-day cap is enforced and what the error looks like.
- What `project_id` selects.
- How it differs from the salesReport under GET /v3/reports/{reportName}.

## Membership Types (3)

### GET `/v3/membershipCancelReasons`

**operationId:** Get Cancel Reasons | **Tier: R0** | **Data: S0** | **Purpose:** List the reasons a membership can be cancelled with.

Parameters:
- query `active`, **optional**, enum '0'|'1' - Filter by active status (example `1`)
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: None.

Quirks:
- Untyped `data`. Ids feed memberships/cancel `cancel_reason_id`. `active` filter is a '0'/'1' string.

LIVE CHECK:
- Item shape.

### GET `/v3/membershipHoldReasons`

**operationId:** Get Hold Reasons | **Tier: R0** | **Data: S0** | **Purpose:** List the reasons a membership can be put on hold with.

Parameters:
- query `active`, **optional**, enum '0'|'1' - Filter by active status (example `1`)
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: None.

Quirks:
- Untyped `data`. Ids feed memberships/hold `hold_reason_id`.

LIVE CHECK:
- Item shape.

### GET `/v3/membershipTypes`

**operationId:** Get All Membership Types | **Tier: R0** | **Data: S0** | **Purpose:** List the memberships and packs the studio sells.

Parameters:
- query `active`, **optional**, enum '0'|'1' - Filter by active status (example `1`)
- query `location_id`, **optional**, integer - Location ID
- query `with_membership_types_props`, **optional**, enum '0'|'1' - Include membership type properties (example `1`)
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `MembershipTypesResource` envelope `{statusCode, data[], extra[]}`. Item fields: `membership_type_id`, `membership_type_name`, `location_name`, `membership_type_internal_name`, `description`, `type`, `period_amount`, `period_time_unit`, `active`, `sessions`, `link`, `price`, `is_recurring_payment`, `sku`, `department_id`, `department_name`, `box_category_id`, `series_id`.

Preconditions: None.

Quirks:
- Fields: `membership_type_id`, `type`, `period_amount`, `period_time_unit`, `sessions`, `price`, `is_recurring_payment`, `link`, `sku`, `series_id`, `box_category_id`, `department_name`.
- `membership_type_id` is the id POST /v3/users/memberships needs.
- `with_membership_types_props=1` adds 'properties' but the response schema has no field for them.

LIVE CHECK:
- Values of `type`.
- What `link` is (a purchase link?).
- Where the `with_membership_types_props` data appears.

## Tasks (4)

### GET `/v3/tasks`

**operationId:** Get All Tasks | **Tier: R0** | **Data: S1** | **Purpose:** List follow-up tasks in a date range.

Parameters:
- query `from_date`, **required**, string - Start date (format: Y-m-d)
- query `include_completed`, **optional**, enum '0'|'1' - Include completed tasks (example `1`)
- query `location_id`, **optional**, integer - Location ID
- query `task_type_id`, **optional**, integer - Task type ID
- query `to_date`, **required**, string - End date (format: Y-m-d)
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `TaskResource` envelope `{statusCode, data[], extra[]}`. Item fields: `task_id`, `user_id`, `email`, `gender`, `active`, `reminder_time`, `created_at`, `full_name`, `phone`, `additional_phone`, `location_name`, `task_type`, `description`, `staff_member`, `staff_member_phone`, `done`, `done_time`, `done_by`, `attribution`.

Preconditions: `from_date` and `to_date` REQUIRED.

Quirks:
- `include_completed=1` to see done tasks; `task_type_id` filter.
- Fields: `task_id`, `user_id`, `task_type`, `description`, `reminder_time`, `staff_member`, `done`, `done_time`, `done_by`, `attribution`.
- `task_id` is a string here; mark-as-completed takes it as a path string.

LIVE CHECK:
- Whether the date range filters the reminder date or the creation date.

### POST `/v3/tasks`

**operationId:** Create New Task | **Tier: R1** | **Data: S1** | **Purpose:** Create a follow-up task (optionally about a member or lead and assigned to a staff member).

Pagination: none.
Body (JSON, required):
- `location_id` **required**, number
- `task_type_id` **required**, number
- `user_id`, number|null
- `assigned_to`, number|null
- `description`, string|null
- `reminder` **required**, object
- `reminder.date` **required**, string (date)
- `reminder.time` **required**, string
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `location_id` (GET /v3/locations), `task_type_id` (GET /v3/tasks/types), optional `user_id` (searchUser) and `assigned_to` (allStaffMembers).

Quirks:
- Required: `location_id`, `task_type_id`, `reminder` object with `date` (date) and `time` (string, format unstated).
- No delete-task operation: a wrong task can only be marked completed.

LIVE CHECK:
- `reminder.time` format (HH:MM?).
- Whether the assignee is notified.
- Duplicate tasks on retry.

### POST `/v3/tasks/markAsCompleted/{task_id}`

**operationId:** Mark Task as Completed | **Tier: R1** | **Data: S1** | **Purpose:** Mark a task as done.

Parameters:
- path `task_id`, **required**, string
Pagination: none.
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `task_id` from GET /v3/tasks.

Quirks:
- No body. `task_id` is a path string.
- Spec declares no 422 and a plain 200 only.

LIVE CHECK:
- Re-completing an already-done task.
- Whether it can be undone.

### GET `/v3/tasks/types`

**operationId:** Get Task Types | **Tier: R0** | **Data: S0** | **Purpose:** List task types (to translate to ids).

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `TaskTypeResource` envelope `{statusCode, data[], extra[]}`. Item fields: `task_type_id`, `type`, `task_type_color`, `active`.

Preconditions: None.

Quirks:
- Fields: `task_type_id`, `type`, `task_type_color`, `active`.

## Message (2)

### POST `/v3/message`

**operationId:** Send Message to User | **Tier: R2** | **Data: S1** | **Purpose:** Send a push or WhatsApp message to chosen members.

Pagination: none.
Body (JSON, optional):
- `message`, string|null
- `subject`, string|null
- `users_ids` **required**, array of number
- `type` **required**, enum 'push'|'whatsapp' - `whatsapp` is only for businesses with Meta WhatsApp integration.
- `message_template_id`, integer - `Message template ID` is only for businesses with Meta WhatsApp integration.
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `users_ids` from a report or list. For WhatsApp with a template, `message_template_id` from GET /v3/messageTemplates.

Quirks:
- Body is `allOf`: `users_ids` (number[], **no maxItems**) required; `type` enum push|whatsapp required; `message`, `subject` nullable; `message_template_id` integer.
- `whatsapp` works only with a Meta WhatsApp integration (per the property description).
- Response is untyped: no per-recipient delivery result.
- Check `allow_sms` / `allow_email` on the people you pick; the spec says nothing about whether the API enforces consent.

LIVE CHECK:
- Whether it sends immediately and to whom (test with the owner's own user).
- What happens when `message` is null.
- Whether the API enforces consent or blocklists.
- Duplicate sends on retry; any rate limit.

### GET `/v3/messageTemplates`

**operationId:** Get Message Templates | **Tier: R0** | **Data: S0** | **Purpose:** List saved message templates.

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `MessageTemplateResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: None.

Quirks:
- Untyped `data`. Templates matter for WhatsApp: `message_template_id` is 'only for businesses with Meta WhatsApp integration'.

LIVE CHECK:
- Item shape and whether push messages use templates at all.

## Digital Forms (2)

### GET `/v3/digitalForms`

**operationId:** Get Digital Forms | **Tier: R0** | **Data: S0** | **Purpose:** List the studio's digital forms (waivers, declarations).

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `DigitalFormResource` envelope `{statusCode, data[], extra[]}`. Item fields: `form_id`, `name`, `version`, `active`, `signature_declaration`, `content`, `created_at`, `updated_at`.

Preconditions: None.

Quirks:
- Fields: `form_id`, `name`, `version`, `active`, `signature_declaration`, `content`, `created_at`, `updated_at`. `content` may be large.
- All fields are strings; `form_id` is a string here but `digital_form_id` is a number in createLink.

LIVE CHECK:
- Whether `form_id` here equals `digital_form_id` in createLink.

### POST `/v3/digitalForms/createLink`

**operationId:** Create Digital Form Link | **Tier: R1** | **Data: S1** | **Purpose:** Create a signing link for a form for a member.

Pagination: none.
Body (JSON, required):
- `digital_form_id` **required**, number
- `user_id` **required**, number
Response 200: `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

Preconditions: `digital_form_id` (GET /v3/digitalForms, field `form_id`), `user_id` (searchUser).

Quirks:
- Both body fields are required numbers.
- Response is untyped: where the link comes back is unknown.
- Provisional R1; treat as R2 until it is confirmed the call only returns a link and sends nothing.

LIVE CHECK:
- Where the link is returned.
- Whether the member is messaged automatically.

## Custom Fields (1)

### GET `/v3/customFields`

**operationId:** Get Custom Fields | **Tier: R0** | **Data: S0** | **Purpose:** List the studio's custom member fields.

Pagination: none.
Response 200: a bare `string` (not the usual envelope)

Preconditions: None.

Quirks:
- The 200 schema is a bare `string`, not the usual `{statusCode, data, extra}` envelope.
- No params, no pagination, no 422.
- Custom values appear elsewhere as `custom_field_value` (response) and `customFields` (request arrays of undefined shape).

LIVE CHECK:
- Real response shape.
- The `customFields` request item shape.

## Locations (1)

### GET `/v3/locations`

**operationId:** Get All Locations | **Tier: R0** | **Data: S0** | **Purpose:** List the studio's locations (also the cheapest connection test).

Parameters:
- query `location_id`, **optional**, integer - Location ID
Pagination: `limit` (max 500), `page`, `sort`; no total in the response.
Response 200: `LocationResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_id`, `location_name`, `address`.

Preconditions: None. Call first: every `location_id` comes from here.

Quirks:
- Fields: `location_id` (string), `location_name`, `address`.
- Optional `location_id` filter and pagination.
- A key probably sees only its own location(s) (decision D5: one key per branch) but the spec does not say.

LIVE CHECK:
- Status code and body for a bad key (the spec declares no 401).
- Whether one key returns several locations.

---

## Common lookup chains

Each arrow is a call whose result feeds the next. Steps marked (R2)/(R3) need the tier's confirmation. Every id passes from string (response) to number (request).

1. **Connect and orient (first call of every session).** GET /v3/locations -> note `location_id` per location. Optionally GET /v3/schedule/boxCategories (service types) and GET /v3/users/allStaffMembers (coaches) to build the id-to-name tables used later.
2. **Find a person.** By phone, email, ID card or id: GET /v3/users/searchUser?type=...&value=... -> `user_id`. **By name there is no search**: page GET /v3/users (limit=500) or a report and filter locally. Leads: GET /v3/leads (same shape). Read details: GET /v3/users/{userId}.
3. **Book a member into a class (R2).** searchUser -> `user_id`; GET /v3/users/memberships?user_id=<id>&active=1 -> pick a `membership_user_id` that fits the class (the response has no sessions-left; a pack balance needs a report) -> GET /v3/schedule?from_date&to_date(&registration_count=1&waiting_list_count=1) -> pick `schedule_id` and check `registration_count` < `max_participants` -> owner confirms (person, class, date, which pack) -> POST /v3/schedule/bookSession {user_id, schedule_id, membership_user_id} -> keep `booking_id` -> verify with GET /v3/schedule counts.
4. **Cancel a booking (R2).** searchUser -> GET /v3/schedule (find the `schedule_id`) -> owner confirms and states whether it is a late cancellation -> POST /v3/schedule/cancelUserBooking {schedule_id, user_id}. Keyed by schedule+user, not `booking_id`.
5. **Book a trial class for a new person (R1 then R2).** POST /v3/leads {first_name, phone, location_id} (R1; search by phone first) -> `user_id` -> GET /v3/schedule -> `schedule_id` -> POST /v3/schedule/booking/trial {user_id, schedule_id} (R2) -> verify with GET /v3/schedule/booking/trial. Cancel: DELETE /v3/schedule/booking/trial?user_id&schedule_id (R2).
6. **Follow up a lead (R1).** GET /v3/statuses, GET /v3/sources, GET /v3/tasks/types, GET /v3/users/allStaffMembers (lookup tables) -> GET /v3/leads -> POST /v3/tasks {location_id, task_type_id, user_id, assigned_to, reminder{date,time}} and/or POST /v3/leads/createNote and/or POST /v3/leads/updateStatus {user_id, status_id}. Close the loop with GET /v3/tasks (from_date,to_date) -> POST /v3/tasks/markAsCompleted/{task_id}. Lost: GET /v3/lostReasons -> POST /v3/leads/markAsLost.
7. **Create a task for the front desk (R1).** GET /v3/locations -> GET /v3/tasks/types -> (optional) searchUser for `user_id` and allStaffMembers for `assigned_to` -> POST /v3/tasks -> verify with GET /v3/tasks.
8. **Message a group of members (R2).** Build the audience (a report or GET /v3/users; filter on `allow_sms`/`allow_email`) -> owner reviews the exact text and recipient count -> (WhatsApp only) GET /v3/messageTemplates -> POST /v3/message {type, users_ids[], subject?, message?} in small batches. No per-recipient result comes back; never retry.
9. **Sell a membership or pack (R3, not v1).** searchUser -> GET /v3/membershipTypes (`membership_type_id`) -> GET /v3/users/memberships?user_id (check duplicates) -> POST /v3/users/memberships (no id returned) -> GET /v3/users/memberships?user_id again to find the new `membership_user_id` -> optional POST /v3/users/memberships/qr or /document.
10. **Hold or cancel a membership (R3, not v1).** GET /v3/users/memberships?user_id -> `membership_user_id`; GET /v3/membershipHoldReasons or /v3/membershipCancelReasons -> POST /v3/users/memberships/hold or /cancel.
11. **Collect a signed waiver (R0 then R1).** GET /v3/users/waiver/{type}/{value} (or the signedFormsReport) -> who lacks one; GET /v3/digitalForms -> `form_id`; POST /v3/digitalForms/createLink {digital_form_id, user_id} (R1 provisional).
12. **Change a class instructor (R2, not v1).** GET /v3/users/allStaffMembers (`user_id` = staff id) -> GET /v3/schedule (staff NAMES only; note the old name) -> PATCH /v3/schedule {schedule_id, staff_member_id}.
13. **Issue a document (R3, not v1).** searchUser -> POST /v3/finance/documents. `customer_id` has no lookup operation; see its LIVE CHECK.

### Where each id comes from

| Id needed | Source operation | Field in the response | Notes |
|---|---|---|---|
| `location_id` | GET /v3/locations | `location_id` (string) | Required in POST /v3/leads and POST /v3/tasks bodies; optional filter elsewhere. |
| `user_id` (member, lead) | GET /v3/users/searchUser; GET /v3/users; GET /v3/leads | `user_id` | No name search. |
| staff id (`staff_id`, `staff_member_id`, `assigned_to`, `assignee_id`) | GET /v3/users/allStaffMembers | `user_id` | GET /v3/schedule returns staff names only. |
| `schedule_id` | GET /v3/schedule | `schedule_id` | One class occurrence, not the recurring series. |
| `membership_user_id` | GET /v3/users/memberships | `membership_user_id` | POST /v3/users/memberships does not return it. |
| `membership_type_id` | GET /v3/membershipTypes | `membership_type_id` | Memberships list shows only the type name. |
| `box_category_id` | GET /v3/schedule/boxCategories | `box_category_id` | Required for staffAvailability and spacesAvailability. |
| `space_id` | GET /v3/schedule/spacesAvailability | `space_id` | No operation lists spaces on their own. |
| `task_type_id` | GET /v3/tasks/types | `task_type_id` |  |
| `task_id` | GET /v3/tasks | `task_id` |  |
| `status_id`, `source_id`, `lost_reason_id` | GET /v3/statuses, /v3/sources, /v3/lostReasons | unknown (untyped) | Probe the item shape first. |
| `cancel_reason_id`, `hold_reason_id` | GET /v3/membershipCancelReasons, /v3/membershipHoldReasons | unknown (untyped) |  |
| `digital_form_id` | GET /v3/digitalForms | `form_id` | Name differs between response and request. |
| `form_id` (memberships/document) | signedFormsReport (per spec description) | see T3 | Not the same source as the line above, per the description. |
| `message_template_id` | GET /v3/messageTemplates | unknown (untyped) | WhatsApp with Meta integration only. |
| `recurring_payment_id` | GET /v3/users/recurringPayments | **not present** | Closest field is `user_box_token_id`. LIVE CHECK. |
| `customer_id` (finance documents) | none documented | - | LIVE CHECK. |
| `booking_id` | POST /v3/schedule/bookSession response; GET /v3/schedule/booking/trial | `booking_id` | Only used by the QR operation; cancel uses schedule+user. |

---

## Write semantics the spec leaves implicit (all LIVE CHECK)

None of the 28 writes documents idempotency, retry behavior, undo or side effects. This table lists the question to answer per write. Run the checks only on the **test gym** (decision D4), in this order: R1 first, then R2, R3 last, with a disposable member. Record observed answers back into the entries above.

| Write | Retry twice: duplicate, error or no-op? | Undo via a documented call? | Notifies the member? | Tier |
|---|---|---|---|---|
| `POST /v3/digitalForms/createLink` | LIVE CHECK | none documented | LIVE CHECK | R1 |
| `POST /v3/finance/documents` | LIVE CHECK | unknown (refund_invoice?) | LIVE CHECK | R3 |
| `POST /v3/leads` | LIVE CHECK | DELETE users (R3) | LIVE CHECK | R1 |
| `POST /v3/leads/updateStatus` | LIVE CHECK | updateStatus back | LIVE CHECK | R1 |
| `POST /v3/leads/markAsLost` | LIVE CHECK | updateStatus (unverified) | LIVE CHECK | R1 |
| `POST /v3/leads/createNote` | LIVE CHECK | none | LIVE CHECK | R1 |
| `POST /v3/message` | LIVE CHECK | none (sent) | LIVE CHECK | R2 |
| `POST /v3/schedule/booking/trial` | LIVE CHECK | DELETE booking/trial | LIVE CHECK | R2 |
| `DELETE /v3/schedule/booking/trial` | LIVE CHECK | POST booking/trial | LIVE CHECK | R2 |
| `PATCH /v3/schedule` | LIVE CHECK | PATCH back | LIVE CHECK | R2 |
| `POST /v3/schedule/bookSession` | LIVE CHECK | cancelUserBooking | LIVE CHECK | R2 |
| `POST /v3/schedule/cancelUserBooking` | LIVE CHECK | bookSession (may not restore the session) | LIVE CHECK | R2 |
| `POST /v3/tasks` | LIVE CHECK | markAsCompleted only | LIVE CHECK | R1 |
| `POST /v3/tasks/markAsCompleted/{task_id}` | LIVE CHECK | none documented | LIVE CHECK | R1 |
| `POST /v3/users/memberships/cancel` | LIVE CHECK | unknown | LIVE CHECK | R3 |
| `POST /v3/users/memberships/update` | LIVE CHECK | update back | LIVE CHECK | R3 |
| `POST /v3/users/memberships/hold` | LIVE CHECK | none documented | LIVE CHECK | R3 |
| `POST /v3/users/memberships/qr` | LIVE CHECK | unknown | LIVE CHECK | R1 |
| `POST /v3/users/memberships/document` | LIVE CHECK | none documented | LIVE CHECK | R2 |
| `POST /v3/users/memberships` | LIVE CHECK | cancel (R3) | LIVE CHECK | R3 |
| `POST /v3/users` | LIVE CHECK | no (DELETE users, R3) | LIVE CHECK | R2 |
| `PATCH /v3/users` | LIVE CHECK | PATCH back (needs saved old values) | LIVE CHECK | R2 |
| `PATCH /v3/users/injury` | LIVE CHECK | old value unreadable | LIVE CHECK | R2 |
| `POST /v3/users/profileImage` | LIVE CHECK | POST old image | LIVE CHECK | R2 |
| `POST /v3/users/createNote` | LIVE CHECK | none | LIVE CHECK | R1 |
| `POST /v3/users/recurringPayments` | LIVE CHECK | POST back | LIVE CHECK | R3 |
| `POST /v3/users/group` | LIVE CHECK | none documented | LIVE CHECK | R3 |
| `DELETE /v3/users/{type}/{userId}` | LIVE CHECK | none documented | LIVE CHECK | R3 |

Special: `DELETE /v3/users/{type}/{userId}` needs the meaning of `type` first. Do not probe by trying values on real data; ask Arbox, or try on a throwaway test record only.

---

## Endpoints no idea uses yet

Measured against the 22-idea catalog in `docs/design/owner-journey.md` section 2 (hand-checked, not a text match). "Used" includes operations only named as out-of-scope.

27 operations: 8 are R3, the rest R0-R2.

| Operation | Tier | What it would do | Note |
|---|---|---|---|
| `POST /v3/leads` | R1 | Lead intake from a message or call. | Candidate idea: **lead intake assistant** (R1) - owner pastes a name and phone, agent searches for duplicates, creates the lead, optionally books a trial. |
| `POST /v3/schedule/bookSession` | R2 | Booking for a member. | Candidate idea: **front-desk booking helper** (R2). Needs the chain above and the LIVE CHECKs on deduction and full classes. |
| `POST /v3/schedule/cancelUserBooking` | R2 | Cancelling for a member. | Pairs with bookSession (R2). |
| `POST /v3/schedule/booking/trial` | R2 | Trial booking. | Pairs with lead intake (R2). |
| `DELETE /v3/schedule/booking/trial` | R2 | Trial cancel. | Pairs with trial booking (R2). |
| `POST /v3/tasks/markAsCompleted/{task_id}` | R1 | Closing tasks. | Natural extension of ideas 9 and 19 (R1): "mark these as done". |
| `POST /v3/leads/markAsLost` | R1 | Lost-lead handling. | Extension of idea 9 (R1 provisional); needs GET /v3/lostReasons, also unused. |
| `GET /v3/lostReasons` | R0 | Lost-reason lookup. | Needed only with markAsLost. |
| `POST /v3/users/createNote` | R1 | Member notes. | Candidate: **note-taking helper** (R1) with GET /v3/users/notes (also unused). Notes cannot be deleted through the API. |
| `GET /v3/users/notes` | R0 | Reading member notes. | Free text from third parties: prompt-injection surface; read as data only. |
| `POST /v3/users` | R2 | Member creation. | R2 (may send a welcome email). Not needed by any current idea. |
| `POST /v3/users/profileImage` | R2 | Photo replace. | No owner demand identified (R2). |
| `PATCH /v3/users` | R2 | Editing people. | Named in idea 20 as out of scope; R2 with consent/contact fields held back by policy. |
| `PATCH /v3/users/injury` | R2 | Injury notes. | Health data; out of v1 (R2/S2). |
| `PATCH /v3/schedule` | R2 | Instructor swaps. | Named in idea 15 as out of scope (R2; see tier note in its entry). |
| `GET /v3/users/staffSalary` | R0 | Staff pay tiers. | Named in idea 14 as excluded by default (S2). |
| `GET /v3/users/recurringPayments` | R0 | Standing payments. | Possible read-only "payments health" idea, but needs `recurring_payment_id` and card-masking answers (S2). |
| `POST /v3/users/recurringPayments` | R3 | Editing payments. | R3, never in v1. |
| `POST /v3/users/group` | R3 | Grouping members. | R3, never in v1. |
| `POST /v3/users/memberships` | R3 | Selling a membership. | R3, never in v1. |
| `POST /v3/users/memberships/update` | R3 | Editing a membership. | R3, never in v1. |
| `POST /v3/users/memberships/cancel` | R3 | Cancelling a membership. | R3, never in v1. |
| `POST /v3/users/memberships/hold` | R3 | Freezing a membership. | R3, never in v1. |
| `POST /v3/users/memberships/qr` | R1 | Check-in QR. | Unknown effect; no idea needs it (R1 provisional). |
| `POST /v3/users/memberships/document` | R2 | Attaching a commitment document. | No idea needs it (R2). |
| `POST /v3/finance/documents` | R3 | Issuing invoices and receipts. | R3, never in v1. |
| `DELETE /v3/users/{type}/{userId}` | R3 | Deleting a person. | R3, never in v1; `type` unknown. |

The other 37 operations are used by at least one catalog idea (including those used only for lookup).

Three **new idea candidates** surfaced here for the lead (not added to the catalog): lead intake assistant, front-desk booking helper, member note-taking helper. They are the first ideas that need R1/R2 writes beyond the existing set, so they depend on the write policy (Q3).

---

## Highest-value LIVE CHECKs from this pass

Ranked by how much they block or endanger. All on the test gym.

1. Bad-key and good-key responses from GET /v3/locations (status code and body): the connection test and every error message depend on it. The spec declares only 200 and 422.
2. What `type` means in `DELETE /v3/users/{type}/{userId}` (throwaway record only). Prevents the worst wrong-class deletion.
3. Idempotency and duplicate behavior of POST /v3/leads, POST /v3/users, POST /v3/tasks, POST /v3/users/createNote and POST /v3/message: decides whether the executor must refuse any retry.
4. POST /v3/message: sends immediately? to whom? what happens with null `message`? Enforces consent or not? Test with the owner's own member record.
5. POST /v3/schedule/bookSession: deducts a session, behavior when the class is full, double-booking, notification.
6. Where `registration_details` data appears in GET /v3/schedule, and whether GET /v3/schedule/entryFromWaitingList lists current waiters or promotions. Idea 3 and idea 4 depend on these.
7. How to obtain `recurring_payment_id` (absent from the GET response) and whether `credit_card_number` is masked.
8. POST /v3/users/memberships: query vs body precedence, the missing response, whether it charges or invoices.
9. Untyped lookup tables (statuses, sources, lostReasons, cancel/hold reasons, messageTemplates, tasks/types are typed): their item shape.
10. GET /v3/users/waiver/{type}/{value}: which of path or query is read, and what `value=0` returns.
11. Pagination end detection and the real default `limit` (no totals anywhere).
12. Meaning of unlabelled enums: `service_type` 1|2|4, `active` 0|1|2 on memberships, `transparent`, `confirm`, `force` (two endpoints), `billing_cycle`, `late_cancellation`.

## Verification

- Every operation and field in the generated parts (parameters, bodies, response fields, pagination) was produced by script from the spec JSON, not typed by hand. The script asserts: 64 operations, exactly one entry per operation, every GET is R0 and no write is R0, every tag present, no 404 declared.
- Hand-written parts (purpose, tier, data class, preconditions, quirks, LIVE CHECKs) are my judgment. Tiers are provisional until the LIVE CHECKs answer the reversibility questions; the main judgment calls: PATCH /v3/schedule is R2 (journey idea 15 said R3), POST /v3/leads/markAsLost and POST /v3/digitalForms/createLink are provisionally R1, POST /v3/users/memberships/qr is provisionally R1.
- No request was sent to the API. Statements about behavior are therefore either spec text or labeled LIVE CHECK.
- `arbox-api.md` correction: it says "No error schema is defined"; the 422 and 404 shapes are defined in `components.responses` (see cross-cutting fact 1), though no non-report operation declares 404.
