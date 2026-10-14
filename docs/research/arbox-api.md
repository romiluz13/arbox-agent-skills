# Arbox Public API: factual map

Source: https://arboxserver.arboxapp.com/docs/api (Stoplight Elements page, hash router).
Spec saved as: `docs/research/arbox-openapi.json` (raw JSON, unmodified).

Citation convention: `spec:` refers to `docs/research/arbox-openapi.json`, with a JSON pointer where useful.

## How the spec was obtained

- The docs page has no separate spec URL. The `<elements-api>` element is configured in inline JS: `docs.apiDescriptionDocument = {...}` (page line 87 of the fetched HTML). The OpenAPI document is embedded in the page.
- Fetched `https://arboxserver.arboxapp.com/docs/api` (HTTP 200), extracted that JSON literal, validated it parses, and saved it byte-for-byte. Nothing was executed.
- Page loads `@stoplight/elements@8.4.2` from unpkg. Not relevant to the API.

## Basics

| Item | Value | Source |
|---|---|---|
| Base URL | `https://arboxserver.arboxapp.com/api/public` | `spec:/servers/0/url` |
| Path prefix | every path starts with `/v3` | `spec:/paths` |
| API version | `0.0.1` (title "Arbox API") | `spec:/info` |
| OpenAPI version | `3.1.0` | `spec:/openapi` |
| Paths / operations | 56 paths, 65 operations | counted from `spec:/paths` |
| Schemas | 102 in `components.schemas` | `spec:/components/schemas` |

## Auth

- Scheme name in spec: `Authorization`. Type `apiKey`, location `header`, header name **`api-key`**.
  Spec: `spec:/components/securitySchemes/Authorization` = `{"type":"apiKey","in":"header","name":"api-key","description":"Enter your Arbox's api key"}`.
- Applied globally: `spec:/security` = `[{"Authorization": []}]`. No operation overrides it.
- How to obtain the key: not documented in the spec. Open question.
- Gotcha: the scheme is called `Authorization` but the header is `api-key`. Anyone sending `Authorization: <key>` will not match the spec.

## Rate limits and pagination

- Rate limits: none in the spec. No `429` response, no `x-ratelimit` extension, no rate text found in the document.
- Pagination (used on 30 list GETs, each as a parameter):
  - `page`: "Page number (minimum: 1)".
  - `limit`: "Number of items per page (minimum: 1, maximum: 500)".
  - `sort`: enum `asc` / `desc`.
  - Source: parameter objects under `spec:/paths/*/get/parameters`.
- Response envelope has no pagination metadata. Every list response is `{statusCode, data: [...], extra: [...]}`, and `extra` is an untyped array (`spec:/components/schemas/LeadsResource/properties/extra` = `{"type":"array","items":{}}`). No total, next-page, or cursor field is defined.
- Date-range cap: the `to_date` description says "The date range must not exceed 31 days" on four finance GETs only: `/v3/finance/reports/invoices`, `receipts`, `cashFlow`, `sales` (`spec:/paths/<path>/get/parameters`, param `to_date`). Other date-range endpoints state no cap.

## Conventions that cut across endpoints

- **`location_id` is everywhere** and means location/box. It is optional query param on most GETs (description "Location ID"). It is required in request bodies for `CreateLeadRequest` and `CreateTaskRequest` (`spec:/components/schemas/CreateLeadRequest/required`, `CreateTaskRequest/required`). No default is documented when omitted.
- `box_id` appears only in one response (`spec:/components/schemas/StaffSalaryResource`, a salary record). It seems to be a legacy alias for location. Unconfirmed.
- Dates: `format: date` (`YYYY-MM-DD`; query descriptions say "format: Y-m-d") and `format: date-time` in responses (26 occurrences).
- Booleans: three encodings for the same concept.
  - Query flags: strings `"0"` / `"1"` (e.g. `active`, `cancelled`, `transparent`, `success`).
  - Body yes/no: `allow_sms` / `allow_email` are `enum: ["yes","no"]` in `CreateUserRequest` and `CreateLeadRequest`.
  - JSON booleans elsewhere (e.g. `CancelUserBookingRequest.late_cancellation`).
- ID types differ between request and response (see Odd things).
- Lists the spec labels with `sort`, `limit`, `page`, `location_id` are the same four params on nearly every GET, so the "standard list" shape is consistent.

## Endpoints by group

Counts: Users 23, Schedule 12, Leads 10, Finance 6, Membership Types 3, Tasks 4, Message 2, Digital Forms 2, Custom Fields 1, Locations 1, Reports 1. Total 65.
Names below are the spec's `operationId`. The spec has **no** `summary` or `description` on any operation, so these are the only human-readable names. Every operation cites `spec:/paths/<path>/<method>`.

### Users / memberships (23)

| Method | Path | Operation (operationId) |
|---|---|---|
| GET | /v3/users | Get All Users |
| POST | /v3/users | Create New User |
| PATCH | /v3/users | Update user |
| GET | /v3/users/{userId} | Get user by id |
| DELETE | /v3/users/{type}/{userId} | Delete user |
| GET | /v3/users/searchUser | Search user |
| PATCH | /v3/users/injury | Create or update injury |
| POST | /v3/users/profileImage | Change user profile image |
| POST | /v3/users/createNote | Create user note |
| GET | /v3/users/notes | Get general notes |
| GET | /v3/users/allStaffMembers | Get staff members |
| GET | /v3/users/staffSalary | Get Staff Salary |
| GET | /v3/users/recurringPayments | Get user recurring payments |
| POST | /v3/users/recurringPayments | Edit user recurring payment |
| GET | /v3/users/waiver/{type}/{value} | Get users with waiver |
| POST | /v3/users/group | Group users |
| GET | /v3/users/memberships | Get User Memberships |
| POST | /v3/users/memberships | Create User Membership |
| POST | /v3/users/memberships/update | Update user membership |
| POST | /v3/users/memberships/cancel | Cancel user membership |
| POST | /v3/users/memberships/hold | Suspend user membership |
| POST | /v3/users/memberships/qr | Create Membership QR |
| POST | /v3/users/memberships/document | Attach commitment document to membership |

### Schedule / bookings (12)

| Method | Path | Operation |
|---|---|---|
| GET | /v3/schedule | Get Schedule |
| PATCH | /v3/schedule | Update Class Schedule |
| GET | /v3/schedule/boxCategories | Get Services |
| GET | /v3/schedule/boxScheduleSettings | Get Schedule Settings |
| GET | /v3/schedule/staffAvailability | Get Staff Availability |
| GET | /v3/schedule/spacesAvailability | Get Space Availability |
| GET | /v3/schedule/entryFromWaitingList | Get Waiting List Entries |
| POST | /v3/schedule/bookSession | Book Session |
| POST | /v3/schedule/cancelUserBooking | Cancel session |
| POST | /v3/schedule/booking/trial | Book Trial Class |
| GET | /v3/schedule/booking/trial | Get Trial Class Bookings |
| DELETE | /v3/schedule/booking/trial | Cancel Trial Booking |

### Leads (10)

| Method | Path | Operation |
|---|---|---|
| GET | /v3/leads | Get All Leads |
| POST | /v3/leads | Create New Lead |
| POST | /v3/leads/updateStatus | Update Lead Status |
| POST | /v3/leads/markAsLost | Mark Lead as Lost |
| POST | /v3/leads/createNote | Add Note to Lead |
| GET | /v3/leads/converted | Get Converted Leads |
| GET | /v3/leads/lost | Get Lost Leads |
| GET | /v3/statuses | Get Lead Statuses |
| GET | /v3/sources | Get Lead Sources |
| GET | /v3/lostReasons | Get Lead Lost Reasons |

### Finance (6)

| Method | Path | Operation |
|---|---|---|
| GET | /v3/finance/reports/invoices | Get Invoices Report |
| GET | /v3/finance/reports/receipts | Get Receipts Report |
| GET | /v3/finance/reports/cashFlow | Get Cash Flow Report |
| GET | /v3/finance/reports/sales | Get Sales By Invoice Report |
| GET | /v3/finance/reports/failedTransactions | Get Failed Transactions |
| POST | /v3/finance/documents | Create Document |

### Membership types (3)

| Method | Path | Operation |
|---|---|---|
| GET | /v3/membershipTypes | Get All Membership Types |
| GET | /v3/membershipCancelReasons | Get Cancel Reasons |
| GET | /v3/membershipHoldReasons | Get Hold Reasons |

### Tasks (4)

| Method | Path | Operation |
|---|---|---|
| GET | /v3/tasks | Get All Tasks |
| POST | /v3/tasks | Create New Task |
| GET | /v3/tasks/types | Get Task Types |
| POST | /v3/tasks/markAsCompleted/{task_id} | Mark Task as Completed |

### Message (2)

| Method | Path | Operation |
|---|---|---|
| GET | /v3/messageTemplates | Get Message Templates |
| POST | /v3/message | Send Message to User |

### Digital forms (2)

| Method | Path | Operation |
|---|---|---|
| GET | /v3/digitalForms | Get Digital Forms |
| POST | /v3/digitalForms/createLink | Create Digital Form Link |

### Reports (1)

| Method | Path | Operation |
|---|---|---|
| GET | /v3/reports/{reportName} | Get Reports |

Single generic endpoint. `reportName` is an enum of 46 values (`spec:/components/schemas/ReportName`, e.g. `salesReport`, `activeMembersReport`, `debtReport`, `revenueAnalysisReport`). Its 200 response is an `anyOf` of 44 `*ReportResource` schemas with no discriminator (`spec:/paths/~1v3~1reports~1{reportName}/get/responses/200/content/application~1json/schema`).

### Custom fields (1) and locations (1)

| Method | Path | Operation |
|---|---|---|
| GET | /v3/customFields | Get Custom Fields |
| GET | /v3/locations | Get All Locations |

## Read vs write split

| Method | Count | Notes |
|---|---|---|
| GET | 37 | reads |
| POST | 23 | creates, actions, and some edits |
| PATCH | 3 | `PATCH /v3/users`, `PATCH /v3/users/injury`, `PATCH /v3/schedule` |
| PUT | 0 | none |
| DELETE | 2 | `DELETE /v3/users/{type}/{userId}`, `DELETE /v3/schedule/booking/trial` |
| **Total** | **65** | |

Writes that change money, messaging, or access (review before any skill calls them):
- `POST /v3/message`: sends push or WhatsApp messages to users (`SendMessageRequest`).
- `POST /v3/finance/documents`: creates invoices, receipts, or price quotes, and can email them (`CreateDocumentRequest.email`).
- `POST /v3/users/memberships` and `POST /v3/users/memberships/update`: sets `price`, `sessions_left`, `debt`.
- `POST /v3/users/recurringPayments`: edits a recurring payment's `amount` and `status` (`CHARGE` / `CANCELLED`).
- `POST /v3/users/memberships/cancel`, `POST /v3/users/memberships/hold`: change membership state.

Destructive:
- `DELETE /v3/users/{type}/{userId}` ("Delete user"). `type` is an unconstrained string path param, so the valid values are unknown.
- `DELETE /v3/schedule/booking/trial` ("Cancel Trial Booking"), with a `force` query flag.
- `POST /v3/schedule/cancelUserBooking`: cancels a booking, with `late_cancellation`.
- `POST /v3/leads/markAsLost`, `POST /v3/users/group` (merges users under a head user, `GroupUsersRequest`).
- `PATCH /v3/schedule`: reassigns staff on a class (`PatchScheduleRequest`).

No endpoint is documented as idempotent or as safe to retry.

## Odd things

1. **No descriptions at all.** Zero `summary` and zero `description` on operations, and zero `description` on component schemas. Only some parameters and two body properties have text. The only human-readable name is `operationId`, which is inconsistent (see 2).
2. **Misleading names.** `GET /v3/schedule/boxCategories` is titled "Get Services" (`spec:/paths/~1v3~1schedule~1boxCategories/get/operationId`). `POST /v3/schedule/cancelUserBooking` is titled "Cancel session". The naming vocabulary (box, category, service, session, class, booking) is not defined anywhere.
3. **Duplicate param names.** Same name as both path and query param on two endpoints:
   - `/v3/reports/{reportName}`: `reportName` is path and query.
   - `/v3/users/waiver/{type}/{value}`: `type` and `value` are path and query. The query `type` is an enum (`medical`, `regular`), the path `type` is untyped. Which one the server reads is unknown.
4. **ID type drift.** Responses type IDs as strings (`LeadsResource.user_id`, `MembershipUserResource.membership_user_id`, `ScheduleResource.schedule_id`, `LocationResource.location_id` are all `["string","null"]`). Requests type the same IDs as numbers (`CreateLeadNoteRequest.user_id` is `number`). Some request bodies use `integer`, others `number`, for the same field.
5. **`active` is typed three ways.** `CreateUserRequest.active` is boolean, `PatchUserRequest.active` is `number`, and the `active` query filter is `"0"`/`"1"`.
6. **Naming drift in params.** Reports use `fromDate`/`toDate` and `group_by` in camelCase. Everywhere else is `from_date`/`to_date`. `CreateUserRequest` has `customFields` while other fields are snake_case. `membership_user_id` and `user_id` are both used for the same person in different endpoints.
7. **Untyped responses.** Only the envelope is typed: `data` is an array even for single-object endpoints (e.g. `GET /v3/users/{userId}` returns `UsersResource`, where `data` is an array). Several responses are missing a 422 or a schema: `GET /v3/customFields`, `POST /v3/tasks/markAsCompleted/{task_id}`, `GET /v3/users/{userId}` (no 422), and `POST /v3/users/memberships` (no 200 schema).
8. **Reports response is an unlabelled union.** Which of the 44 `*ReportResource` schemas applies depends on `reportName`, but the spec does not say so.
9. **Typed query enums vs free strings.** `DELETE /v3/users/{type}/{userId}` takes any string for `type`.
10. **Auth header mismatch.** Scheme named `Authorization`, header `api-key` (see Auth).
11. **Mixed verbs for updates.** No PUT anywhere. Updates are PATCH (`/v3/users`, `/v3/schedule`), or POST to action-style paths (`/v3/users/memberships/update`, `/v3/users/recurringPayments`, `/v3/leads/updateStatus`).
12. **Examples are sparse.** 22 `example` fields in the whole spec. Not enough to infer payload shapes for most operations.
13. **`POST /v3/message` body is `allOf`**, with `type` (`push` / `whatsapp`) and `message_template_id` optional. `whatsapp` only works with a Meta WhatsApp integration (per the property description). Spec: `spec:/paths/~1v3~1message/post/requestBody`.

## Open questions

1. How is the API key obtained, and what permissions does it grant? Not in the spec.
2. Rate limits and quotas: none documented. Unknown whether any exist.
3. Pagination: does the server return a total count or next-page indicator anywhere? The envelope has none. Is `extra` ever populated, and with what?
4. Is `location_id` required on GETs that accept it, and what is the default when omitted?
5. Valid values for `DELETE /v3/users/{type}/{userId}` `type`. Also valid values for the waiver `type` path param.
6. Which `reportName` maps to which `*ReportResource` schema, and what fields each report returns.
7. Are the `box_id` (salary) and `location_id` fields the same concept?
8. Date-range cap: the 31-day limit is documented only on four finance GETs. Is it enforced there, and do other range endpoints have an undocumented cap?
9. Idempotency and side effects: does `POST /v3/users/memberships` with an existing user create a duplicate? Does `POST /v3/message` send immediately?
10. Error shapes: only `422` and occasionally `404` are declared. No error schema is defined.
11. Is the Stoplight-hosted docs page the source of truth, or is there a separate canonical OpenAPI file? The spec was extracted from inline JS only.
