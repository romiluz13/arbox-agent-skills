# Arbox API: Other operations

Membership types and cancel or hold reasons, tasks, messages, digital forms, custom fields and locations.

Tier key: **R0** read-only. **R1** reversible internal write (notes, tasks, lead status, create a lead). **R2** member-facing or hard to undo (messages, bookings, edits to a person). **R3** money, identity or delete: never agent-executed in v1.

Data key: **S0** studio configuration. **S1** personal contact data. **S2** health, national ID, salary, payment or finance data. S1 and S2 reads stay out of chat and go to files by default.

Shared rules (pagination, id types, `location_id`, date formats) are in [quirks.md](quirks.md). Common multi-step chains are in [quirks.md](quirks.md#lookup-chains). Each operation ends with its official docs link.

## Contents

- [Get Cancel Reasons](#get-cancel-reasons)
- [Get Hold Reasons](#get-hold-reasons)
- [Get All Membership Types](#get-all-membership-types)
- [Get All Tasks](#get-all-tasks)
- [Create New Task](#create-new-task)
- [Mark Task as Completed](#mark-task-as-completed)
- [Get Task Types](#get-task-types)
- [Send Message to User](#send-message-to-user)
- [Get Message Templates](#get-message-templates)
- [Get Digital Forms](#get-digital-forms)
- [Create Digital Form Link](#create-digital-form-link)
- [Get Custom Fields](#get-custom-fields)
- [Get All Locations](#get-all-locations)

### Get Cancel Reasons

`GET /v3/membershipCancelReasons` · Tier R0 · Data S0

List the reasons a membership can be cancelled with.

**Parameters:**

- query `active`, **optional**, enum '0'|'1' - Filter by active status (example `1`)
- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** None.

**Quirks:**

- Untyped `data`. Ids feed memberships/cancel `cancel_reason_id`. `active` filter is a '0'/'1' string.

**LIVE CHECK:**

- Item shape.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Cancel%20Reasons

### Get Hold Reasons

`GET /v3/membershipHoldReasons` · Tier R0 · Data S0

List the reasons a membership can be put on hold with.

**Parameters:**

- query `active`, **optional**, enum '0'|'1' - Filter by active status (example `1`)
- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** None.

**Quirks:**

- Untyped `data`. Ids feed memberships/hold `hold_reason_id`.

**LIVE CHECK:**

- Item shape.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Hold%20Reasons

### Get All Membership Types

`GET /v3/membershipTypes` · Tier R0 · Data S0

List the memberships and packs the studio sells.

**Parameters:**

- query `active`, **optional**, enum '0'|'1' - Filter by active status (example `1`)
- query `location_id`, **optional**, integer - Location ID
- query `with_membership_types_props`, **optional**, enum '0'|'1' - Include membership type properties (example `1`)

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `MembershipTypesResource` envelope `{statusCode, data[], extra[]}`. Item fields: `membership_type_id`, `membership_type_name`, `location_name`, `membership_type_internal_name`, `description`, `type`, `period_amount`, `period_time_unit`, `active`, `sessions`, `link`, `price`, `is_recurring_payment`, `sku`, `department_id`, `department_name`, `box_category_id`, `series_id`.

**Preconditions and lookup:** None.

**Quirks:**

- Fields: `membership_type_id`, `type`, `period_amount`, `period_time_unit`, `sessions`, `price`, `is_recurring_payment`, `link`, `sku`, `series_id`, `box_category_id`, `department_name`.
- `membership_type_id` is the id POST /v3/users/memberships needs.
- `with_membership_types_props=1` adds 'properties' but the response schema has no field for them.

**LIVE CHECK:**

- Values of `type`.
- What `link` is (a purchase link?).
- Where the `with_membership_types_props` data appears.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Membership%20Types

### Get All Tasks

`GET /v3/tasks` · Tier R0 · Data S1

List follow-up tasks in a date range.

**Parameters:**

- query `from_date`, **required**, string - Start date (format: Y-m-d)
- query `include_completed`, **optional**, enum '0'|'1' - Include completed tasks (example `1`)
- query `location_id`, **optional**, integer - Location ID
- query `task_type_id`, **optional**, integer - Task type ID
- query `to_date`, **required**, string - End date (format: Y-m-d)

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `TaskResource` envelope `{statusCode, data[], extra[]}`. Item fields: `task_id`, `user_id`, `email`, `gender`, `active`, `reminder_time`, `created_at`, `full_name`, `phone`, `additional_phone`, `location_name`, `task_type`, `description`, `staff_member`, `staff_member_phone`, `done`, `done_time`, `done_by`, `attribution`.

**Preconditions and lookup:** `from_date` and `to_date` REQUIRED.

**Quirks:**

- `include_completed=1` to see done tasks; `task_type_id` filter.
- Fields: `task_id`, `user_id`, `task_type`, `description`, `reminder_time`, `staff_member`, `done`, `done_time`, `done_by`, `attribution`.
- `task_id` is a string here; mark-as-completed takes it as a path string.

**LIVE CHECK:**

- Whether the date range filters the reminder date or the creation date.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Tasks

### Create New Task

`POST /v3/tasks` · Tier R1 · Data S1

Create a follow-up task (optionally about a member or lead and assigned to a staff member).

**Pagination:** none.

**Body (JSON, required):**

- `location_id` **required**, number
- `task_type_id` **required**, number
- `user_id`, number|null
- `assigned_to`, number|null
- `description`, string|null
- `reminder` **required**, object
- `reminder.date` **required**, string (date)
- `reminder.time` **required**, string

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** `location_id` (GET /v3/locations), `task_type_id` (GET /v3/tasks/types), optional `user_id` (searchUser) and `assigned_to` (allStaffMembers).

**Quirks:**

- Required: `location_id`, `task_type_id`, `reminder` object with `date` (date) and `time` (string, format unstated).
- No delete-task operation: a wrong task can only be marked completed.

**LIVE CHECK:**

- `reminder.time` format (HH:MM?).
- Whether the assignee is notified.
- Duplicate tasks on retry.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Create%20New%20Task

### Mark Task as Completed

`POST /v3/tasks/markAsCompleted/{task_id}` · Tier R1 · Data S1

Mark a task as done.

**Parameters:**

- path `task_id`, **required**, string

**Pagination:** none.

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** `task_id` from GET /v3/tasks.

**Quirks:**

- No body. `task_id` is a path string.
- Spec declares no 422 and a plain 200 only.

**LIVE CHECK:**

- Re-completing an already-done task.
- Whether it can be undone.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Mark%20Task%20as%20Completed

### Get Task Types

`GET /v3/tasks/types` · Tier R0 · Data S0

List task types (to translate to ids).

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `TaskTypeResource` envelope `{statusCode, data[], extra[]}`. Item fields: `task_type_id`, `type`, `task_type_color`, `active`.

**Preconditions and lookup:** None.

**Quirks:**

- Fields: `task_type_id`, `type`, `task_type_color`, `active`.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Task%20Types

### Send Message to User

`POST /v3/message` · Tier R2 · Data S1

Send a push or WhatsApp message to chosen members.

**Pagination:** none.

Body (JSON, optional):

- `message`, string|null
- `subject`, string|null
- `users_ids` **required**, array of number
- `type` **required**, enum 'push'|'whatsapp' - `whatsapp` is only for businesses with Meta WhatsApp integration.
- `message_template_id`, integer - `Message template ID` is only for businesses with Meta WhatsApp integration.

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** `users_ids` from a report or list. For WhatsApp with a template, `message_template_id` from GET /v3/messageTemplates.

**Quirks:**

- Body is `allOf`: `users_ids` (number[], **no maxItems**) required; `type` enum push|whatsapp required; `message`, `subject` nullable; `message_template_id` integer.
- `whatsapp` works only with a Meta WhatsApp integration (per the property description).
- Response is untyped: no per-recipient delivery result.
- Check `allow_sms` / `allow_email` on the people you pick; the spec says nothing about whether the API enforces consent.

**LIVE CHECK:**

- Whether it sends immediately and to whom (test with the owner's own user).
- What happens when `message` is null.
- Whether the API enforces consent or blocklists.
- Duplicate sends on retry; any rate limit.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Send%20Message%20to%20User

### Get Message Templates

`GET /v3/messageTemplates` · Tier R0 · Data S0

List saved message templates.

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `MessageTemplateResource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** None.

**Quirks:**

- Untyped `data`. Templates matter for WhatsApp: `message_template_id` is 'only for businesses with Meta WhatsApp integration'.

**LIVE CHECK:**

- Item shape and whether push messages use templates at all.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Message%20Templates

### Get Digital Forms

`GET /v3/digitalForms` · Tier R0 · Data S0

List the studio's digital forms (waivers, declarations).

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `DigitalFormResource` envelope `{statusCode, data[], extra[]}`. Item fields: `form_id`, `name`, `version`, `active`, `signature_declaration`, `content`, `created_at`, `updated_at`.

**Preconditions and lookup:** None.

**Quirks:**

- Fields: `form_id`, `name`, `version`, `active`, `signature_declaration`, `content`, `created_at`, `updated_at`. `content` may be large.
- All fields are strings; `form_id` is a string here but `digital_form_id` is a number in createLink.

**LIVE CHECK:**

- Whether `form_id` here equals `digital_form_id` in createLink.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Digital%20Forms

### Create Digital Form Link

`POST /v3/digitalForms/createLink` · Tier R1 · Data S1

Create a signing link for a form for a member.

**Pagination:** none.

**Body (JSON, required):**

- `digital_form_id` **required**, number
- `user_id` **required**, number

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** `digital_form_id` (GET /v3/digitalForms, field `form_id`), `user_id` (searchUser).

**Quirks:**

- Both body fields are required numbers.
- Response is untyped: where the link comes back is unknown.
- Provisional R1; treat as R2 until it is confirmed the call only returns a link and sends nothing.

**LIVE CHECK:**

- Where the link is returned.
- Whether the member is messaged automatically.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Create%20Digital%20Form%20Link

### Get Custom Fields

`GET /v3/customFields` · Tier R0 · Data S0

List the studio's custom member fields.

**Pagination:** none.

**Response 200:** a bare `string` (not the usual envelope)

**Preconditions and lookup:** None.

**Quirks:**

- The 200 schema is a bare `string`, not the usual `{statusCode, data, extra}` envelope.
- No params, no pagination, no 422.
- Custom values appear elsewhere as `custom_field_value` (response) and `customFields` (request arrays of undefined shape).

**LIVE CHECK:**

- Real response shape.
- The `customFields` request item shape.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Custom%20Fields

### Get All Locations

`GET /v3/locations` · Tier R0 · Data S0

List the studio's locations (also the cheapest connection test).

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `LocationResource` envelope `{statusCode, data[], extra[]}`. Item fields: `location_id`, `location_name`, `address`.

**Preconditions and lookup:** None. Call first: every `location_id` comes from here.

**Quirks:**

- Fields: `location_id` (string), `location_name`, `address`.
- Optional `location_id` filter and pagination.
- A key probably sees only its own location(s) (decision D5: one key per branch) but the spec does not say.

**LIVE CHECK:**

- Status code and body for a bad key (the spec declares no 401).
- Whether one key returns several locations.

---

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Locations
