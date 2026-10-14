# Arbox product map

Research date: 2026-10-14. Companion to `docs/research/arbox-api.md` (API map).

Citation convention: full URLs. `[fetched]` = page text read in this research. `[search]` = only the search-index summary was seen (page not fetched or fetch failed). `INFERRED` = my inference, not stated by a source. `UNKNOWN` = not found in the sources checked.

Sources that 404'd or 429'd during fetch are marked as such. Fetched content comes through a summarizer, so exact wording is paraphrased unless in quotes.

---

## 1. Who the customers are

**Business types (Arbox's own claim).** The vertical pages list Fitness (yoga, Pilates, CrossFit, boxing/MMA, spinning), Wellness (spas, massage, nutritionists, physiotherapists, clinics), Activities (shooting ranges, escape games, hiking, ATV rentals), Education (tutors, language and music teachers), Beauty (salons, barbers, nail technicians), and Small business. Sub-pages exist for yoga-pilates, crossfit, gym, martial-arts, pilates, dance, and personal-trainer. [fetched] https://arboxapp.com (vertical links on the home page). Sub-pages were listed but not fetched.

**Clinics and therapists are a real segment.** The help center has articles for "personal meetings for clinics and therapists" and for exporting treatment documentation as PDF. [fetched] https://help.arboxapp.com/he/collections/8857409-לוח-הזמנים → https://help.arboxapp.com/he/articles/12309679-ניהול-פגישות-אישיות-לקליניקות-ומטפלים and https://help.arboxapp.com/he/articles/15053654-ייצוא-ושליחת-תיעוד-טיפול-pdf

**Sizes.** UNKNOWN. No customer counts, box counts, or tiers-by-size were found on the pages checked. Pricing tiers imply solo to multi-location. Enterprise adds "multi-location rollout" per [search] https://exercise.com/grow/how-much-does-arbox-cost (a competitor site, low trust).

**Countries and languages.**
- The help center's primary language is Hebrew. English is available by toggle, and the Hebrew version is what the collection redirects land on. [fetched] https://help.arboxapp.com
- Several help-center titles reference Israeli-specific systems: an export to Hashavshevet (Israeli accounting software), an "allocation number" change (likely Israeli Tax Authority invoice allocation). [fetched] https://help.arboxapp.com/he/collections/10628208-פיננסים → https://help.arboxapp.com/he/articles/16131156-הגדרת-הנהלת-חשבונות-וייצוא-לחשבשבת and https://help.arboxapp.com/he/articles/15265492-מספר-הקצאה-מה-השתנה-ומה-יש-לעשות
- **INFERRED:** Israel is the home market. The marketing site is English-only and says nothing about countries. Stripe availability "varies by country" [fetched] https://www.arboxapp.com/features-pages/payment-processing.
- Capterra reviews do not state reviewer countries in the summary read, so they do not settle the market question. [fetched] https://www.capterra.com/p/184438/Arbox/reviews/
- Marketing-site pricing is in USD, with no currency or country named. [fetched] https://www.arboxapp.com/pricing
- Other languages: UNKNOWN.

**Pricing tiers.** [fetched] https://www.arboxapp.com/pricing (this is a summarizer's read of the page; verify numbers on the page before publishing anything)

| Plan | Annual billing | Monthly billing | Weekly sessions | Service types | Products | Reports |
|---|---|---|---|---|---|---|
| Free | $0 | $0 | 5 | 3 | 3 | Basic |
| Basic | $39/mo | $49/mo | 20 | 10 | 20 | Basic |
| Standard | $99/mo | $129/mo | Unlimited | Unlimited | Unlimited | Advanced |
| Professional | $239/mo | $299/mo | Unlimited | Unlimited | Unlimited | Advanced |
| Enterprise | Contact sales | Contact sales | Unlimited | Unlimited | Unlimited | UNKNOWN |

What each tier adds, per the same page:
- **Free:** scheduling (5 weekly sessions), client management, payments and invoicing, client app, online shop.
- **Basic:** adds 20 weekly sessions, online classes, support.
- **Standard:** adds unlimited sessions, data migration, in-person onboarding, auto actions, email communication, task and lead management, smart insights.
- **Professional:** adds branded app, spaces management, premium support.
- **Enterprise:** adds on-site implementation, custom development, VIP support.

The page's feature checkmarks for memberships, waitlists, Stripe, and the scheduling system were not readable in the summary, so **per-tier availability of those is UNKNOWN.** Also: the summarizer noted the Standard annual price is ~23% below monthly, not the 20% the page says. Seasonal promo codes are listed with unstated validity.

Secondary sources (lower trust) disagree on the free tier and on the price band: Software Advice reports $49–$299/mo across 4 plans [search] https://www.softwareadvice.com/gym-management/arbox-profile/. Use the Arbox page.

---

## 2. Feature inventory

Plan column: the tier named on the pricing page, or "any" if the feature is on the Free plan's list, or UNKNOWN.

### Scheduling and classes
- **What it does:** Class and appointment calendar, group sessions, workshops, courses, recurring sessions, team and personal calendars, attendance caps (prevents overbooking), embedded schedule on any site, Zoom hosting, booking and cancellation policies, auto reminders before appointments.
- **Plan:** Free includes scheduling, limited to 5 weekly sessions. Unlimited on Standard and up.
- **Sources:** [fetched] https://www.arboxapp.com/features-pages/scheduling-appointments ; [fetched] https://www.arboxapp.com/pricing
- **Help center collection:** 7 articles, including limiting group sign-ups by age and gender (https://help.arboxapp.com/he/articles/15554794-הגבלת-הרשמה-לשיעורים-קבוצתיים-לפי-גיל-ומגדר), session notes (https://help.arboxapp.com/he/articles/12086445-הוספת-הערות-למפגשים-ביומן), tracks (https://help.arboxapp.com/he/articles/15804161-ניהול-מסלולים), Google Calendar sync (https://help.arboxapp.com/he/articles/15106428-arbox-google-sync). [fetched] https://help.arboxapp.com/he/collections/8857409-לוח-הזמנים

### Waitlists
- **What it does:** Dynamic waitlists that notify clients when a spot opens. Attendance tracking.
- **Plan:** UNKNOWN per tier.
- **Source:** [fetched] https://www.arboxapp.com/features-pages/scheduling-appointments

### Bookings (client side)
- **What it does:** Clients book, change, and cancel classes, appointments, workshops, and events in the client app or through online links. Event sign-up.
- **Plan:** any (client app and online links are on Free).
- **Sources:** [fetched] https://www.arboxapp.com/features-pages/customer-app ; [fetched] https://www.arboxapp.com/features-pages/payment-processing

### Memberships, packages, and punch cards
- **What it does:** Trials, memberships, subscriptions, multi-entry tickets, discounts. Freeze a standing-order membership. Renew from the client app. Punch-card tracking is mentioned in the app listing.
- **Plan:** UNKNOWN per tier (page checkmarks not readable).
- **Sources:** [fetched] https://www.arboxapp.com/features-pages/scheduling-appointments ; [fetched] https://help.arboxapp.com/he/collections/10636074-חברויות-ומוצרים → https://help.arboxapp.com/he/articles/12743229-הקפאה-של-מנוי-מסוג-הוראת-קבע ; [search] App Store listing https://apps.apple.com/app/id1037717356

### Payments and billing
- **What it does:** In-app and in-store payments via Stripe. Stored card details for one-off and recurring charges. Recurring invoices and standing orders. Automatic reminders for due and upcoming payments. Real-time "client paid" alerts for staff. Refunds (via Stripe). Automatic discounts and tax. Auto-sent receipts and invoices. Financial reports. Staff salary payouts. Bulk price update for standing orders. Redirect to a custom link after payment.
- **Fees:** Stripe takes a country-dependent commission. Arbox states it takes no commission on client-app or link transactions.
- **Plan:** Free includes payments and invoicing.
- **Sources:** [fetched] https://www.arboxapp.com/features-pages/payment-processing ; [fetched] https://help.arboxapp.com/he/collections/10628208-פיננסים → https://help.arboxapp.com/he/articles/10290056-עדכון-מחירים-גורף-עבור-הוראות-קבע and https://help.arboxapp.com/he/articles/15082626-הפניה-לקישור-מותאם-אישית-לאחר-תשלום
- **Not on the page:** punch-card payment rules, failed-payment retries (failed transactions appear only as an API report, see §3), POS hardware, terminal hardware.

### Cash, checks, and expenses (add-ons)
- **What it does:** Add-ons for managing cash and check deposits, and for managing expenses. Inventory add-on.
- **Plan:** These are named as add-ons ("תוסף"). Whether they cost extra is UNKNOWN.
- **Sources:** [fetched] https://help.arboxapp.com/he/articles/15253772-תוסף-לניהול-הפקדות-מזומן-ושיקים ; https://help.arboxapp.com/he/articles/15254135-תוסף-לניהול-הוצאות ; https://help.arboxapp.com/he/articles/15694021-תוסף-ניהול-מלאי

### Accounting export
- **What it does:** Set up accounting and export to Hashavshevet. Allocation-number change. Umbrella organizations.
- **Plan:** UNKNOWN.
- **Sources:** [fetched] https://help.arboxapp.com/he/articles/16131156-הגדרת-הנהלת-חשבונות-וייצוא-לחשבשבת ; https://help.arboxapp.com/he/articles/16451528-ארגונים-מאגדים ; https://help.arboxapp.com/he/articles/15265492-מספר-הקצאה-מה-השתנה-ומה-יש-לעשות

### Payroll and staff
- **What it does:** New payroll report for staff pay. Staff management with role-based access and permissions. Team payouts.
- **Plan:** UNKNOWN.
- **Sources:** [fetched] https://www.arboxapp.com/features-pages/payment-processing ; [fetched] https://help.arboxapp.com/he/articles/15516336-איך-לחסוך-שעות-בחישוב-שכר-לצוות-עם-דוח-השכר-החדש ; [fetched] https://arboxapp.com (staff management mention)

### CRM and leads
- **What it does:** Central lead and client records. Multiple sales pipelines with automatic lead assignment. Lead capture forms that save into the CRM. Lead intake from Facebook and Instagram ads and Google Ads. Smart contact lists. Automated sales funnels. Lead filters and live insights. Lost and converted tracking.
- **Plan:** Task and lead management on Standard. Others UNKNOWN.
- **Sources:** [fetched] https://www.arboxapp.com/features-pages/marketing-sales ; [fetched] https://www.arboxapp.com/pricing ; the CRM page https://www.arboxapp.com/features-pages/fitness-crm was **not fetched** (listed on the home page only)

### Marketing and campaigns
- **What it does:** Email campaigns. SMS and push notifications. Marketing automation. Marketing reports tied to revenue. Loyalty programs. Coupons and discounts. Gift cards. Upsell and renewal campaigns.
- **Plan:** Email communication on Standard. Others UNKNOWN.
- **Source:** [fetched] https://www.arboxapp.com/features-pages/marketing-sales

### Automations and messaging
- **What it does:** Automated workflows that send scheduled or event-triggered messages. Automated client onboarding. Automated reminders and follow-ups. Birthday messages. Automated subscription renewals. Booking reminders by SMS and email. Automated WhatsApp messages for personal appointments in the calendar.
- **Channels:** SMS, email, push (app), WhatsApp. The marketing page does not mention WhatsApp, but a help article does: "How to build automatic WhatsApp messages for personal calendar appointments." [fetched] https://help.arboxapp.com/he/articles/15493834-איך-לבנות-הודעות-אוטומטיות-בוואטסאפ-לפגישות-אישיות-ביומן ; an integrated WhatsApp guide: https://help.arboxapp.com/he/articles/11196342-מדריך-חיבור-וואטסאפ-אינטגרלי-למערכת
- **Plan:** "Auto actions" and "email communication" on Standard. Others UNKNOWN.
- **Sources:** [fetched] https://www.arboxapp.com/features-pages/marketing-sales ; [fetched] https://www.arboxapp.com/pricing

### Member (client) app
- **What it does:** iOS and Android app. Book, change, and cancel. Pay in-app. Renew memberships. Buy shop products. Stored card details. Activity tracking and personal feed. Push notifications. In-app direct messaging. Share schedules and invite friends. Offers and greetings from the business.
- **Branding:** A branded app (under the business's name) is on the Professional plan, requested through support. [fetched] https://www.arboxapp.com/features-pages/customer-app
- **Access:** Only existing members can log in, using credentials issued on joining. Password reset is in the profile. Login with phone number is documented. [fetched] https://help.arboxapp.com/he/articles/11873321-התחברות-עם-טלפון-לאתר-ההרשמות
- **No web version of the member app** was described on the page.
- **Store listing:** The members app is published under "Arbox LTD," and gym-branded apps (FIRSTUDIO, Urban Studio, RCLUB) are built on it. Rating on the App Store is about 2.5/5 from 34 ratings [search] https://apps.apple.com/app/id1037717356. The App Store fetch returned 429, so this is from the search summary only. Google Play listing: 404 on fetch; UNKNOWN.

### Coach app
- **What it does:** UNKNOWN. Not found on any page checked. The app listing mentions that a coach or owner can connect a member, but no coach-specific app was identified.

### Online links and website widgets
- **What it does:** Shareable schedule and shop links for self-service booking and payment. Embedded schedule on any website. Registration site (login with phone).
- **Plan:** Free includes online links.
- **Sources:** [fetched] https://www.arboxapp.com/features-pages/scheduling-appointments ; [fetched] https://www.arboxapp.com/features-pages/payment-processing ; [fetched] https://help.arboxapp.com/he/collections/10636075-אפליקציית-לקוחות-ואתר-ההרשמות

### Digital forms, waivers, and policies
- **What it does:** Booking and cancellation policies stored with digital signing in the app. Custom forms. Injury records and notes (from the API map). 
- **Plan:** UNKNOWN.
- **Source:** [fetched] https://www.arboxapp.com/features-pages/scheduling-appointments ; [fetched] https://www.arboxapp.com/features-pages/marketing-sales (custom forms)

### Reports and analytics
- **What it does:** Attendance, popular services, payment status, financial reports, marketing-to-revenue reports, payroll report. 46 report types in the API (see the API map).
- **Plan:** Basic on Free and Basic, Advanced on Standard and up (per the pricing summary; verify).
- **Sources:** [fetched] https://www.arboxapp.com/pricing ; the reporting page https://www.arboxapp.com/features-pages/reporting-and-analytics was **not fetched** (listed on the home page only)

### Access control and check-in
- **What it does:** The home page lists "a network-based reader for member entry" and attendance check-in for group sessions and appointments. No details on hardware or how entry is authorized.
- **Plan:** UNKNOWN.
- **Source:** [fetched] https://arboxapp.com (listed, not expanded); check-in is referenced in [fetched] https://www.arboxapp.com/features-pages/scheduling-appointments (attendance management only).

### Store, products, and POS
- **What it does:** Online shop for products, merchandise, subscriptions, and bundles. In-store payments are referenced. No POS hardware is described.
- **Plan:** Products limit: 3 on Free, 20 on Basic, Unlimited on Standard and up.
- **Sources:** [fetched] https://www.arboxapp.com/features-pages/payment-processing ; [fetched] https://www.arboxapp.com/pricing

### Integrations
- **What it does:** Zapier-based integrations (listed as Zapier apps): QuickBooks Online, Square, WooCommerce, Amilia, Google Calendar, Schedule by Zapier, Facebook Pages and Lead Ads, Instagram Lead Ads, Google Ads, Mailchimp, ActiveCampaign, Typeform, Google Forms, Gravity Forms, Thryv, Wix, Trengo (support), Slack, SMS by Zapier, WATI (WhatsApp-related), Airtable, Google Sheets, Zoom, Webhooks by Zapier, Code by Zapier, and more ("Show more" is a placeholder).
- **Plan:** UNKNOWN.
- **Sources:** [fetched] https://www.arboxapp.com/features-pages/integrations ; [fetched] https://www.arboxapp.com/features-pages/integrations (API-key setup line: "You'll need your API key")

### AI features
- **Found:** None. No AI feature is named on any page checked, and no AI-related help article was in the category lists.
- **Source:** [fetched] https://arboxapp.com (absence), help-center categories [fetched] https://help.arboxapp.com.

### Partner program (for builders, not owners)
- Free to join. Tech partners, resellers, referral partners. Application, verification by email, then invitation. Apply/contact buttons link to placeholders.
- **Source:** [fetched] https://www.arboxapp.com/partnership-tech

---

## 3. Capability matrix

Maps each product feature to the API operations in `docs/research/arbox-api.md`. "UI only" means no operation in the spec covers it. Verify each row against live behavior before relying on it.

| Product feature | API coverage (operationId / path) | Notes |
|---|---|---|
| Read the class schedule | Get Schedule `GET /v3/schedule` | |
| Change a class (reassign staff) | Update Class Schedule `PATCH /v3/schedule` | Spec names this as a write, so guard it. |
| Services / categories | Get Services `GET /v3/schedule/boxCategories` | Title is misleading. Spec calls it "Services". |
| Schedule settings | Get Schedule Settings `GET /v3/schedule/boxScheduleSettings` | |
| Staff availability | Get Staff Availability `GET /v3/schedule/staffAvailability` | |
| Space availability (spaces) | Get Space Availability `GET /v3/schedule/spacesAvailability` | Ties to Pro "spaces management". |
| Waitlist | Get Waiting List Entries `GET /v3/schedule/entryFromWaitingList` | Read only. No "add to waitlist" operation found. Dynamic notification is UI only. |
| Book a member into a class | Book Session `POST /v3/schedule/bookSession` | |
| Cancel a booking | Cancel session `POST /v3/schedule/cancelUserBooking` | Has a late-cancellation flag. |
| Trial classes | Book Trial Class / Get Trial Class Bookings / Cancel Trial Booking `POST` / `GET` / `DELETE /v3/schedule/booking/trial` | DELETE has a `force` flag. |
| Members list, search, profile | Get All Users, Search user, Get user by id `GET /v3/users`, `/searchUser`, `/{userId}` | |
| Create or edit a member | Create New User `POST /v3/users`; Update user `PATCH /v3/users` | |
| Delete a member | Delete user `DELETE /v3/users/{type}/{userId}` | `type` values unknown. |
| Member notes | Create user note / Get general notes `POST`/`GET /v3/users/createNote`, `/notes` | |
| Injury record | Create or update injury `PATCH /v3/users/injury` | |
| Profile photo | Change user profile image `POST /v3/users/profileImage` | |
| Group / merge members | Group users `POST /v3/users/group` | Destructive. |
| Membership list | Get User Memberships `GET /v3/users/memberships` | |
| Create membership | Create User Membership `POST /v3/users/memberships` | Spec says `sessions_left` and `price` are settable. Punch-card support is INFERRED from that field. |
| Update membership | Update user membership `POST /v3/users/memberships/update` | |
| Cancel membership | Cancel user membership `POST /v3/users/memberships/cancel` | |
| Freeze / hold membership | Suspend user membership `POST /v3/users/memberships/hold` | Hold reasons: `GET /v3/membershipHoldReasons`. |
| Cancel reasons | `GET /v3/membershipCancelReasons` | |
| Membership types / plans | Get All Membership Types `GET /v3/membershipTypes` | |
| Membership QR | Create Membership QR `POST /v3/users/memberships/qr` | |
| Commitment document | Attach commitment document `POST /v3/users/memberships/document` | |
| Recurring payments (standing orders) | Get user recurring payments / Edit user recurring payment `GET`/`POST /v3/users/recurringPayments` | Edits `amount` and `status`. Money write. |
| Invoices, receipts, quotes | Create Document `POST /v3/finance/documents` | Can email them. Money write. |
| Finance reports | Invoices / Receipts / Cash Flow / Sales / Failed Transactions `GET /v3/finance/reports/*` | 31-day cap on four of them. |
| Staff salary | Get Staff Salary `GET /v3/users/staffSalary` | |
| Payroll report | Via the Reports endpoint (`GET /v3/reports/{reportName}`) | Report name not verified. |
| Stripe checkout, card storage, refunds | UI only, no API | Refunds are "via Stripe integration" per the page. |
| Discounts, coupons, gift cards, loyalty | UI only, no API | |
| Lead records, list, create | Get All Leads / Create New Lead `GET`/`POST /v3/leads` | Create needs `location_id`. |
| Lead status, mark lost, notes | Update Lead Status / Mark Lead as Lost / Add Note `POST /v3/leads/updateStatus`, `/markAsLost`, `/createNote` | |
| Converted and lost leads | `GET /v3/leads/converted`, `GET /v3/leads/lost` | |
| Lead lookups (statuses, sources, lost reasons) | `GET /v3/statuses`, `/v3/sources`, `/v3/lostReasons` | |
| Sales pipelines, automatic assignment, funnels | UI only, no API | |
| Lead capture forms, website lead intake | UI only (no form-submission endpoint in spec) | |
| Ad lead intake (Facebook / Google) | UI or Zapier | Not in the API. |
| Custom fields | Get Custom Fields `GET /v3/customFields` | Read only. |
| Message templates | Get Message Templates `GET /v3/messageTemplates` | |
| Send a message to a member | Send Message to User `POST /v3/message` | Spec says `push` or `whatsapp` only. **SMS and email sending via API not in the spec.** WhatsApp needs a Meta integration. |
| Automated workflows and triggers | UI only, no API | |
| Email campaigns, SMS campaigns | UI only, no API | |
| Booking and renewal reminders | UI only, no API | Automatic. |
| Tasks | Get All Tasks, Create New Task, Get Task Types, Mark Task as Completed `GET`/`POST /v3/tasks`, `/types`, `/markAsCompleted/{task_id}` | `location_id` required on create. |
| Digital forms and waivers | Get Digital Forms `GET /v3/digitalForms`; Create Digital Form Link `POST /v3/digitalForms/createLink`; waivers `GET /v3/users/waiver/{type}/{value}` | Waiver `type` is ambiguous in spec. |
| Reports (46 types) | Get Reports `GET /v3/reports/{reportName}` | Response is an unlabelled union. |
| Locations / branches | Get All Locations `GET /v3/locations` | Per-branch key handling (D5) is not verified. |
| Member app login, branding, push | UI only, no API | |
| Coach app | UI only, no API. Not identified in product. | UNKNOWN |
| Online booking links, embedded schedule | UI only, no API | |
| Access control and check-in | UI only, no API (no check-in endpoint in spec) | Boost.space template lists an "entrance" trigger; not verified. |
| Accounting export (Hashavshevet) | UI only, no API | |
| Integrations (Zapier) | Via the public API key (Zapier apps are built on it, INFERRED). | |
| Expense, cash-deposit, inventory add-ons | UI only, no API | |
| AI features | None found | |

**Read vs write for skills.** The API covers most reads (37 GETs) and creates/edits on users, memberships, bookings, leads, tasks, and messages. Money writes (membership price, recurring payments, invoices), messaging, and destructive writes are listed in arbox-api.md "Writes that change money, messaging, or access." Skills must gate those.

**Biggest gaps for owners:** automations, campaigns, payments (checkout, refunds), pipelines, check-in, POS, member app, and branding are all UI only.

---

## 4. Owner pain points and jobs

### Jobs owners do (from Arbox's own pages and help center)
1. Fill classes: scheduling, waitlists, reminders, booking rules. [fetched] https://www.arboxapp.com/features-pages/scheduling-appointments
2. Collect money: recurring memberships, standing orders, invoices, reminders for overdue payments. [fetched] https://www.arboxapp.com/features-pages/payment-processing
3. Acquire and convert leads: ad intake, pipelines, auto assignment. [fetched] https://www.arboxapp.com/features-pages/marketing-sales
4. Keep members engaged: automated onboarding, birthday messages, loyalty, cancellation reduction. [fetched] https://www.arboxapp.com/features-pages/marketing-sales
5. Run the books: accounting export, payroll, expenses, cash and check deposits. [fetched] https://help.arboxapp.com/he/collections/10628208-פיננסים
6. See the business: reports and analytics. [fetched] https://www.arboxapp.com/pricing (report tiers)
7. Serve clinics and therapists: personal appointments and treatment documentation. [fetched] https://help.arboxapp.com/he/collections/8857409-לוח-הזמנים

### What owners praise (Capterra, 25 unique reviews, mostly 2019–2021; reviewers mostly owners and managers)
- Responsive support: ~15 reviews. Quote (owner, CrossFit affiliate, Nov 2020): "the customer service was, hands down, the best I've seen!" [fetched] https://www.capterra.com/p/184438/Arbox/reviews/
- Easy to use: ~12 reviews. Quote (owner, Dec 2019): "Most user friendly software i have seen." [same]
- All-in-one: ~8 reviews. Quote (chairman, Mar 2023): "The Arbox platform is a one stop shop to manage our business." [same]
- Product keeps evolving: ~7 reviews. [same]
- Reporting: ~6 reviews. Quote (manager, Jul 2020): "there are reports that can be produced at any time." [same]
- Anywhere and anytime access: ~4 reviews. [same]
- Overall rating: 4.7 from 42 on Capterra [search] https://www.capterra.com/p/184438/Arbox/reviews/

### What owners complain about (same source, same caveats)
- **Weak admin tools and BI depth:** ~5 reviews. Quote (owner, Feb 2021): "It lacks tools and easiness for admin." [fetched]
- **Payments and card handling:** ~4 reviews. Quote (manager, Apr 2021): "No integrated card swiper so you have to manually enter Credit Card payments every time." [fetched]
- **Bugs and reliability:** ~3 reviews, including a recent one. Quote (CEO, Dec 2025, 1-star): "there are constant errors both when I register someone manually." [fetched]
- **Not built for non-gym businesses:** ~4 reviews. Quote (Pilates studio owner, Dec 2019): "Developed and built mainly for Gyms and less for Pilates Studios." [fetched] — **directly relevant to the yoga/Pilates segment.**
- **Slow support (a minority):** ~3 reviews, including Dec 2025. [fetched]
- **Price:** mixed, ~2 reviews. Quote (retail associate, Jul 2021): "The price is what I least like." Others chose Arbox for price. [fetched]
- **Dated app:** ~2 reviews. Quote (FitHub owner, Sep 2019): "The app is a bit old fashioned." [fetched]

### Third-party summaries (lower trust)
- Owners report login failures and loading screens in the member app and friction when cancelling. [search] https://marlvel.ai/apps/arbox/vs (aggregator, method unclear).
- Training is confusing and hard to reach. [search] GetApp reviews https://www.getapp.com/recreation-wellness-software/a/arbox/reviews/220af126f9/
- Owners want easier payment-method switching and owner tools. [search] https://www.softwareadvice.com/salon/arbox-profile/reviews/

### Wishes (inferred from complaints, not stated by owners as wishes)
- INFERRED: a better owner dashboard, an integrated card terminal, and fitness-agnostic setup for studios.

### Owner community
- Not searched in this pass. UNKNOWN.

---

## 5. Getting an API key

**Short answer: the key is in the Arbox admin, under Settings. The plan that unlocks it is UNKNOWN.**

- **Where:** The help-center API article says the business API key is "supplied inside the Arbox platform," copied from Settings under Business Information. It also says a second identifier, `location_box_fk`, must be requested from support. [search] https://help.arboxapp.com/he/articles/9013934-api-documentation-arbox. **Both fetch attempts (Hebrew and English URLs) returned 404.** The menu path and the `location_box_fk` detail are therefore from the search summary only, not from the page.
- **Who sees it:** UNKNOWN. The article does not say. Presumably the account owner or admin, but this is INFERRED.
- **Which plan:** UNKNOWN. The integrations page says "You'll need your API key" and "Get your Arbox API access key" with no steps and no plan named [fetched] https://www.arboxapp.com/features-pages/integrations. The pricing page does not mention API access in any tier [fetched] https://www.arboxapp.com/pricing. The Enterprise tier mentions "API access" only in a competitor's summary [search] https://exercise.com/grow/how-much-does-arbox-cost. A third-party review site says API availability varies by vendor and tier and recommends confirming with Arbox [search] https://www.itqlick.com/arbox/integrations (secondary).
- **Who can ask for API access:** the partner program is free to join, aimed at tech partners, resellers, and referral partners. The page does not describe API-key issuance [fetched] https://www.arboxapp.com/partnership-tech.
- **Other keys:** the API map notes the spec wants `api-key` as the header. The spec does not describe key issuance either (see arbox-api.md, Open questions 1).
- **Multi-location:** the search summary says a business key is issued per business and a `location_box_fk` identifier is requested from support. Whether each branch gets its own key (decision D5 in `.team/decisions.md`) is NOT confirmed by any source read.

**Implication for onboarding (the least-sure item):** We cannot yet say "go get your key" for every customer. Until the plan gate is known, onboarding should say: "Ask your Arbox contact for API access, or check Settings → Business Information."

---

## Unknowns (explicit)

1. Customer counts, box sizes, and revenue bands. UNKNOWN.
2. Whether the home market is Israel. INFERRED from the Hebrew help center and Israeli-specific accounting and invoicing titles. Not stated by Arbox.
3. Per-tier availability of memberships, waitlists, Stripe, CRM pipelines, and automations. UNKNOWN (pricing page checkmarks not readable).
4. API key plan gate, key issuer, and who can see it. UNKNOWN. Menu path from search summary only.
5. The API article's full text. Page returned 404 on both languages.
6. Coach app. UNKNOWN.
7. Check-in and access-control hardware and API. UNKNOWN.
8. Whether SMS and email can be sent via `POST /v3/message`. UNKNOWN from spec. Spec says push and WhatsApp only.
9. Google Play listing and the member app's current rating. UNKNOWN (404; App Store fetch 429).
10. Pages not fetched: operations, reporting-and-analytics, fitness-crm, website, and all vertical pages. Only their names are known from the home page and search.
11. Owner communities (Facebook groups, forums). UNKNOWN.
12. Whether add-ons (cash, expenses, inventory) cost extra. UNKNOWN.
13. Languages supported in the member app and admin UI beyond Hebrew and English. UNKNOWN.

## Fetch log

About 25 fetches (stop rule ~30). Main pages: arboxapp.com home and pricing, scheduling, payments, marketing, customer app, integrations, partnership-tech. Help center root and collections (schedule, finance, memberships, customer app, advanced tools). Capterra reviews. Multiple 404s/429s noted above.
