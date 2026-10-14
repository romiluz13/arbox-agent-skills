# Arbox API: official docs deep links

Every operation in the spec (65) with its deep link into the official docs. Use these links to read the source when a reference file is missing a detail or contradicts the live API. The live spec is at https://arboxserver.arboxapp.com/docs/api.json and the human docs are at https://arboxserver.arboxapp.com/docs/api.

## Pattern

- Operation: `https://arboxserver.arboxapp.com/docs/api#/operations/<operationId>`, where `<operationId>` is the raw spec value percent-encoded (spaces become `%20`). Python: `urllib.parse.quote(op_id, safe='')`.
- Schema: `https://arboxserver.arboxapp.com/docs/api#/schemas/<SchemaName>`, using the component name as it appears under `components/schemas`.
- The hash is the whole route. The docs use hash routing, so there is no path prefix before `#`.
- Verified in a headless browser for 5 operations and one schema. The other operations use the same pattern.

## Operations (65)

| tag | method | path | operationId | deep link |
|---|---|---|---|---|
| Custom Fields | GET | `/v3/customFields` | Get Custom Fields | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Custom%20Fields |
| Digital Forms | GET | `/v3/digitalForms` | Get Digital Forms | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Digital%20Forms |
| Digital Forms | POST | `/v3/digitalForms/createLink` | Create Digital Form Link | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20Digital%20Form%20Link |
| Finance | POST | `/v3/finance/documents` | Create Document | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20Document |
| Finance | GET | `/v3/finance/reports/cashFlow` | Get Cash Flow Report | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Cash%20Flow%20Report |
| Finance | GET | `/v3/finance/reports/failedTransactions` | Get Failed Transactions | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Failed%20Transactions |
| Finance | GET | `/v3/finance/reports/invoices` | Get Invoices Report | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Invoices%20Report |
| Finance | GET | `/v3/finance/reports/receipts` | Get Receipts Report | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Receipts%20Report |
| Finance | GET | `/v3/finance/reports/sales` | Get Sales By Invoice Report | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Sales%20By%20Invoice%20Report |
| Leads | GET | `/v3/leads` | Get All Leads | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Leads |
| Leads | POST | `/v3/leads` | Create New Lead | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20New%20Lead |
| Leads | GET | `/v3/leads/converted` | Get Converted Leads | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Converted%20Leads |
| Leads | POST | `/v3/leads/createNote` | Add Note to Lead | https://arboxserver.arboxapp.com/docs/api#/operations/Add%20Note%20to%20Lead |
| Leads | GET | `/v3/leads/lost` | Get Lost Leads | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Lost%20Leads |
| Leads | POST | `/v3/leads/markAsLost` | Mark Lead as Lost | https://arboxserver.arboxapp.com/docs/api#/operations/Mark%20Lead%20as%20Lost |
| Leads | POST | `/v3/leads/updateStatus` | Update Lead Status | https://arboxserver.arboxapp.com/docs/api#/operations/Update%20Lead%20Status |
| Leads | GET | `/v3/lostReasons` | Get Lead Lost Reasons | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Lead%20Lost%20Reasons |
| Leads | GET | `/v3/sources` | Get Lead Sources | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Lead%20Sources |
| Leads | GET | `/v3/statuses` | Get Lead Statuses | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Lead%20Statuses |
| Locations | GET | `/v3/locations` | Get All Locations | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Locations |
| Membership Types | GET | `/v3/membershipCancelReasons` | Get Cancel Reasons | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Cancel%20Reasons |
| Membership Types | GET | `/v3/membershipHoldReasons` | Get Hold Reasons | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Hold%20Reasons |
| Membership Types | GET | `/v3/membershipTypes` | Get All Membership Types | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Membership%20Types |
| Message | POST | `/v3/message` | Send Message to User | https://arboxserver.arboxapp.com/docs/api#/operations/Send%20Message%20to%20User |
| Message | GET | `/v3/messageTemplates` | Get Message Templates | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Message%20Templates |
| Reports | GET | `/v3/reports/{reportName}` | Get Reports | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports |
| Schedule | GET | `/v3/schedule` | Get Schedule | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Schedule |
| Schedule | PATCH | `/v3/schedule` | Update Class Schedule | https://arboxserver.arboxapp.com/docs/api#/operations/Update%20Class%20Schedule |
| Schedule | POST | `/v3/schedule/bookSession` | Book Session | https://arboxserver.arboxapp.com/docs/api#/operations/Book%20Session |
| Schedule | DELETE | `/v3/schedule/booking/trial` | Cancel Trial Booking | https://arboxserver.arboxapp.com/docs/api#/operations/Cancel%20Trial%20Booking |
| Schedule | GET | `/v3/schedule/booking/trial` | Get Trial Class Bookings | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Trial%20Class%20Bookings |
| Schedule | POST | `/v3/schedule/booking/trial` | Book Trial Class | https://arboxserver.arboxapp.com/docs/api#/operations/Book%20Trial%20Class |
| Schedule | GET | `/v3/schedule/boxCategories` | Get Services | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Services |
| Schedule | GET | `/v3/schedule/boxScheduleSettings` | Get Schedule Settings | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Schedule%20Settings |
| Schedule | POST | `/v3/schedule/cancelUserBooking` | Cancel session | https://arboxserver.arboxapp.com/docs/api#/operations/Cancel%20session |
| Schedule | GET | `/v3/schedule/entryFromWaitingList` | Get Waiting List Entries | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Waiting%20List%20Entries |
| Schedule | GET | `/v3/schedule/spacesAvailability` | Get Space Availability | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Space%20Availability |
| Schedule | GET | `/v3/schedule/staffAvailability` | Get Staff Availability | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Staff%20Availability |
| Tasks | GET | `/v3/tasks` | Get All Tasks | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Tasks |
| Tasks | POST | `/v3/tasks` | Create New Task | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20New%20Task |
| Tasks | POST | `/v3/tasks/markAsCompleted/{task_id}` | Mark Task as Completed | https://arboxserver.arboxapp.com/docs/api#/operations/Mark%20Task%20as%20Completed |
| Tasks | GET | `/v3/tasks/types` | Get Task Types | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Task%20Types |
| Users | GET | `/v3/users` | Get All Users | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Users |
| Users | PATCH | `/v3/users` | Update user | https://arboxserver.arboxapp.com/docs/api#/operations/Update%20user |
| Users | POST | `/v3/users` | Create New User | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20New%20User |
| Users | GET | `/v3/users/allStaffMembers` | Get staff members | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20staff%20members |
| Users | POST | `/v3/users/createNote` | Create user note | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20user%20note |
| Users | POST | `/v3/users/group` | Group users | https://arboxserver.arboxapp.com/docs/api#/operations/Group%20users |
| Users | PATCH | `/v3/users/injury` | Create or update injury | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20or%20update%20injury |
| Users | GET | `/v3/users/memberships` | Get User Memberships | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20User%20Memberships |
| Users | POST | `/v3/users/memberships` | Create User Membership | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20User%20Membership |
| Users | POST | `/v3/users/memberships/cancel` | Cancel user membership | https://arboxserver.arboxapp.com/docs/api#/operations/Cancel%20user%20membership |
| Users | POST | `/v3/users/memberships/document` | Attach commitment document to membership | https://arboxserver.arboxapp.com/docs/api#/operations/Attach%20commitment%20document%20to%20membership |
| Users | POST | `/v3/users/memberships/hold` | Suspend user membership | https://arboxserver.arboxapp.com/docs/api#/operations/Suspend%20user%20membership |
| Users | POST | `/v3/users/memberships/qr` | Create Membership QR | https://arboxserver.arboxapp.com/docs/api#/operations/Create%20Membership%20QR |
| Users | POST | `/v3/users/memberships/update` | Update user membership | https://arboxserver.arboxapp.com/docs/api#/operations/Update%20user%20membership |
| Users | GET | `/v3/users/notes` | Get general notes | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20general%20notes |
| Users | POST | `/v3/users/profileImage` | Change user profile image | https://arboxserver.arboxapp.com/docs/api#/operations/Change%20user%20profile%20image |
| Users | GET | `/v3/users/recurringPayments` | Get user recurring payments | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20user%20recurring%20payments |
| Users | POST | `/v3/users/recurringPayments` | Edit user recurring payment | https://arboxserver.arboxapp.com/docs/api#/operations/Edit%20user%20recurring%20payment |
| Users | GET | `/v3/users/searchUser` | Search user | https://arboxserver.arboxapp.com/docs/api#/operations/Search%20user |
| Users | GET | `/v3/users/staffSalary` | Get Staff Salary | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Staff%20Salary |
| Users | GET | `/v3/users/waiver/{type}/{value}` | Get users with waiver | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20users%20with%20waiver |
| Users | DELETE | `/v3/users/{type}/{userId}` | Delete user | https://arboxserver.arboxapp.com/docs/api#/operations/Delete%20user |
| Users | GET | `/v3/users/{userId}` | Get user by id | https://arboxserver.arboxapp.com/docs/api#/operations/Get%20user%20by%20id |

## Schema links

Example: [BookForTrialClassRequest](https://arboxserver.arboxapp.com/docs/api#/schemas/BookForTrialClassRequest). Pattern: `https://arboxserver.arboxapp.com/docs/api#/schemas/<SchemaName>`.

