# Arbox product map, round 2

Research date: 2026-10-14. Builds on `docs/research/arbox-product.md` (round 1). Round 1 is not repeated here except where a finding changes it.

Labels: `[fetched]` = page text read this round. `[search]` = only a search summary seen. `INFERRED` = my inference. `UNKNOWN` = not found in sources checked. Fetched text passed through a summarizer, so quotes are the page's wording as reported, not verified character-for-character. Verify before publishing customer-facing copy.

Fetch count this round: about 46 (stop rule ~50). Headless Chrome `--dump-dom` returned an empty file in this environment, so all reads used WebFetch.

---

## 0. Headline findings

1. **The vertical pages are mostly one template.** Yoga, Pilates, CrossFit, gym, martial arts, dance, and personal-trainer pages use the same feature blocks and the same three testimonials and logos, with the vertical word swapped into the headline. Only the testimonial and a few nouns differ. Do not build a separate interview branch per vertical. Branch on the operating model instead (see section 6). `[fetched]` the seven vertical URLs in section 1.
2. **Arbox's public copy speaks "clients" and "members" and "staff", not "boxes" for most verticals.** "Box" appears only in CrossFit and owner testimonials. Keep the owner's own word.
3. **Plan gates confirmed on the pricing page:** CRM/lead management, auto actions, smart insights, email communication, and data migration start at Standard. Branded app starts at Professional. Reports go from Basic to Advanced at Standard. `[fetched]` https://www.arboxapp.com/pricing (checkmarks are images; a text-only read, so treat as "named in plan bullets", not as verified checkmarks).
4. **The English help center is empty.** `[fetched]` https://help.arboxapp.com/en says "This Help Center doesn't have any articles or collections yet." The Hebrew help center is the real one. The English lesson content lives on academy.arboxapp.com.
5. **Arbox has a separate Academy** with quick-help lessons in English. It covers penalties, membership types, recurring plans, check-in, and the Zapier integration in more detail than the help center. `[fetched]` https://academy.arboxapp.com
6. **Check-in is a separate web app for staff and coaches**, not a coach app in the store. `[fetched]` https://academy.arboxapp.com/lesson/check-in-interface
7. **Penalties (no-show and late-cancel fines, enforced by app blocks or membership shortening) are a real owner feature.** `[fetched]` https://academy.arboxapp.com/lesson/penalties
8. **Arbox's own copy claims scale** ("about 2.76 million active clients", "about 34.9 million bookings") but without dates, method, or scope. Use as marketing claims only. `[fetched]` https://www.arboxapp.com/verticals/smbs

---

## 1. Priority 1: vertical pages (what Arbox pitches to each)

Shared template, present on almost every vertical page `[fetched]` (see the individual URLs):
- Scheduling: "Powerful scheduling", "Maximize your availability", "Unlimited booking access with a touch of a button" (schedule link).
- Client app: "Get a professional edge with the client app" (book and pay on mobile, push reminders, forms and health waivers, sell products).
- Member records: "Manage all customer information centrally".
- Memberships: "Sell membership plans and packages".
- Marketing: "Grow your business with powerful marketing tools" (discounts, free trials, punch cards, automated class reminders, Facebook and Google ads).
- Team: "Boost your team's productivity" (auto-assign staff to sessions, staff manage their own time and payments).
- Payments: "Say goodbye to the hassles of managing financial transactions" (online payments, invoices, quotes, connected payment provider).
- Reporting: "Make simpler, smarter business decisions driven by data".
- Integrations: "Connect with industry leading platforms, and automate your work".
- Free plan: "Free forever. No credit card needed", "Unlimited time on Free plan".
- Social proof: "Join the Thousands of Businesses Already Using Arbox" (no number on the vertical pages). Logos repeated across pages: Platika, CrossFit Sacred Pine, Breaking Barre.

| Vertical | URL | Distinctive pitch or term | What is NOT on the page |
|---|---|---|---|
| Yoga (and Pilates) | https://www.arboxapp.com/verticals/yoga-pilates | "Your all-in-one yoga business management software"; "Keep your yoga business running smoothly"; "Sell membership plans and packages"; "Maximize your availability". Testimonial: Lotus Studio owner. | Instructor payouts and Pilates terms. Waitlists, attendance, reports, and payroll appear only in generic FAQ text. |
| CrossFit | https://www.arboxapp.com/verticals/crossfit-management-software | "Your all-in-one CrossFit management software"; "Keep your Crossfit studio running smoothly"; FAQ-level: attendance tracking, class capacity limits, waitlists, performance tracking. Named customers: CrossFit Sacred Pine. | WODs, leaderboards, athlete performance tools. |
| Gym | https://www.arboxapp.com/verticals/gym | Access control: "A low-cost, network-based reader for member facility access"; check-in for group sessions and appointments; "Staff accounts with selectable access and permissions, plus payroll options"; "Revenue and detailed reports, plus a mobile app for managing the gym remotely"; sales pipeline "replacing spreadsheets"; "Marketing Suite" adds drip campaigns and referral and reputation programs; card updater on memberships; "priority booking, retail discounts". Testimonial: gym owner. | Equipment. |
| Martial arts | https://www.arboxapp.com/verticals/martial-arts | "Your all-in-one martial arts studio management software"; "Power up your marketing & client relationships"; testimonial: "Dojo on Main Street" ("handle all aspects of my box"). | Belts, grading, kids classes, family plans. Martial-arts vocabulary is absent. |
| Pilates | https://www.arboxapp.com/verticals/pilates | "Your all-in-one Pilates management software"; "Keep your pilates business running smoothly". Testimonial: "Yoga & Pilates Studio Owner". | Reformer, equipment, private Pilates sessions (page says "personal and group training"). |
| Dance | https://www.arboxapp.com/verticals/dance | "Your all-in-one dance studio management software"; "Grow dance studio"; sales funnel tracking and lead touchpoint history; Marketing Suite with customer profiles from "interactions, visits, and purchases"; "Point-of-sale: integrated in-studio payments with appropriate hardware"; booking through "website, Arbox app, Google, and a branded mobile app". Testimonial: Dance Instructor. | Recitals, levels, students, parents, tuition. Page uses "clients", "members", "trainees", "staff". |
| Personal trainer | https://www.arboxapp.com/verticals/personal-trainer | "Manage All Customer Information Centrally"; "Professional CRM"; "Keep Your PT Business Running Smoothly" (digital invoices, cut paperwork); "Make simpler, smarter business decisions driven by data"; testimonial Sid Blackburn, Personal Trainer. | Progress tracking, online training, training-program management. |
| Wellness and clinics | https://www.arboxapp.com/verticals/wellness | The only vertical with clinical vocabulary: "Easy Scheduling" (share availability, sync calendars, reschedule missed appointments); 1:1 and group sessions with "invitee limits"; "Online sessions" (virtual care); "Daily Operations" (automate patient follow-ups, paperwork, payment collection); "No More Waiting to Be Paid"; "automated appointment reminders and follow-ups, plus health tips and preventive notifications"; "digital health forms" with electronic signature; business types: spas, massage, nutritionists, physiotherapists, health clinics, chiropractors, psychologists. | Treatment records, clinical or medical records, insurance. The page does NOT claim treatment records, but the help center has "export and send treatment documentation (PDF)" (round 1, `help.arboxapp.com/he/articles/15053654`). |
| Beauty | https://www.arboxapp.com/verticals/beauty | Appointments: "Schedule and manage your salon's appointments to get paid faster"; "Stay on Top of Your Team's Performance": subcontractors, team reminders, hours and productivity, per-person commission rate, staff payouts, client assignment to team member; loyalty program ("Digital rewards for repeat clients"); waitlists; "Track and monitor your salon's performance with real-time business insights". Business types: hair salons, makeup artists, nail technicians, barber shops, lash and brow technicians, tanning salons, beauticians. | "Chair" and "treatment" terms. |
| Education | https://www.arboxapp.com/verticals/education | "Build and Manage a Successful Teaching Business"; "Book Your Classes Online"; "Fill Up Every Class"; "Get Paid in Seconds". Lessons: 1:1 classes, availability sharing (student picks a slot), group sessions, home assignments and follow-ups sent in the app, onboarding forms for new students. Courses as recurring events over a set period. Online video classes hosted through Zoom. Automatic SMS and email class reminders. Payments via Stripe with payment-due reminders. | Parents or guardians. |
| Activities | https://www.arboxapp.com/verticals/activities | Activity types named: shooting ranges, paintball, escape games, hiking, parks, ATV rentals. Booking, group and 1:1 sessions, workshops, and courses. Staff hours, overtime, and workload. Reminders by SMS, email, and push. Single or recurring payments, payment schedules, and automated dues collection. Payments in "over 40 currency types". Group-booking special rates. Contracts and renewals management. | Equipment rental, waiver or liability forms (only "digital forms"), activity-specific pricing (per hour or session). |
| Fitness (umbrella) | https://www.arboxapp.com/verticals/fitness | "Build a powerful fitness business". Sub-verticals with dedicated pages: yoga, Pilates, CrossFit, gym, martial arts, dance, personal trainer. Boxing clubs: listed, link is a placeholder. Spinning: named only. Claims integrations with accounting, email marketing, and social media tools. | |
| Small business (umbrella) | https://www.arboxapp.com/verticals/smbs | "Organize your business schedule from any device"; "Easily manage your time, team, revenue and clients"; "Boost sales, build relationships and keep clients engaged"; "Provide simple, secure in-app and in-store payments"; "24/7 access control" for member entry; configurable cancellation rules (three levels, from free cancellation to late-cancel charges); registration closing time; claimed results: "about 32.5 million sessions, about $1.51 billion in transactions, about 34.9 million bookings, about 2.76 million active clients". | No date or method for the numbers. |
| Companies (corporate wellbeing) | https://www.arboxapp.com/features-pages/arbox-for-companies | "Easily plan your company's wellbeing activities with Arbox". Team-building, yoga, meditation activities; merged team calendars; employee self-service "branded self-service app" with 24/7 access, who is attending, invite friends; third-party assessments and certifications tracked; dynamic waitlists; Zoom sessions; testimonial: VP People at ironSource. | Company-specific reporting detail. |

**Vertical take-aways for the skills**
- Only four real operating models appear across the pages:
  1. **Group classes and memberships** (yoga, Pilates, CrossFit, gym, martial arts, dance, spinning): sessions, capacity, waitlist, punch cards, memberships, check-in.
  2. **1:1 appointments with staff** (personal trainer, wellness and clinics, beauty, tutors): availability, appointment reminders, staff commission or payouts, documents.
  3. **Courses and workshops** (education, activities, corporate): recurring events, registration cutoffs, group caps, waivers.
  4. **Venue or event bookings with attendance** (activities, companies): group sessions, spaces, attendance.
- Vertical copy is marketing. Model the operating model, not the label.

---

## 2. Priority 2: feature pages not yet read

### 2a. Operations (`/features-pages/managing-your-everyday`)
`[fetched]` https://www.arboxapp.com/features-pages/managing-your-everyday
- Headlines: "Manage your business on the fly"; "Cut out the busywork with automations"; "Manage your team to maximum productivity".
- Team: hours, overtime, workload; share updates; assign members to clients; team tasks with boards, reminders, tags and statuses.
- Documents: contracts, agreements, and proofs for clients to sign.
- Clients: member profiles, reminders to reduce no-shows, personalized offers, custom booking forms, cross-sell and upsell identification, client files and notes.
- Automations: appointment reminders, automatic replies to queries, personalized follow-ups, automatic emails, forms, and invoices, recurring task automation, automated payment processing, lead workflows, and custom triggers that fire on conditions or at set times.
- Smart insights: this page does not describe them. See 2d.
- Not on the page: subcontractors (the beauty page has them), permissions (the gym page has them).

### 2b. Reporting and analytics (`/features-pages/reporting-and-analytics`)
`[fetched]` https://www.arboxapp.com/features-pages/reporting-and-analytics
- Real-time dashboard: "a 360 overview of your business".
- Finance: compare monthly financial history; profit breakdown; accounts chart (income and expenses by category); earnings goals (annual or monthly targets with progress).
- Booking analytics: attendance and booking performance.
- Overdue reminders: automatic client notifications for missed payments.
- Membership forecast: attendance and client predictions for the next year.
- Lead statistics: new leads, converted leads, trial classes.
- Metrics named: profit and loss, top services, staff performance, site traffic, client attendance, referral sources, popular services, revenue and balance, expired subscriptions, paid/pending/overdue payments, subscription status, salaries and sales, team earnings.
- Comparisons: new vs returning clients.
- "Smart insights" appears in the reporting and finance sections. No detail given.
- Exports: none mentioned on this page. The Academy reports lesson says Excel download (see section 3).

### 2c. Fitness CRM (`/features-pages/fitness-crm`)
`[fetched]` https://www.arboxapp.com/features-pages/fitness-crm
- "Convert your potential leads into paying customers".
- Pipelines: mentioned in passing ("enhance your sales pipeline by effectively managing leads"); no stages described.
- Lead sources: not specified. Import "from other sources".
- Register new lead directly into a class or event ("Register New Lead" under "Manage Participants").
- Automated tasks: "Cut out the busywork with automated tasks".
- Waitlists: auto-promote, or request approval within a time window.
- Registration closing time: blocks last-minute sign-ups.
- Segments: target groups likely to buy; cross-sell and upsell.
- Engagement: email campaigns and SMS notifications.
- Lead forms as a CRM feature: not listed. Client app collects forms and waivers.
- Lost reasons: not mentioned.
- Plan: Free lists "Unlimited time"; paid tiers on pricing page. Pricing page puts "Task and lead management" on Standard.

### 2d. Website (`/features-pages/website`)
`[fetched]` https://www.arboxapp.com/features-pages/website
- "Get your own personalized link with a dedicated url" (schedule link).
- Embedded schedule: copy HTML from the schedule link page into an existing website, or give it to a developer.
- Lead capture form: "Turn Leads into Clients".
- Online store link: "no coding skills needed".
- Memberships, subscriptions, and punch cards offered from the link.
- Payments at booking once a payment provider is connected.
- Offerings created in the management system appear automatically on the schedule link.
- Not described: templates, custom domains, SEO, languages.

### 2e. Automations and auto actions
`[fetched]` https://www.arboxapp.com/features-pages/managing-your-everyday (see 2a) and https://www.arboxapp.com/pricing ("Auto actions" on Standard).
- No Arbox help-center article on auto actions was found in Hebrew or English. `[search]` searches for Hebrew "אוטומציות" returned nothing from help.arboxapp.com. UNKNOWN: the help-center article titles.
- Academy "Penalties" is an automation of sorts (absence rule triggers a block or shortened membership). `[fetched]` https://academy.arboxapp.com/lesson/penalties
- Zapier triggers and actions cover the rest of the automation surface. `[fetched]` https://academy.arboxapp.com/lesson/zapier-arbox-integration

### 2f. Smart insights
- Named on the pricing page for Standard and up. `[fetched]` https://www.arboxapp.com/pricing
- The reporting page names "Smart insights" beside dynamic reports but describes no AI. `[fetched]` https://www.arboxapp.com/features-pages/reporting-and-analytics
- Arbox's own pages mention no AI feature. Third-party integration pages claim "AI-powered analytics" for the Boost.space connector and an AI-workflow integration by meinGPT. These are integrations, not Arbox features. `[search]` https://boost.space/integrations/arbox/?view=mcp and https://meingpt.com/en/integrations/automate-arbox-with-ai
- **INFERRED:** "Smart insights" is a reporting feature, not AI. Do not describe it as AI until Arbox says so. UNKNOWN: what the insights are.

### 2g. Marketing (`/features-pages/marketing-sales`)
Round 1 covered this page. Round 2 additions come from the vertical pages and CRM page:
- Marketing Suite (gym page): drip campaigns, referral and reputation programs, customer profiles from interactions, visits, and purchases.
- Email communication (pricing page, Standard).
- Dance page: lead touchpoint history; sales funnel tracking.
- Booking reminders by SMS, email, and push. `[fetched]` https://www.arboxapp.com/verticals/activities

### 2h. Member (client) app (`/features-pages/customer-app`)
`[fetched]` https://www.arboxapp.com/features-pages/customer-app
- Headline: "Taking customer experience to the next level".
- Book, change, pay, renew memberships and subscriptions, buy shop products, sign up for events, share schedules, invite friends.
- Personalized feed with real-time stats and activity; "24/7 client access" through a branded self-management app.
- In-app direct messaging; push notifications for reminders, updates, special offers, greetings.
- "Triggers" send messages to the right client at the right time (business-side tool, not a client feature).
- Branded app: Professional tier, requested through support (round 1 `[fetched]`).
- Store names: members app published under "Arbox LTD" (round 1 `[search]` on App Store).

### 2i. Coach app
- **No separate coach app found.** Coaches, trainers, and staff use the check-in web app. `[fetched]` https://academy.arboxapp.com/lesson/check-in-interface
- Check-in access: any computer, phone, or tablet, at `checkin.manage.arboxapp.com/login-check-in`, with the same login as the management platform and client app. Manager sees all staff events; Staff Member, Coach, and Trainer see only the events they conduct.
- A search summary also cites `checkin.arboxapp.com` as the coach sign-in domain. `[search]` https://help.arboxapp.com/en/articles/5320237-add-new-staff-member (article itself returned 404 this round). Two domains, one purpose. Verify which is current.

### 2j. Access control and check-in
- Check-in interface (above). Shows the schedule, marks attendance for today or past events only (no future check-in), and lets staff see flags on members:
  - Leads: purple background.
  - "NEW": joined under 30 days ago.
  - Cake icon: birthday.
  - Debt indicator: hover or tap to see amount owed.
  - Injury warning icon: shown if "Display member injuries on Checkin platform" is on in Settings > Preferences.
- A tablet can sit at the entrance so clients mark their own attendance. Lesson advises hiding sensitive details in that setup. `[fetched]` https://academy.arboxapp.com/lesson/check-in-interface
- Entry control: "Business entry via QR code and chip" is a Zapier trigger. `[fetched]` https://academy.arboxapp.com/lesson/zapier-arbox-integration
- Hardware: "network-based reader" and "24/7 access control" are marketing lines with no spec. `[fetched]` https://www.arboxapp.com/verticals/gym and https://www.arboxapp.com/verticals/smbs
- Hardware vendor, model, and setup: UNKNOWN.

### 2k. Other pages seen
- Integrations page and Zapier: section 3 and round 1.
- Partnership pages: round 1.
- Companies page (corporate wellbeing): section 1.

---

## 3. Priority 3: help center and Academy

### 3a. Hebrew help center collections
`[fetched]` https://help.arboxapp.com/he (home lists six collections):

| # | Hebrew | English | URL | Articles listed |
|---|---|---|---|---|
| 1 | ניהול לקוחות ומתעניינים | Customer and lead management | https://help.arboxapp.com/he/collections/10628205-ניהול-לקוחות-ומתעניינים | 2: length of engagement (LEG); replacing an existing class registration with a new one |
| 2 | לוח הזמנים | Schedule | https://help.arboxapp.com/he/collections/8857409-לוח-הזמנים | 7: session notes in calendar; personal appointments for clinics and therapists; export and send treatment documentation (PDF); Google Calendar sync; group sign-up limits by age and gender; track management; (plus round 1 items) |
| 3 | פיננסים | Finance | https://help.arboxapp.com/he/collections/10628208-פיננסים | 7: bulk price update for standing orders; cookie data by browser; cash and check deposit add-on; expense add-on; allocation number change; accounting setup and Hashavshevet export; umbrella organizations |
| 4 | חברויות ומוצרים | Memberships and products | https://help.arboxapp.com/he/collections/10636074-חברויות-ומוצרים | 2: freezing a standing-order membership; custom link after payment |
| 5 | אפליקציית לקוחות ואתר ההרשמות | Customer app and registration site | https://help.arboxapp.com/he/collections/10636075-אפליקציית-לקוחות-ואתר-ההרשמות | 1: logging in to the registration site with a phone |
| 6 | כלים מתקדמים | Advanced tools | https://help.arboxapp.com/he/collections/10636082-כלים-מתקדמים | 3: WhatsApp integration guide; inventory add-on; payroll report |

Recently added (home page): payroll report; expense add-on; Google Sync; clinic personal appointments; allocation number; inventory add-on.

**Caveat:** the summarizer returned few titles per collection. The collection pages may load more articles by script. Titles listed are what the page showed, not a verified full list. The CRM collection in particular looks incomplete. UNKNOWN: full article count.

Titles in round 1 that were fetched there and are still valid: standing-order freeze, custom post-payment link, Hashavshevet export, allocation number, expense add-on, cash/check add-on, personal appointments, treatment PDF, WhatsApp personal-appointment messages, age and gender limits, tracks, Google Sync, client app phone login.

### 3b. Academy (English lessons, `academy.arboxapp.com`)
Categories: Product Updates, Integrations, Client management, Bookings website, Schedule, Client App, Platform fundamentals, Backstage. `[fetched]` https://academy.arboxapp.com
Courses: "Getting Started" with lessons on Introduction, Group Sessions, Appointments and Availabilities, Spaces Management, Categories, Toolbar and Schedule Settings. `[fetched]` https://academy.arboxapp.com/academy-courses/getting-started
Course topics: Getting started; Scheduling; Marketing & Sales; Payments; Integrations; Client app.
Quick-help lessons: Check-in interface; Recurring Plan; New Releases; Convert Client to Lead (404 on fetch); Toolbar and Schedule Settings; Introduction; Appointments and Availabilities; Group Sessions; Categories; Spaces Management; Bookings Website; Client App; Membership Types; Zapier and Arbox integration; Zapier and Facebook integration; Penalties.

### 3c. Requested help-center articles, read in full

**Reports.** `[fetched]` https://academy.arboxapp.com/quick-help-articles/reports
- Three report groups:
  - **Essentials:** active members and staff; daily operations: transactions, bookings, session summaries.
  - **Growth:** prospects and leads; lead statistics at each stage; lead revenue; share of new leads converted to paying clients.
  - **Retention:** clients at risk: not visited or bought from shop recently; memberships expiring without renewal.
- Reports can be messaged from: e.g., remind clients to renew expiring memberships, check in with clients who missed several sessions.
- Favorites tab for starred reports. Downloads as Excel. No filters described. No report names in Hebrew.

**Automations and auto actions.** UNKNOWN in Hebrew and English help. Covered by features page and Zapier (above).

**Leads pipeline.** No dedicated article. Academy "Convert Client to Lead" returned 404. Facts from the Zapier lesson (`[fetched]`): triggers "New lead created", "Lead converted to client", "Mark lead as 'Lost'"; actions "Create new lead", "Update lead status". Lead statuses, sources, and lost reasons exist in the API (round 1).

**Messaging and WhatsApp.** Article titles only this round. Round 1 said these exist: "WhatsApp integration guide for the system" (`https://help.arboxapp.com/he/articles/11196342-...`) and "automatic WhatsApp messages for personal calendar appointments" (`.../15493834-...`). Not re-read this round. UNKNOWN: the WhatsApp setup steps.

**API.** Help article 9013934 returned 404 on the fetch this round. Academy Zapier lesson gives the key location: "Settings >> Club Information" (`[fetched]` https://academy.arboxapp.com/lesson/zapier-arbox-integration). Round 1's search summary said "Settings → Business Information". Two labels for one place. Verify in the product.

**Settings, permissions, roles.**
- Staff roles named in the check-in lesson: Manager; Staff Member; Coach; Trainer. Manager sees all; the rest see only their own events. `[fetched]` https://academy.arboxapp.com/lesson/check-in-interface
- "Staff accounts with selectable access and permissions" on the gym page. `[fetched]` https://www.arboxapp.com/verticals/gym
- English staff article 404 on fetch. `[search]` only.
- Penalty setup path: Settings > Business Settings > Penalties > Add penalty. `[fetched]` https://academy.arboxapp.com/lesson/penalties
- Recurring payment setup: Settings > Finance > edit "Recurring Payment". `[fetched]` https://academy.arboxapp.com/lesson/recurring-plan
- Membership plan setup: Settings > Membership types > "Add New Membership Plan". `[fetched]` https://academy.arboxapp.com/lesson/membership-types

### 3d. Penalties (Academy, Backstage category)
`[fetched]` https://academy.arboxapp.com/lesson/penalties
- Triggers when absences reach a set limit (example: two absences in seven days).
- Absence types: late cancellation (set in each event's schedule rules), no-show, or both.
- Penalty types:
  - Block and cancel: blocks app access for set days, cancels current registrations.
  - Block without canceling: blocks app access for several days.
  - Shorten membership: shortens by a few days; only works with an end date.
- Timing: after the event; immediate enforcement not available so staff can mark attendance first.
- New memberships must be added manually to the penalty.
- Client notification: push, SMS, email, or combined, with a template.
- Who sets it up: the owner in the management platform. Roles not named.

### 3e. Membership types and punch cards
`[fetched]` https://academy.arboxapp.com/lesson/membership-types
- Membership plan fields: plan name, location, price, expiration period, "Show in Shop", "Recurring Payment Plan" (checkbox; billing every week, bi-weekly, or month; recurring plans priced as monthly).
- **Session Punch Card** (Settings > Session Punch Cards > "Add New Session Punch Card"): plan name, location, number of entrances, price, expiration (example 6 months), "Show in Shop".
- No time-based or unlimited type named in the lesson.

### 3f. Recurring payments and failed charges
`[fetched]` https://academy.arboxapp.com/lesson/recurring-plan
- A declined charge on an active recurring payment can block the client. Causes named: stolen or blocked card, maxed credit.
- A declined charge creates a debt for the client.
- Settings > Finance > "Recurring Payment": allow clients to update card in the client app; "immediate payment" closes the debt.
- Transactions > "Failed Transactions" sends clients a debt and card-update message.
- Client app: Feed shows "Transaction failed"; client taps "Update Payment Method", then "Pay Now"; registrations reopen after the debt clears.

### 3g. Zapier integration
`[fetched]` https://academy.arboxapp.com/lesson/zapier-arbox-integration
- Key from Settings >> Club Information. Zapier "Add connection" with the key. Free to use; some other apps need a paid Zapier plan.
- Triggers: New lead created; Lead converted to client; New client created; A member renewed their membership; Enrolled from waitlist; Canceling registration (end-user); Credit refusal (recurring plans); Registration for X events; New purchase; Business entry via QR code and chip; Mark lead as "Lost"; Sign digital form; X attendance marks.
- Actions: Create new lead; Create new client; Create new task; Create new purchase; Send message; Update lead status; Search client; Get schedule; Create group session.
- Round 1 listed Zapier apps including Facebook/Instagram lead ads, Google Ads, Mailchimp, QuickBooks, Square, WooCommerce, Google Sheets, Airtable, Slack, WATI. `[fetched]` https://www.arboxapp.com/features-pages/integrations

---

## 4. Priority 4: round 1 Unknowns, resolved one by one

| # | Round 1 Unknown | Status | Evidence |
|---|---|---|---|
| 1 | Customer counts, box sizes, revenue bands | **Still UNKNOWN.** Arbox claims totals (2.76M active clients, 34.9M bookings, $1.51B transactions) with no date or method. | https://www.arboxapp.com/verticals/smbs |
| 2 | Home market is Israel | **Still INFERRED.** Hebrew is the primary help-center language; Hashavshevet and allocation-number articles. English help center empty. | https://help.arboxapp.com/he ; https://help.arboxapp.com/en |
| 3 | Per-tier availability (memberships, waitlists, Stripe, CRM, automations) | **Partly resolved.** Confirmed on text: CRM/leads, auto actions, smart insights, email, data migration = Standard+. Branded app = Professional. Reports: Basic (Free, Basic), Advanced (Standard, Professional). Still UNKNOWN: memberships, waitlists, Stripe, SMS, API access, access control, POS, Enterprise reports. Invoicing has footnote "*Requires an additional fee" yet Free lists "Payments & Invoicing": a page conflict. | https://www.arboxapp.com/pricing |
| 4 | API key: plan gate, issuer, who sees it | **Partly resolved.** Location: Settings > Club Information (Academy). Round 1 said "Business Information" from search. Plan gate, issuer, and visibility still UNKNOWN. | https://academy.arboxapp.com/lesson/zapier-arbox-integration ; https://help.arboxapp.com/he/articles/9013934-api-documentation-arbox (404) |
| 5 | API article full text | **Still UNKNOWN.** 404 this round too. | same as 4 |
| 6 | Coach app | **Partly resolved.** No store coach app. Coaches sign in to the check-in web app at checkin.manage.arboxapp.com/login-check-in; coaches see only their own events. A second domain, checkin.arboxapp.com, appears in a search summary. | https://academy.arboxapp.com/lesson/check-in-interface |
| 7 | Check-in and access-control hardware and API | **Partly resolved.** Check-in: web app, QR and chip entry as a Zapier trigger, injury flags, debt flags. Hardware vendor and model still UNKNOWN. API: no check-in endpoint in round 1 spec. | https://academy.arboxapp.com/lesson/check-in-interface ; https://academy.arboxapp.com/lesson/zapier-arbox-integration |
| 8 | SMS and email via `POST /v3/message` | **Still UNKNOWN from this research.** Zapier "Send message" action exists; the channel list in its docs was not read. Round 1 spec says push and WhatsApp only. | https://academy.arboxapp.com/lesson/zapier-arbox-integration (action exists, channels not stated) |
| 9 | Google Play listing and member app rating | **Still UNKNOWN.** Play page returned 404 with the package name tried (`com.arboxapp`). Package name not verified. App Store rating: round 1 search only. | https://play.google.com (404) |
| 10 | Pages not fetched: operations, reporting, fitness-crm, website, all vertical pages | **Resolved.** All read this round (section 1 and 2). | URLs in sections 1 and 2 |
| 11 | Owner communities | **Still UNKNOWN.** Not searched. | none |
| 12 | Whether cash, expense, inventory add-ons cost extra | **Still UNKNOWN.** Pricing footnote mentions "additional fee" for invoicing only. | https://www.arboxapp.com/pricing |
| 13 | Languages beyond Hebrew and English | **Still UNKNOWN.** | none |

New unknowns this round:
- 14. Full list of Hebrew help-center articles per collection (collection pages returned partial lists).
- 15. Leads pipeline details: stages, sources, lost reasons in product UI (Academy lesson 404).
- 16. Automation: list of auto actions and the UI for building them.
- 17. WhatsApp setup (both help articles from round 1 not re-read).
- 18. Whether "Smart insights" uses AI.
- 19. Whether checkin.arboxapp.com or checkin.manage.arboxapp.com is the current coach domain.
- 20. Access-control hardware vendor, pricing, and integration.

---

## 5. Priority 5: owner vocabulary

### 5a. Hebrew (from Arbox's own help-center titles and collection names)

| Hebrew | Meaning in context | Source |
|---|---|---|
| לוח הזמנים | Schedule (the calendar and its settings) | collection name, help.arboxapp.com/he/collections/8857409 |
| ניהול לקוחות ומתעניינים | Client and prospect management ("prospects" = מתעניינים, used for leads) | collection 10628205 |
| פיננסים | Finance | collection 10628208 |
| חברויות ומוצרים | Memberships and products (חברות = membership) | collection 10636074 |
| אפליקציית לקוחות ואתר ההרשמות | Client app and registration site (אתר הרשמות = sign-up site) | collection 10636075 |
| כלים מתקדמים | Advanced tools | collection 10636082 |
| הוראת קבע | Standing order / recurring charge (bank-style) | article 10290056 and 12743229 |
| הקפאה | Freeze (of a membership) | article 12743229 |
| לחוג / חוג | A class or club activity; "registration to a class" = הרשמה לחוג | article 15692332 (singular form only) |
| הרשמה | Registration / sign-up | several articles |
| מסלולים | Tracks (a sequence of classes) | article 15804161 |
| פגישות אישיות | Personal (one-to-one) appointments | article 12309679 |
| מטפל / מטפלים | Therapist / practitioner | article 12309679 |
| תיעוד טיפול | Treatment documentation | article 15053654 |
| תוסף | Add-on (paid module) | articles 15253772, 15254135, 15694021 |
| הנהלת חשבונות | Bookkeeping / accounting setup | article 16131156 |
| חשבשבת | Hashavshevet (accounting software name) | article 16131156 |
| מספר הקצאה | Allocation number (invoice-related, Israel) | article 15265492 |
| ארגונים מאגדים | Umbrella organizations | article 16451528 |
| דוח השכר | Payroll report | article 15516336 |
| הפקדות מזומן ושיקים | Cash and check deposits | article 15253772 |
| מלאי | Inventory | article 15694021 |
| מסלול / מסלולים | track | article 15804161 |
| אתר הרשמות | registration website | article 11873321 |

UNKNOWN: "חוגים" (plural). Not found on any page checked. Round 1's "hugim" is not confirmed by Arbox.

### 5b. English (product UI labels and owner terms)

Product labels (from Academy and pricing pages):
- **Schedule** (sidebar), **Client management**, **Client App**, **Bookings website** (also "schedule link", "Online links" on the features page), **Spaces** (Spaces Management), **Categories** (calendar events organization), **Group Sessions**, **Appointments and Availabilities**.
- **Membership types** (Settings), **Add New Membership Plan**, **Session Punch Card**, **Show in Shop**, **Recurring Payment Plan**.
- **Penalties** (Settings > Business Settings), **Late Cancellation**, **No Show**, **Block and cancel**, **Block without canceling**, **Shorten membership**.
- **Recurring Payment** (Settings > Finance), **Failed Transactions** (Transactions), **Update Payment Method**, **Pay Now**.
- **Auto actions**, **Smart Insights**, **Task and lead management**, **Email communication**, **Data migration** (pricing page).
- **Check-in** (web app), **Manager**, **Staff Member**, **Coach**, **Trainer**.
- **Registration Closing Time**, **Waitlist** (auto-promote or approval).
- **Marketing Suite** (drip campaigns, referral and reputation).
- **Card updater** (expired card details).
- **Penalties**, **Triggers** (messages sent on conditions).

Owner terms used in testimonials and vertical copy:
- **"box"**: CrossFit boxes; a martial arts owner says "handle all aspects of my box". Use only if the owner uses it.
- **"studio"**: yoga, Pilates, martial arts, dance.
- **"gym"**: gym page and CrossFit boxes.
- **"salon"**: beauty.
- **"clients"** vs **"members"**: Arbox uses both. Pricing uses "clients" in marketing and "members" for the app. Ask the owner which they use.
- **"trainees"**: personal trainer page.
- **"instructor"**, **"coach"**, **"trainer"**, **"staff"**: staff roles.
- **"punch card"**: session punch card (count of entries). Marketing says "punch cards" on most pages.
- **"free trial"**, **"trial classes"** (API term), **"no-show"**, **"late cancel"**, **"waitlist"**.
- **"wellbeing"**: corporate page.

---

## 6. What changes for the skills

### 6a. Guide interview (branch on operating model, not vertical)
Ask first: "What do you sell: classes, 1:1 sessions, courses, or bookable spaces?" Then branch:

1. **Group classes and memberships** (yoga, Pilates, CrossFit, gym, martial arts, dance, spinning):
   - Ask: "Do you sell monthly memberships, session punch cards, or single classes?" (Membership types and Session Punch Card are the only named plan types.)
   - Ask: "Do you need a waitlist?" (auto-promote or approval; Standard+ tier? UNKNOWN for waitlists.)
   - Ask: "Do you need to check members in at the door?" (check-in web app on any device; entrance tablet option.)
   - Ask: "Do you charge a fee for no-shows or late cancels?" (Penalties.)
2. **1:1 appointments** (personal trainer, clinics and therapists, beauty, tutors):
   - Ask: "Do staff get commission or payouts?" (beauty page: commission and payouts; personal trainer page: staff manage own payments.)
   - Ask: "Do you need treatment notes or PDF documentation?" (help center article 15053654.)
   - Ask: "Do you run online sessions over Zoom?" (wellness and education pages.)
   - Ask: "Do clients need health forms signed?" (digital forms and e-signature.)
3. **Courses and workshops** (education, activities, corporate):
   - Ask: "Do you have age or gender restrictions on sign-ups?" (help article 15554794.)
   - Ask: "Do you need a cutoff time for sign-ups?" (Registration Closing Time.)
   - Ask: "Do clients need to sign waivers?" (digital forms; no waiver-specific product confirmed.)
4. **Multiple branches**: ask "one location or several?" Locations endpoint exists in the API. Round 1 flagged D5 as unverified.

Ask on every branch:
- "What do you call your clients?" (box/studio/gym/salon) and "Is it clients or members?"
- "Which plan are you on?" (Free, Basic, Standard, Professional, Enterprise). Standard is needed for auto actions, smart insights, lead management, email. Professional is needed for a branded app.
- "Do you take payments online, in-store, or both?" (in-store payments and POS: POS hardware UNKNOWN.)
- "Do you use WhatsApp or SMS for reminders?" (WhatsApp via Meta is in the API spec; SMS sending via API is UNKNOWN.)

### 6b. Ideas catalog (every idea needs a plan gate and a risk tag)
Gate labels: [plan] = pricing page says Standard+ / Professional; [unknown] = no plan evidence.

- **No-show and late-cancel penalties** [unknown plan]: "block and cancel" after two absences in seven days. Risk: money and access. Gate writes.
- **Expiring-membership renewal outreach** [Standard? unknown]: use Retention reports, then message. Risk: messaging. Gate sends.
- **Dropped-attendance outreach** [unknown]: report of clients who missed several sessions, then message.
- **Failed-payment recovery** [unknown]: Failed Transactions message, card update in app, "Pay Now". Risk: money.
- **Lead to client funnel** [Standard+]: Growth reports; lead statistics; trial classes; converted leads.
- **Zapier lead intake** [unknown plan]: Facebook and Instagram lead ads, Google Ads to "Create new lead". Risk: data entry.
- **Birthday and new-member flags** [unknown]: cake icon and NEW badge at check-in; no automated message is documented.
- **Injury flags at check-in** [unknown]: enable "Display member injuries on Checkin platform" for CrossFit, martial arts, PT. Risk: health data; gate by staff role.
- **Entrance tablet check-in** [unknown]: client self check-in. Hide sensitive fields.
- **Schedule link on Instagram or website** [any tier?]: schedule link is on Free. Embedded schedule HTML for a site builder or developer.
- **Membership plans with "Show in Shop"** [any tier?]: shop listing in the app.
- **Staff commission report** [unknown]: beauty page; payroll report article 15516336.
- **Accounting export to Hashavshevet** [unknown plan; Israel only]: requires setup article 16131156.

### 6c. Recipes (step-by-step owner tasks)
Each recipe needs a source article or Academy lesson before it ships.

1. **Set up a punch card**: Settings > Session Punch Cards > Add New Session Punch Card > name, location, entries, price, expiration, Show in Shop. Source: Academy membership-types lesson.
2. **Set up a recurring membership**: Settings > Membership types > Add New Membership Plan > tick Recurring Payment Plan > choose cycle. Price as monthly. Source: same.
3. **Set up a no-show penalty**: Settings > Business Settings > Penalties > Add penalty > absence rule, types, penalty type, timing, memberships, notification. Source: Academy penalties lesson.
4. **Recover a failed recurring payment**: Settings > Finance > Recurring Payment (allow card update in app); Transactions > Failed Transactions to message. Source: Academy recurring-plan lesson.
5. **Connect a lead source through Zapier**: Settings > Club Information (copy key) > Zapier > My Apps > Add connection > Arbox > paste key > pick trigger (e.g. New lead created). Source: Academy Zapier lesson.
6. **Set up check-in**: open checkin.manage.arboxapp.com/login-check-in (or the second domain: UNKNOWN which is current), sign in with management login, pick the day, tap the event. Source: Academy check-in lesson.
7. **Use the Growth report**: open Reports > Growth, read lead stages and conversion share, and message leads from the report. Source: Academy reports lesson.

### 6d. Guardrails from this round
- Do not describe vertical pages as deep. They are one template. Say so when an owner asks "do you do X for my kind of business?" and check the feature instead.
- Do not say "AI" for smart insights. Mark as UNKNOWN.
- Do not quote the "Thousands of Businesses" or the millions figures as facts. Marketing claims with no method.
- Show the API key menu path as "Settings > Club Information (per Academy); older label Business Information" until verified.
- Use "invoicing requires an additional fee" as UNKNOWN until the price page is checked against the account.
- English help center is empty. Any English owner should be pointed to Academy lessons, not help.arboxapp.com/en.
- Penalties, recurring charges, and bulk price updates touch money or access. Gate write actions as in round 1.
- Round 1 is still right about Hebrew-first terms. Add the glossary in 5a to the guide's terms file, not inline in prompts.
