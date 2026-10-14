# Arbox API: Leads

Prospects, lead statuses and sources, converted and lost leads, and lead notes.

Tier key: **R0** read-only. **R1** small internal write, no undo through the API (notes, tasks, lead status, create a lead). **R2** member-facing or hard to undo (messages, bookings, edits to a person). **R3** money, identity or delete: never agent-executed in v1.

Data key: **S0** studio configuration. **S1** personal contact data. **S2** health, national ID, salary, payment or finance data. S1 and S2 reads stay out of chat and go to files by default.

Shared rules (pagination, id types, `location_id`, date formats) are in [quirks.md](quirks.md). Common multi-step chains are in [quirks.md](quirks.md#lookup-chains). Each operation ends with its official docs link.

## Contents

- [Get All Leads](#get-all-leads)
- [Create New Lead](#create-new-lead)
- [Get Converted Leads](#get-converted-leads)
- [Add Note to Lead](#add-note-to-lead)
- [Get Lost Leads](#get-lost-leads)
- [Mark Lead as Lost](#mark-lead-as-lost)
- [Update Lead Status](#update-lead-status)
- [Get Lead Lost Reasons](#get-lead-lost-reasons)
- [Get Lead Sources](#get-lead-sources)
- [Get Lead Statuses](#get-lead-statuses)

### Get All Leads

`GET /v3/leads` · Tier R0 · Data S1

List leads (people in the sales pipeline).

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

**Preconditions and lookup:** None.

**Quirks:**

- A lead's `user_id` is a person id usable in lead operations.
- Response has `lead_source` and `lead_status` as NAMES, no ids, and **no created date**: new leads this week cannot be derived from this call. Use leadsInProcessReport / allLeadsReport.
- No date or status filters.

**LIVE CHECK:**

- Whether converted/lost leads are included.
- Whether the lead's `user_id` stays the same after they join.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Leads

### Create New Lead

`POST /v3/leads` · Tier R1 · Data S1

Add a new lead.

**Pagination:** none.

**Body (JSON, required):**

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

**Response 200:** `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

**Preconditions and lookup:** `location_id` (GET /v3/locations). Optional ids: `source_id` (GET /v3/sources), `status_id` (GET /v3/statuses), `assignee_id` (allStaffMembers). Search by phone first to avoid a duplicate.

**Quirks:**

- Required: `first_name`, `phone`, `location_id`.
- `allow_sms`/`allow_email` are 'yes'/'no'. `gender` enum male|female|other. `customFields` untyped.
- Response `LeadsResource`: new `user_id`.

**LIVE CHECK:**

- Duplicate phone behavior (and so retry safety).
- Default status and source when omitted.
- Whether a lead can be removed through the API (only DELETE /v3/users, R3).

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Create%20New%20Lead

### Get Converted Leads

`GET /v3/leads/converted` · Tier R0 · Data S1

List leads who became members.

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

**Preconditions and lookup:** None.

**Quirks:**

- Same `LeadsResource` shape as GET /v3/leads: no conversion date. Use convertedLeadReport for dates and revenue.

**LIVE CHECK:**

- Whether it returns all-time or a window.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Converted%20Leads

### Add Note to Lead

`POST /v3/leads/createNote` · Tier R1 · Data S1

Add an internal note to a lead.

**Pagination:** none.

**Body (JSON, required):**

- `description` **required**, string
- `user_id` **required**, number

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** `user_id` (lead).

**Quirks:**

- Same body as POST /v3/users/createNote (`description`, `user_id`). Append-only through the API.

**LIVE CHECK:**

- Where the note is read back (GET /v3/users/notes?user_id= for a lead id?).
- Duplicate notes on retry.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Add%20Note%20to%20Lead

### Get Lost Leads

`GET /v3/leads/lost` · Tier R0 · Data S1

List leads marked lost.

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

**Preconditions and lookup:** None.

**Quirks:**

- Same `LeadsResource` shape; the lost reason is not a field. Use lostLeadsReport.

**LIVE CHECK:**

- Whether it returns all-time or a window.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Lost%20Leads

### Mark Lead as Lost

`POST /v3/leads/markAsLost` · Tier R1 · Data S1

Mark a lead as lost, with a reason.

**Pagination:** none.

**Body (JSON, required):**

- `user_id` **required**, number
- `lost_reason_id` **required**, number
- `comment`, string|null

**Response 200:** `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

**Preconditions and lookup:** `user_id`; `lost_reason_id` from GET /v3/lostReasons.

**Quirks:**

- Body: `user_id`, `lost_reason_id` (required), `comment`.
- Provisional tier: promote to R2 if it proves not reversible via updateStatus.

**LIVE CHECK:**

- Whether a lost lead can be reopened via updateStatus.
- Whether it cancels the lead's future trial bookings or tasks.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Mark%20Lead%20as%20Lost

### Update Lead Status

`POST /v3/leads/updateStatus` · Tier R1 · Data S1

Move a lead to another pipeline status.

**Pagination:** none.

**Body (JSON, required):**

- `user_id` **required**, number
- `status_id` **required**, number
- `comment`, string|null

**Response 200:** `LeadsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_name`, `gender`, `allow_sms`, `allow_email`, `lead_source`, `lead_status`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `location_id`, `custom_field_value`.

**Preconditions and lookup:** `user_id` (lead); `status_id` from GET /v3/statuses.

**Quirks:**

- Body: `user_id`, `status_id` (required), `comment`.
- Response `LeadsResource`.

**LIVE CHECK:**

- Whether 'converted' and 'lost' statuses can be set here or only through their own operations.
- Idempotency of re-sending the same status.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Update%20Lead%20Status

### Get Lead Lost Reasons

`GET /v3/lostReasons` · Tier R0 · Data S0

List reasons a lead can be marked lost.

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** None.

**Quirks:**

- Untyped `data`. Ids go into markAsLost `lost_reason_id`.

**LIVE CHECK:**

- Item shape.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Lead%20Lost%20Reasons

### Get Lead Sources

`GET /v3/sources` · Tier R0 · Data S0

List lead sources (where leads come from).

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** None.

**Quirks:**

- Untyped `data`. Source ids go into POST /v3/leads `source_id`.

**LIVE CHECK:**

- Item shape.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Lead%20Sources

### Get Lead Statuses

`GET /v3/statuses` · Tier R0 · Data S0

List the lead pipeline statuses (to translate names to ids).

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** None.

**Quirks:**

- Spec types `data` as an untyped array: **field names are not documented** (likely an id and a name). Probe before depending on them.

**LIVE CHECK:**

- Item shape.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Lead%20Statuses
