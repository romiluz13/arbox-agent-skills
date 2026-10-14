# Arbox for owners: product knowledge

What Arbox is, what each plan includes, what Claude can reach through the connection versus what stays in the Arbox app, and the native features worth using first. Written from Arbox's public pages on 2026-10-14. Marketing pages change; verify a number or plan gate on the source before promising it. Items marked UNKNOWN are not confirmed anywhere we could read.

## Contents

- [What Arbox is](#what-arbox-is)
- [Plans](#plans)
- [Operating models](#operating-models)
- [What Claude can reach and what is app-only](#what-claude-can-reach-and-what-is-app-only)
- [Native features worth using first](#native-features-worth-using-first)
- [Where to find things in the app](#where-to-find-things-in-the-app)
- [Honest limits](#honest-limits)
- [Sources](#sources)

## What Arbox is

An all-in-one management system for classes and appointments: schedule, bookings, memberships and packs, payments and invoices, leads and tasks, reports, a member app and a booking website link. Customers are fitness studios and gyms, and also clinics and therapists, salons, tutors and activity venues. Hebrew is the main language of the help center (Israel is the likely home market, inferred); the English help center is empty, and English lessons live in the Academy.

Arbox's vertical pages (yoga, Pilates, CrossFit, gym, dance, beauty and more) share one template. Do not assume a feature exists "for Pilates" because a page says so; check the feature.

## Plans

From the pricing page. Prices in USD, annual billing; check the page before quoting.

| Plan | Price | Adds |
|---|---|---|
| Free | $0 | Scheduling limited to 5 weekly sessions, client management, payments and invoicing, client app, online shop, online links. Basic reports |
| Basic | $39 /mo | 20 weekly sessions, online classes, support. Basic reports |
| Standard | $99 /mo | Unlimited sessions, data migration, in-person onboarding, **auto actions**, email communication, **task and lead management**, **smart insights**. Advanced reports |
| Professional | $239 /mo | Branded app, **spaces management**, premium support |
| Enterprise | contact sales | On-site implementation, custom development, VIP support |

UNKNOWN: which plan includes API access (the pricing page does not say; ask Arbox or check at connect time), plan gates for waitlists, memberships, Stripe, SMS, and whether add-ons (cash and check deposits, expenses, inventory) cost extra. The pricing page says invoicing may require an additional fee even though Free lists payments and invoicing.

"Smart insights" is a reporting feature; do not call it AI. The help center (WhatsApp article, March 2026) announces an AI agent for scheduling and replies inside the smart inbox as "coming soon"; treat it as not available unless the owner says they have it.

## Operating models

Branch the conversation on what the owner sells, not on the label of the business.

1. **Group classes and memberships**: sessions with capacity, waitlist, memberships, session punch cards, check-in, penalties.
2. **One-on-one appointments**: availability, reminders, staff commission and payouts, treatment documentation (PDF export), health forms, Zoom sessions.
3. **Courses and workshops**: recurring events over a period, registration closing time, age and gender limits, waivers.
4. **Spaces and venues**: space availability (spaces management is Professional), group bookings, payment schedules.

## What Claude can reach and what is app-only

The connection is the Arbox public API: about 65 operations, mostly reading. Full list: https://arboxserver.arboxapp.com/docs/api

**Claude can read:** schedule and capacity, waiting-list entries, members and their memberships, leads (statuses, sources, lost reasons, converted, lost), tasks, trial bookings, digital forms and waiver status, locations, message templates, finance reports (invoices, receipts, cash flow, sales, failed transactions), and 47 named reports (members, expiring, absence, debts, bookings, sales, leads, forms and more).

**Claude can do only with the owner's yes (small, reversible):** create a task, add a note to a lead, change a lead status, create a lead, create a form link.

**Messages:** the API can send a push or WhatsApp message, but the guide treats all messages as drafts the owner sends. SMS and email sending through the API is not documented.

**Stays in the Arbox app (Claude does not do it):** payments, refunds, membership price or status changes, cancelling or freezing memberships, merging or deleting members, standing-order changes, creating invoices, schedule changes.

**App only, no API at all:** automations and auto actions, email and SMS campaigns, booking and renewal reminders, pipelines and funnels, lead capture forms, Stripe checkout and card storage, discounts, coupons and gift cards, member app and branding, check-in and entrance, the online booking link, accounting export, add-ons. Claude can only explain these and help write the content; the owner sets them up in Arbox.

## Native features worth using first

| Feature | What it does | Plan | Source |
|---|---|---|---|
| Auto actions | Event or time triggered messages: reminders, birthdays, onboarding, renewals, follow-ups | Standard+ | https://www.arboxapp.com/features-pages/managing-your-everyday (reminders, follow-ups); birthdays, onboarding and renewals from the marketing "Automations and messaging" section, not verified on the page |
| Smart insights, advanced reports, dashboard | Real-time overview, profit breakdown, earnings goals, membership forecast, lead statistics | Standard+ | https://www.arboxapp.com/features-pages/reporting-and-analytics |
| Reports lesson | Essentials, Growth, Retention groups; message members from a report; download as Excel | see plans | https://academy.arboxapp.com/quick-help-articles/reports |
| Penalties | After N absences in a time window: block and cancel, block, or shorten the membership; notice by push, SMS or email | UNKNOWN | https://academy.arboxapp.com/lesson/penalties |
| Failed transactions | Declined recurring charge creates a debt; message the member to update their card and pay | UNKNOWN | https://academy.arboxapp.com/lesson/recurring-plan |
| Membership types and punch cards | Settings > Membership types; Settings > Session Punch Cards | UNKNOWN | https://academy.arboxapp.com/lesson/membership-types |
| Check-in web app | Staff and coaches mark attendance; flags for new, birthday, debt, injury; entrance tablet option | UNKNOWN | https://academy.arboxapp.com/lesson/check-in-interface |
| Zapier | Triggers (new lead, new client, renewal, waitlist enrolment, cancellation, purchase, form signed) and actions (create lead, create task, send message, search client, get schedule) | UNKNOWN | https://academy.arboxapp.com/lesson/zapier-arbox-integration |
| Schedule link, embedded schedule, lead form, shop link | A booking page for any site, no code | Free | https://www.arboxapp.com/features-pages/website |
| WhatsApp | Integrated WhatsApp, connected by QR code, for a fixed monthly fee. Automatic messages via auto actions (trial booking, declined card, membership cancellation, birthday, new lead, waitlist entry). Manual messages from the calendar (participant management) with name fields. A smart inbox shows chats beside the member's debts, plans and tasks | Fee: fixed monthly (amount not stated); plan UNKNOWN | https://help.arboxapp.com/he/articles/11196342-מדריך-חיבור-וואטסאפ-אינטגרלי-למערכת |
| Clinics and therapists | Personal appointments, treatment documentation PDF | UNKNOWN | https://help.arboxapp.com/he/articles/12309679-ניהול-פגישות-אישיות-לקליניקות-ומטפלים |
| Payroll report | Hours and pay for staff | UNKNOWN | https://help.arboxapp.com/he/articles/15516336-איך-לחסוך-שעות-בחישוב-שכר-לצוות-עם-דוח-השכר-החדש |
| Accounting export (Israel) | Hashavshevet export, allocation number | UNKNOWN | https://help.arboxapp.com/he/articles/16131156-הגדרת-הנהלת-חשבונות-וייצוא-לחשבשבת |

## Where to find things in the app

Menu labels come from the Academy and may differ slightly by version.

- API key / Zapier key: Settings > Club Information (an older label is Business Information). `arbox-api` handles the key; the guide never asks for it.
- Membership plans: Settings > Membership types > Add New Membership Plan.
- Session punch cards: Settings > Session Punch Cards > Add New Session Punch Card.
- Penalties: Settings > Business Settings > Penalties.
- Recurring payment options: Settings > Finance > Recurring Payment.
- Failed transactions: Transactions > Failed Transactions.
- Reports: Reports, with Favorites; download as Excel.
- Check-in: separate web app for staff and coaches (checkin.manage.arboxapp.com/login-check-in; a second domain checkin.arboxapp.com appears in a search summary, UNKNOWN which is current).

## Honest limits

- Reports are snapshots of what Arbox returns, not live screens.
- The connection reaches only what the API exposes. Anything seen in the app but absent above is out of reach.
- Customer counts and totals on Arbox's marketing pages have no date or method; do not quote them.
- No separate coach app was found; coaches use the check-in web app.

## Sources

- Site and plans: https://www.arboxapp.com , https://www.arboxapp.com/pricing
- Features: https://www.arboxapp.com/features-pages/scheduling-appointments , https://www.arboxapp.com/features-pages/payment-processing , https://www.arboxapp.com/features-pages/marketing-sales , https://www.arboxapp.com/features-pages/customer-app , https://www.arboxapp.com/features-pages/fitness-crm , https://www.arboxapp.com/features-pages/integrations
- Verticals: https://www.arboxapp.com/verticals/fitness , https://www.arboxapp.com/verticals/wellness , https://www.arboxapp.com/verticals/beauty , https://www.arboxapp.com/verticals/education , https://www.arboxapp.com/verticals/activities
- Help center (Hebrew): https://help.arboxapp.com/he
- Academy: https://academy.arboxapp.com
- API docs: https://arboxserver.arboxapp.com/docs/api and spec https://arboxserver.arboxapp.com/docs/api.json
