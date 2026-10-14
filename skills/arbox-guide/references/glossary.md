# Glossary: owner words, Hebrew and English

Use the owner's own word back to them. The right column is what the word maps to when the agent reads Arbox through the connection; never say those terms to the owner. Hebrew items come from Arbox's Hebrew help center and report names, or are marked as common owner wording (not confirmed in Arbox docs).

## Business and people

| Owner says (HE / EN) | Meaning | Maps to (agent only) |
|---|---|---|
| סטודיו / studio, חדר כושר / gym, בוקס / box (CrossFit), קליניקה / clinic, מכון / salon | The business | the Arbox account ("box"); `location_id` per location |
| סניף / branch, location | One site of the business | `location_id`, Get All Locations |
| מתאמן, מתאמנת, לקוח, לקוחה / member, client, trainee, student | A customer | user (`user_id`) |
| מתעניין, ליד / lead, prospect | Someone interested, not yet a member | lead, `leads` operations |
| מאמן, מדריך, מדריכה / coach, instructor, trainer | Staff who teach | staff member (schedule rows give `staff_member` as a name, not an id; `staff_id` is the schedule query filter) |
| צוות / staff | Employees | staff members |

## Classes and schedule

| Owner says | Meaning | Maps to |
|---|---|---|
| חוג, חוגים / class, activity (common in Israel; Arbox's own report names use "hugim" for course-style activities) | A class or a course-style activity | schedule item; reports `hugimBookingReport`, `activeHugimReport`, `hugimRevenueReport` |
| שיעור / class, session | One scheduled occurrence | schedule entry; "session" |
| לוח זמנים / schedule | The calendar | Get Schedule |
| הרשמה / registration, booking | Signing up for a class | booking (`bookSession`), registration count |
| רשימת המתנה / waiting list, waitlist | Queue for a full class | waiting list entries, `waiting_list_count` |
| שיעור ניסיון / trial class | First visit before joining | trial booking, `trialClassesReport` |
| ביטול מאוחר / late cancel | Cancel after the deadline | `lateCancellationReport` |
| אי הגעה / no-show | Booked, did not come | `absenceReport` |
| מסלולים / tracks | A sequence of classes | tracks (app feature) |
| צ'ק אין / check-in | Marking attendance | check-in web app (no API endpoint) |
| שירות, קטגוריה / service, category | A type of class or appointment | "Get Services" = `boxCategories` |
| פגישה אישית / personal appointment | 1:1 session | personal calendar events |
| חדר, מרחב / space, room | Bookable room or resource | spaces, `space_id` |

## Memberships and money

| Owner says | Meaning | Maps to |
|---|---|---|
| מנוי, חברות / membership | Ongoing or fixed-term plan | membership, `membership_type_id` |
| כרטיסייה / punch card, session pack | A number of entries | Arbox "Session Punch Card"; the balance is not on the membership list, so read it from a report such as `expiringSessionsReport` |
| תוקף / validity, expiry | End date of a plan | `end_date` |
| הקפאה / freeze, hold | Pause a membership | hold (`membershipHoldReasons`) |
| ביטול מנוי / cancellation | Ending a membership | `canceledMembershipsReport`, `membershipCancelReasons` |
| הוראת קבע / standing order, recurring payment | Automatic monthly charge | `recurringPayments` |
| חוב / debt | Money owed by a member | `debtReport`, `debt` |
| חיוב שנכשל / failed charge | A declined card | Failed Transactions |
| חשבונית, קבלה / invoice, receipt | Money documents | finance reports (31-day cap) |
| מספר הקצאה / allocation number | Israeli invoice reference | Arbox app only |
| חשבשבת / Hashavshevet | Israeli accounting software | Arbox export, app only |
| דוח שכר / payroll report | Staff pay | staff salary: private, skipped by default |

## Arbox features and words

| Owner says | Meaning | Maps to |
|---|---|---|
| פעולות אוטומטיות / auto actions | Automatic messages and tasks | app only, Standard+ |
| תובנות חכמות / smart insights | Reporting insights (not AI) | app only, Standard+ |
| אקדמיה / Academy | Arbox's lesson site | https://academy.arboxapp.com |
| מרכז העזרה / help center | Arbox help (Hebrew) | https://help.arboxapp.com/he |
| אפליקציית לקוחות / client app | Member app | app only |
| אתר הרשמות / registration site, bookings website | Public booking page | app only |
| טופס דיגיטלי, הצהרת בריאות / digital form, health declaration | Signed forms | `digitalForms`, `signedFormsReport` |
| משימה / task | Follow-up to-do | `tasks` |
| תבנית הודעה / message template | Saved wording | `messageTemplates` |
| תוסף / add-on | Optional paid module | app only |
| זאפייר / Zapier | Connect Arbox to other apps | app, uses the same key |
| קנס / penalty | Fee or block after absences | Penalties (app only) |

## Words to avoid with owners

| Do not say | Say instead |
|---|---|
| API, endpoint, JSON | "your Arbox information", "the connection" |
| API key (before the connection step) | "the API key", named as Arbox shows it (see `arbox-api` setup.md) |
| query, fetch, payload | "look up", "pull" |
| repo, skill, plugin | "add-on", "helper" only if asked |
| R0/R1/R2/R3 | "look only", "small update with your yes", "draft", "stays in the app" |
