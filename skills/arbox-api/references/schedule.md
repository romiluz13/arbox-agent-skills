# Arbox API: Schedule and bookings

Class schedule, bookings, trial bookings, waiting list and staff or space availability.

Tier key: **R0** read-only. **R1** small internal write, no undo through the API (notes, tasks, lead status, create a lead). **R2** member-facing or hard to undo (messages, bookings, edits to a person). **R3** money, identity or delete: never agent-executed in v1.

Data key: **S0** studio configuration. **S1** personal contact data. **S2** health, national ID, salary, payment or finance data. S1 and S2 reads stay out of chat and go to files by default.

Shared rules (pagination, id types, `location_id`, date formats) are in [quirks.md](quirks.md). Common multi-step chains are in [quirks.md](quirks.md#lookup-chains). Each operation ends with its official docs link.

## Contents

- [Get Schedule](#get-schedule)
- [Update Class Schedule](#update-class-schedule)
- [Book Session](#book-session)
- [Cancel Trial Booking](#cancel-trial-booking)
- [Get Trial Class Bookings](#get-trial-class-bookings)
- [Book Trial Class](#book-trial-class)
- [Get Services](#get-services)
- [Get Schedule Settings](#get-schedule-settings)
- [Cancel session](#cancel-session)
- [Get Waiting List Entries](#get-waiting-list-entries)
- [Get Space Availability](#get-space-availability)
- [Get Staff Availability](#get-staff-availability)

### Get Schedule

`GET /v3/schedule` · Tier R0 · Data S0

See the class schedule between two dates, with how full each class is.

**Parameters:**

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

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `ScheduleResource` envelope `{statusCode, data[], extra[]}`. Item fields: `color`, `max_participants`, `space_name`, `is_transparent`, `session_name`, `custom_field_value`, `schedule_id`, `date`, `start_time`, `end_time`, `location_name`, `staff_member`, `second_staff_member`, `waiting_list_count`, `registration_count`, `cancelled_status`, `cancelled_by_id`, `cancelled_by_name`, `cancellation_time`.

**Preconditions and lookup:** `from_date` and `to_date` are required. Optional filters: `staff_id` (allStaffMembers), `box_category_id` (boxCategories), `location_id`.

**Quirks:**

- Dates are plain `string` here (format Y-m-d), not `format: date`.
- `registration_count` / `waiting_list_count` / `registration_details` are opt-in '0'/'1' flags. Without them the counts are not in the response.
- Response has `max_participants`, `registration_count`, `waiting_list_count` as strings, and `staff_member` / `second_staff_member` as NAMES, not ids.
- **`registration_details=1` is accepted but `ScheduleResource` has no field for the registrants**: where the names appear is unknown (maybe `extra`).
- No documented maximum date range. `cancelled` and `transparent` meaning is not described (`is_transparent` is in the response).

**LIVE CHECK:**

- Where `registration_details` data appears.
- Whether `cancelled=1` returns only cancelled classes or includes them.
- What 'transparent' means.
- Maximum range per call; page through weeks until proven otherwise.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Schedule

### Update Class Schedule

`PATCH /v3/schedule` · Tier R2 · Data S0

Change the instructor of one class occurrence.

**Pagination:** none.

**Body (JSON, required):**

- `schedule_id` **required**, number
- `staff_member_id` **required**, number
- `second_staff_member_id`, number

**Response 200:** `ScheduleResource` envelope `{statusCode, data[], extra[]}`. Item fields: `color`, `max_participants`, `space_name`, `is_transparent`, `session_name`, `custom_field_value`, `schedule_id`, `date`, `start_time`, `end_time`, `location_name`, `staff_member`, `second_staff_member`, `waiting_list_count`, `registration_count`, `cancelled_status`, `cancelled_by_id`, `cancelled_by_name`, `cancellation_time`.

**Preconditions and lookup:** `schedule_id` (GET /v3/schedule); `staff_member_id` from GET /v3/users/allStaffMembers.

**Quirks:**

- Body: `schedule_id`, `staff_member_id` (both required), `second_staff_member_id`.
- GET /v3/schedule returns staff NAMES only, so the previous staff id cannot be read back from it to revert; match names against allStaffMembers (names may collide).
- Tier note: earlier planning called this R3 for v1. By the tier definitions it is R2 (member- and staff-facing, no money/identity/delete). Keeping it out of v1 is a policy choice, not the tier.

**LIVE CHECK:**

- Whether members and the coach are notified.
- Whether it applies to one occurrence or the whole series.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Update%20Class%20Schedule

### Book Session

`POST /v3/schedule/bookSession` · Tier R2 · Data S1

Book a member into a class.

**Pagination:** none.

**Body (JSON, required):**

- `user_id` **required**, number
- `schedule_id` **required**, number
- `membership_user_id` **required**, number

**Response 200:** `ScheduleUserResource` envelope `{statusCode, data[], extra[]}`. Item fields: `booking_id`, `schedule_id`, `date`, `start_time`, `end_time`, `location_name`, `staff_member`, `session_name`, `user_id`, `full_name`, `email`, `phone`, `additional_phone`, `booking_time`, `booked_by`.

**Preconditions and lookup:** `user_id` (searchUser), `schedule_id` (GET /v3/schedule), `membership_user_id` (GET /v3/users/memberships?user_id=).

**Quirks:**

- All three ids are required numbers in the body but strings in responses: convert.
- Response `ScheduleUserResource` includes `booking_id`.
- Lookup chain: searchUser -> memberships -> schedule -> bookSession (see chains).
- Cancel is keyed by `schedule_id`+`user_id`, not by `booking_id`.

**LIVE CHECK:**

- Whether it deducts a session or charges.
- Full class: error, waiting list or overbook.
- Booking the same person twice (idempotency).
- Whether the member is notified.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Book%20Session

### Cancel Trial Booking

`DELETE /v3/schedule/booking/trial` · Tier R2 · Data S1

Cancel a trial booking.

**Parameters:**

- query `user_id`, **required**, number
- query `schedule_id`, **required**, number
- query `force`, **optional**, boolean

**Pagination:** none.

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** `user_id`, `schedule_id` (both REQUIRED, as query params).

**Quirks:**

- Parameters travel in the query string, not a body. Optional `force` (boolean): meaning undocumented.

**LIVE CHECK:**

- What `force` does.
- Response when no such booking exists.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Cancel%20Trial%20Booking

### Get Trial Class Bookings

`GET /v3/schedule/booking/trial` · Tier R0 · Data S1

List booked trial classes.

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `ScheduleUserResource` envelope `{statusCode, data[], extra[]}`. Item fields: `booking_id`, `schedule_id`, `date`, `start_time`, `end_time`, `location_name`, `staff_member`, `session_name`, `user_id`, `full_name`, `email`, `phone`, `additional_phone`, `booking_time`, `booked_by`.

**Preconditions and lookup:** None.

**Quirks:**

- Only `location_id` plus pagination: no date filter. Filter on `date` locally or use the trialClassesReport.
- Fields include `booking_id`, `booked_by`, `booking_time`.

**LIVE CHECK:**

- Default ordering (use `sort`).

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Trial%20Class%20Bookings

### Book Trial Class

`POST /v3/schedule/booking/trial` · Tier R2 · Data S1

Book a lead or new person into a trial class.

**Pagination:** none.

**Body (JSON, required):**

- `user_id` **required**, number
- `schedule_id` **required**, number
- `force`, boolean

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** `user_id` (a lead from POST /v3/leads or GET /v3/leads), `schedule_id`.

**Quirks:**

- `force` (boolean, optional): meaning undocumented. Do not set it.

**LIVE CHECK:**

- What `force` overrides.
- Whether the trial consumes a free-trial entitlement.
- Whether the person is notified.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Book%20Trial%20Class

### Get Services

`GET /v3/schedule/boxCategories` · Tier R0 · Data S0

List the studio's services (class types and appointment types).

**Parameters:**

- query `service_type`, **optional**, enum '1'|'2'|'4' - Service type

**Pagination:** none.

**Response 200:** `BoxCategoriesResource` envelope `{statusCode, data[], extra[]}`. Item fields: `box_category_id`, `name`, `type`, `length`, `participants_count`, `price`, `description`, `box_category_group`, `box_category_group_id`.

**Preconditions and lookup:** None.

**Quirks:**

- Titled 'Get Services' but the path says 'boxCategories'; a `box_category_id` is a class/service type.
- No `location_id`, no pagination params.
- `service_type` filter enum is '1', '2', '4' with no labels. Do not guess which is class vs private.

**LIVE CHECK:**

- Meaning of service types 1, 2 and 4.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Services

### Get Schedule Settings

`GET /v3/schedule/boxScheduleSettings` · Tier R0 · Data S0

Read the studio's booking and cancellation rules.

**Parameters:**

- query `location_id`, **optional**, integer - Location ID

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `BoxScheduleSettingsResource` envelope `{statusCode, data[], extra[]}`. Item fields: `showing_classes_week_ago`, `showing_classes_day_ago`, `showing_classes_time_ago`, `schedule_swapping_time`, `schedule_swapping_standby_time`, `standby_time_to_approve`, `standby_cancellation_time`, `availability_time_cancellation`, `availability_enable_late_cancellation`, `cancellation_policy`.

**Preconditions and lookup:** None.

**Quirks:**

- All values are strings with units not stated: `showing_classes_week_ago`, `schedule_swapping_time`, `standby_time_to_approve`, `standby_cancellation_time`, `availability_time_cancellation`, `availability_enable_late_cancellation`, `cancellation_policy`.
- Useful to explain 'late cancellation' to the owner.

**LIVE CHECK:**

- Units of each time value (minutes? hours?).

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Schedule%20Settings

### Cancel session

`POST /v3/schedule/cancelUserBooking` · Tier R2 · Data S1

Cancel a member's booking.

**Pagination:** none.

**Body (JSON, required):**

- `schedule_id` **required**, number
- `user_id` **required**, number
- `late_cancellation`, boolean|null

**Response 200:** `PublicApiV3Resource` envelope `{statusCode, data[], extra[]}`. **Untyped:** `data` is an array of unspecified items (field names unknown).

**Preconditions and lookup:** `schedule_id`, `user_id` (both required, numbers).

**Quirks:**

- Titled 'Cancel session'. `late_cancellation` (boolean|null) is the only option.
- Response untyped.

**LIVE CHECK:**

- What `late_cancellation` does (marks it late and keeps the session charged?).
- Whether a normal cancel refunds the session.
- What happens to the waiting list.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Cancel%20session

### Get Waiting List Entries

`GET /v3/schedule/entryFromWaitingList` · Tier R0 · Data S1

See waiting-list entries.

**Parameters:**

- query `confirm`, **optional**, enum '0'|'1' - Confirm (example `1`)
- query `from_date`, **optional**, string - Start date (format: Y-m-d)
- query `location_id`, **optional**, integer - Location ID
- query `to_date`, **optional**, string - End date (format: Y-m-d)

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `ScheduleStandByResource` envelope `{statusCode, data[], extra[]}`. Item fields: `waitlist_id`, `schedule_id`, `date`, `start_time`, `staff_member`, `session_name`, `user_id`, `full_name`, `phone`, `additional_phone`, `app_link`, `time_to_approval`, `entry_time`.

**Preconditions and lookup:** None. `from_date` / `to_date` are optional here (no default stated).

**Quirks:**

- The path name reads as 'entries that moved from the waiting list'; the operationId says 'Get Waiting List Entries'. **Which one it returns is unclear**, and owner recipes that need waiting-list data depend on it.
- `confirm` ('0'/'1') meaning unknown.
- Fields: `waitlist_id`, `schedule_id`, `user_id`, `time_to_approval`, `entry_time`, `app_link`.

**LIVE CHECK:**

- Whether it lists people currently waiting or people who were promoted.
- Meaning of `confirm`.
- To count waiting-list size per class, GET /v3/schedule `waiting_list_count=1` is the safer source until this is settled.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Waiting%20List%20Entries

### Get Space Availability

`GET /v3/schedule/spacesAvailability` · Tier R0 · Data S0

Find free rooms or spaces for a service.

**Parameters:**

- query `box_category_id`, **required**, integer - Box category ID
- query `from_date`, **required**, string - Start date (format: Y-m-d)
- query `location_id`, **optional**, integer - Location ID
- query `space_id`, **optional**, integer - Space id
- query `to_date`, **required**, string - End date (format: Y-m-d)

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `SpacesAvailabilityResource` envelope `{statusCode, data[], extra[]}`. Item fields: `space_id`, `space_name`, `location_name`, `location_id`, `phone`, `address`, `date`, `start_time`, `end_time`, `session_length`, `service_type`.

**Preconditions and lookup:** `box_category_id`, `from_date`, `to_date` REQUIRED.

**Quirks:**

- `space_id` filter exists but no operation lists spaces: ids only appear in this response.
- Response includes the space's `phone` and `address`.

**LIVE CHECK:**

- Whether rows are free slots only.

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Space%20Availability

### Get Staff Availability

`GET /v3/schedule/staffAvailability` · Tier R0 · Data S1

Find open appointment slots for staff for a given service.

**Parameters:**

- query `box_category_id`, **required**, integer - Box category ID
- query `from_date`, **required**, string - Start date (format: Y-m-d)
- query `location_id`, **optional**, integer - Location ID
- query `staff_id`, **optional**, integer - Staff id
- query `to_date`, **required**, string - End date (format: Y-m-d)

**Pagination:** `limit` (max 500), `page`, `sort`; no total in the response.

**Response 200:** `StaffAvailabilityResource` envelope `{statusCode, data[], extra[]}`. Item fields: `user_id`, `first_name`, `last_name`, `phone`, `email`, `location_name`, `location_id`, `date`, `start_time`, `end_time`, `session_length`, `service_type`.

**Preconditions and lookup:** `box_category_id` REQUIRED (boxCategories), `from_date`, `to_date` REQUIRED.

**Quirks:**

- Response carries `session_length` and `service_type` but no booked/free marker, so whether rows are free slots or all slots is unknown.
- Includes staff phone and email.

**LIVE CHECK:**

- Whether rows are open slots only.
- How a slot found here is booked (no appointment-booking operation is documented).

Docs: https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Staff%20Availability
