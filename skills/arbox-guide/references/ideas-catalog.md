# Ideas catalog

Pick three per owner (see SKILL.md). Each entry: the owner pitch in plain words, which operating models it fits, the plan gate, the risk tier, effort, and either the recipe that builds it or the operations it uses.

## Contents

- [How to read an entry](#how-to-read-an-entry)
- [Ideas with a recipe](#ideas-with-a-recipe)
- [More Arbox ideas (no recipe yet)](#more-arbox-ideas-no-recipe-yet)
- [Ideas that need no Arbox connection](#ideas-that-need-no-arbox-connection)
- [Native Arbox features to point to first](#native-arbox-features-to-point-to-first)
- [Choosing three](#choosing-three)

## How to read an entry

- **Fits**: G = group classes and memberships (Pilates, yoga, CrossFit, gym, martial arts, dance), 1 = one-on-one appointments (PT, clinic, beauty, tutor), C = courses and workshops (kids, education, activities), S = spaces and venues (bookable rooms, courts, activities), M = several locations.
- **Plan gate**: what the owner's Arbox plan must include. Leads, tasks, auto actions, email and smart insights need Standard or higher; advanced reports need Standard or higher (basic reports on Free and Basic). Whether API access itself depends on plan is not confirmed; `arbox-api` finds out at connect time. "Any" = no plan limit known.
- **Risk**: R0 read only. R1 small internal update in Arbox (a task, a note, a lead status), only after the owner says yes. R2 member-facing message: always a draft the owner sends. R3 money, deletes, merges, membership changes: never done by the agent, stays in the Arbox app.
- **Effort**: Chat (answer in the conversation), Report (one page or file, minutes), Routine (rerun with one sentence), Loop (needs the owner's approval each run).
- **Recipe**: the `arbox-recipes` skill builds it by that name. Operations are cited as `METHOD /path` with a link to the Arbox API docs. Reports are values of `reportName` for the Get Reports operation.
- Report field shapes come from the spec for 40 of 47 reports, matched by name (INFERRED). Seven have no schema (UNTYPED), so their fields are unknown until the recipe probes them live. The recipe confirms fields against live data and shows the owner a spot check.
- Message ideas: only draft for members who allow that channel (report rows carry `allow_sms` / `allow_email`).

## Ideas with a recipe

### 1. Who is drifting (recipe `whos-drifting`)
"Members who used to come regularly and have gone quiet, so I can reach out before they cancel."
Fits G 1 C. Plan: Basic reports are on every plan; whether these report names are basic or advanced is UNKNOWN. Confirm on connect. Risk R0, optional R2 drafts. Effort Report, then Routine.
Operations: [`GET /v3/reports/{reportName}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports) with `absenceReport`, `inactiveMembersReport`, `regularsReport` (who was a regular).
Native check: Arbox Academy "Reports" lesson, Retention group (clients at risk), can message them. Claude adds the join of regulars and absence, and drafted wording.

### 2. Pack and membership renewal watch (recipe `renewal-watch`)
"Who is about to run out of sessions or expire, plus who has unused credits, with a friendly renewal message drafted for me."
Fits G 1 C. Plan: UNKNOWN for the Retention reports; auto-action reminders are Standard+. Confirm on connect. Risk R0, drafts R2. Effort Routine (weekly), Loop for messages.
Operations: [`GET /v3/reports/{reportName}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports) with `expiringSessionsReport`, `expiringMembershipsReport`, `expiredMembershipsReport`, `renewalsReport`; [`GET /v3/messageTemplates`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Message%20Templates) to match their tone.
Native check: Reports > Retention (expiring without renewal) and auto actions (Standard+) send reminders and follow-ups; a renewal trigger isn't confirmed on Arbox's page, so check in the app. Offer to set those up first if the owner wants zero effort; Claude adds the weekly list and Hebrew/English drafts.

### 3. Payments to chase (recipe `payments-to-chase`)
"Who owes me, or whose card failed."
Fits all. Plan: UNKNOWN (failed-payment recovery is unconfirmed per tier). Risk R0; optional R1 task per person; drafts R2. Effort Report. Card digits are never printed.
Operations: [`GET /v3/reports/{reportName}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports) with `debtReport`; [`GET /v3/finance/reports/failedTransactions`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Failed%20Transactions).
Native check: Arbox has Failed Transactions with a built-in debt and card-update message to the member (Academy "Recurring Plan" lesson; plan not confirmed). Point there for the send; Claude builds the owner's chase list.

### 4. Leads and trials follow-up (recipe `leads-and-trials`)
"Every new lead and trial gets looked at, so nobody falls through, and I see who actually joined."
Fits G 1 C. Plan: Standard+ (lead and task management). Risk R0; optional R1 follow-up task or note per lead. Effort Report, then Loop.
Operations: [`GET /v3/leads`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Leads), [`GET /v3/schedule/booking/trial`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Trial%20Class%20Bookings), [`GET /v3/leads/converted`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Converted%20Leads), [`GET /v3/leads/lost`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Lost%20Leads), [`GET /v3/sources`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Lead%20Sources); optional [`POST /v3/tasks`](https://arboxserver.arboxapp.com/docs/api#/operations/Create%20New%20Task), [`POST /v3/leads/createNote`](https://arboxserver.arboxapp.com/docs/api#/operations/Add%20Note%20to%20Lead), [`POST /v3/leads/updateStatus`](https://arboxserver.arboxapp.com/docs/api#/operations/Update%20Lead%20Status). Reports: `leadsInProcessReport`, `trialClassesReport`, `convertedLeadReport`, `allLeadsReport`.
Native check: Arbox's Zapier integration lists Facebook, Instagram and Google Ads lead sources (plan not confirmed); the Growth reports show the share of leads converted. Claude adds follow-up prioritization.

### 5. Sales snapshot (recipe `sales-snapshot`)
"What I earned this month versus last month, and what I sold."
Fits all. Plan: any. Risk R0. Effort Report. Also answers "which source brings people who actually buy".
Operations: [`GET /v3/reports/{reportName}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports) with `salesReport`, `revenueAnalysisReport` (untyped, probe first); [`GET /v3/finance/reports/sales`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Sales%20By%20Invoice%20Report), [`GET /v3/finance/reports/cashFlow`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Cash%20Flow%20Report), [`GET /v3/finance/reports/invoices`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Invoices%20Report), [`GET /v3/finance/reports/receipts`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Receipts%20Report) (these four are capped at 31 days per call, so loop by month).
Native check: Arbox has a real-time dashboard, earnings goals and a monthly financial history on Standard+. Offer it first if it covers the question.

### 6. Class fill and waiting lists (recipe `class-fill`)
"Which times are empty and which are always full, and where people queue."
Fits G C S. Plan: any. Risk R0. Effort Report.
Operations: [`GET /v3/schedule`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Schedule) (capacity; add `registration_count=1` and `waiting_list_count=1` for the counts); [`GET /v3/schedule/entryFromWaitingList`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Waiting%20List%20Entries); [`GET /v3/reports/{reportName}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports) with `classesSummaryReport`, `bookingStatisticsReport` (untyped).
Output is a proposal about what to add or drop. Schedule changes stay in the Arbox app.

### 7. No-shows and late cancels (recipe `no-shows`)
"Who keeps cancelling late or not turning up."
Fits 1 G C. Plan: any. Risk R0, drafts R2. Effort Report. The strongest pain for 1:1 businesses.
Operations: [`GET /v3/reports/{reportName}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports) with `lateCancellationReport`, `bookingCancellationReport`, `cancelledSessionsReport`, `absenceReport`.
Native check: Arbox Penalties (Settings > Business Settings > Penalties) block or shorten memberships after repeated absences (Academy "Penalties" lesson). Mention it before suggesting any other fix.

### 8. First 30 days (recipe `first-30-days`)
"Did my new members come back after the intro offer?" Intro-offer retention.
Fits G 1 C. Plan: any. Risk R0, drafts R2. Effort Report, then Routine.
Operations: [`GET /v3/reports/{reportName}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports) with `sessionsReport`, `bookingsReport` (untyped), `activeMembershipsReport`; [`GET /v3/users/searchUser`](https://arboxserver.arboxapp.com/docs/api#/operations/Search%20user) for lookups. The recipe flags possible duplicate people instead of guessing.

### 9. Waivers and forms (recipe `waivers-and-forms`)
"Who has not signed their waiver or health declaration."
Fits all, esp. clinics and activities. Plan: any. Risk R0. Form links are made in the Arbox app; the helper can't create them in v1. Effort Report. Health values are never printed, only whether it is signed.
Operations: [`GET /v3/digitalForms`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Digital%20Forms); [`GET /v3/reports/{reportName}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports) with `signedFormsReport`; [`GET /v3/users/waiver/{type}/{value}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20users%20with%20waiver); optional [`POST /v3/digitalForms/createLink`](https://arboxserver.arboxapp.com/docs/api#/operations/Create%20Digital%20Form%20Link).

### 10. The Monday page (output of several recipes)
"One page every Monday: how many came, who joined, who left, what I earned, who to call."
Fits all. Plan: any, richer on Standard+. Risk R0. Effort Routine (rerun with one sentence, no automatic scheduling in v1).
Composes renewal-watch, payments-to-chase, sales-snapshot, class-fill and no-shows into one HTML page. Offer it as the second or third idea once one recipe has worked. It also covers "local dashboard" and "daily front-desk briefing" requests.

## More Arbox ideas (no recipe yet)

Built on request from the Arbox docs and the `arbox-api` references, as a one-off report or chat answer. Say plainly that these are built live and may need a spot check with the owner.

### 11. Where my customers come from
Which lead source or campaign brings people who sign up. Fits all. Plan: Standard+ for leads. R0. Report.
Operations: [`GET /v3/sources`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Lead%20Sources); reports `allLeadsReport`, `convertedLeadReport`, `salesReport`.

### 12. Why people leave
Reasons members cancel or freeze, and when. Fits all. Plan: any. R0. Report.
Operations: [`GET /v3/reports/{reportName}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports) with `canceledMembershipsReport`, `membersOnHoldReport`; [`GET /v3/membershipCancelReasons`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Cancel%20Reasons), [`GET /v3/membershipHoldReasons`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Hold%20Reasons).

### 13. Ask your studio anything
"Who is Dana's coach?", "how many are on the 7am Tuesday class?" Fits all. R0. Chat.
Operations: [`GET /v3/users/searchUser`](https://arboxserver.arboxapp.com/docs/api#/operations/Search%20user), [`GET /v3/users/{userId}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20user%20by%20id), [`GET /v3/users/memberships`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20User%20Memberships), [`GET /v3/schedule`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Schedule).

### 14. Coach popularity
Which instructors fill their classes. Fits G C. Plan: any. R0. Report.
Operations: [`GET /v3/schedule`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Schedule), [`GET /v3/users/allStaffMembers`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20staff%20members); reports `classesSummaryReport`, `employeeAttendanceReport`. Never touch salary data unless the owner asks.

### 15. Membership mix
Which memberships and packs sell, and which could be retired. Fits all. R0. Report.
Operations: [`GET /v3/membershipTypes`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Membership%20Types); reports `activeMembershipsReport`, `salesReport`.

### 16. Data tidy-up list
Members missing a phone or email, or who blocked messages. Fits all. R0. Report only; fixing records stays in the Arbox app.
Operations: [`GET /v3/users`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Users), [`GET /v3/customFields`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Custom%20Fields); report `membersPropertiesReport`.

### 17. Compare my branches
Both locations side by side. Fits M. R0. Routine.
Operations: [`GET /v3/locations`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Locations); the sales snapshot and Monday page once per connection `arbox-api` sets up.

### 18. Birthdays and milestones
Birthday wishes drafted for each member who allows messages. Fits G 1 C. R0, drafts R2. Loop.
Operations: [`GET /v3/reports/{reportName}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports) with `birthdayReport`.
Native check: Arbox auto actions (Standard+) send reminders and follow-ups; a birthday trigger isn't confirmed on Arbox's page, so check in the app. Check-in shows a birthday icon. Suggest the native route first.

### 19. Daily front-desk briefing
Today's classes, bookings, birthdays, expiring packs, open tasks. Fits G 1. R0. Routine (daily).
Operations: [`GET /v3/schedule`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Schedule), [`GET /v3/tasks`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20All%20Tasks); reports `birthdayReport`, `expiringSessionsReport`.

### 20. Schedule planning proposal
Suggest times to add or drop from real demand. Fits G C S. R0. Report. A proposal document only; any change is made in the Arbox app.
Operations: [`GET /v3/schedule`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Schedule), [`GET /v3/schedule/staffAvailability`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Staff%20Availability), [`GET /v3/schedule/spacesAvailability`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Space%20Availability), [`GET /v3/schedule/boxScheduleSettings`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Schedule%20Settings), [`GET /v3/schedule/boxCategories`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Services); report `bookingStatisticsReport` (untyped).

### 21. Standing-order overview
Who pays by standing order, amounts and status. Fits all. R0. Report. Changing any amount or status is R3 and stays in the Arbox app.
Operations: [`GET /v3/users/recurringPayments`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20user%20recurring%20payments).

### 22. Course enrollment view
Kids' and course ("hugim") enrollment against capacity and revenue. Fits C. R0. Report.
Operations: [`GET /v3/reports/{reportName}`](https://arboxserver.arboxapp.com/docs/api#/operations/Get%20Reports) with `hugimBookingReport`, `activeHugimReport` and `hugimRevenueReport` (both untyped).

## Ideas that need no Arbox connection

Safest first win for a nervous owner. No key, nothing in Arbox touched. Effort: Chat unless noted. Risk: none to Arbox data.

| # | Idea | Owner pitch | Fits | Notes |
|---|---|---|---|---|
| N1 | Class and service descriptions | "Make my class names and descriptions sound like us." | All | Ask for tone and three existing examples. |
| N2 | Social posts calendar | "A month of Instagram/Facebook posts and story ideas." | All | Drafts only; the owner posts. Offer Hebrew and English. |
| N3 | Message templates | "Welcome, renewal, we-miss-you, payment reminder, birthday, waitlist, holiday closures, in my voice." | All | They paste into Arbox message templates or WhatsApp. Pair with ideas 1 to 3. |
| N4 | Pricing and offer analysis | "Which pack should I promote? Is my intro offer too cheap?" | All | Needs a CSV or Excel the owner exports from Arbox reports (Academy says reports download as Excel). Work from the file; no connection. |
| N5 | Simple website or landing page | "A one-page site: classes, prices, trial signup." | All | Combine with the Arbox schedule link, embedded schedule and lead form (Free plan has online links; see product file). Claude writes the page, the owner publishes it. |
| N6 | Staff schedule, checklists, SOPs | "Opening/closing checklist, coach onboarding, cleaning rota." | All | Effort: an hour. |
| N7 | Waiver and policy wording | "A first draft of cancellation policy and waiver text." | All | Draft for review only; tell them to have a lawyer check it. Arbox stores and signs them (digital forms). |
| N8 | Review replies | "Replies to Google reviews, kind and professional." | All | Drafts only. |
| N9 | Member FAQ and onboarding pack | "What to bring, how booking works, how to freeze." | G 1 C | Good for new-member welcome. |
| N10 | Learn Arbox features | "How do I set up a punch card, penalties, check-in?" | All | Walk through the Arbox Academy lesson; see [arbox-product.md](arbox-product.md). Honesty beats building something Arbox already has. |
| N11 | Event or challenge launch plan | "A 6-week challenge: offer, schedule, messages, posts." | G | Combines N2, N3 and N4. |

## Native Arbox features to point to first

If the owner's need matches, say it plainly, give the plan gate, then offer what Claude adds on top.

| Need | Arbox already has | Plan | Claude adds |
|---|---|---|---|
| Reminders, birthday and renewal messages | Auto actions | Standard+ | Wording in their voice; a weekly review of who is not covered |
| No-show and late-cancel fines | Penalties | any (unconfirmed per tier) | Who triggers them most; wording for the notice |
| Failed card payments | Failed Transactions message and card update in the client app | UNKNOWN | A chase list across debts and failures |
| Members at risk or expiring | Reports > Retention, message from the report | Advanced reports Standard+ | Drift join, drafted outreach |
| Leads from ads | Zapier (Facebook, Instagram, Google Ads) | unconfirmed | Follow-up prioritization |
| Revenue overview | Dashboard, earnings goals, monthly history | Standard+ | Questions the dashboard does not answer |
| Check-in at the door | Check-in web app, entrance tablet | UNKNOWN | Nothing; just explain |
| Booking page for the website | Schedule link, embedded schedule, lead form | Free | A page around it (N5) |

## Choosing three

1. Filter by operating model (Fits) and plan gate.
2. Rank by their top two pains. A pain with a native feature: say so, then offer the add-on.
3. Compose: a quick win (R0, minutes: 1, 3, 5, 7, 13 or N4), a weekly-value idea (2, 4, 10), and a stretch or a no-connection idea (N5, N11, 17, 20).
4. First-time owners with a lot of caution: make two of the three no-connection ideas.
5. Never propose R3 actions. If asked, explain they stay in the Arbox app and offer the list or draft that prepares them.
