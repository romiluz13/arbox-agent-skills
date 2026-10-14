# Owner journey and skill set (design proposal, T2)

Owner: Matt | Route: Plan | Phase: resolve design decisions | Author: Sonnet | 2026-10-14
Status: proposal for lead review. No skill or code files exist yet.

Labels used below:
- **ASSUMED**: a product or user-behavior claim with no source yet. `docs/research/arbox-product.md` (T1) did not exist when this was written. Reconcile when it lands.
- **LIVE CHECK**: a fact about a machine, harness or the live API that must be tested before we depend on it.
- `spec:` means `docs/research/arbox-openapi.json`. `api:` means `docs/research/arbox-api.md`. `rt:` means `docs/research/red-team.md`.

## 0. Design in one paragraph

An owner who has never opened a terminal types a vague question. A **guide** skill answers in plain language, interviews them in short rounds (using Matt's grilling shape: numbered questions, each with a recommended answer so "yes" accepts), and proposes three ideas tailored to what they said. **Only after they pick one** does it ask for an API key, because asking for a credential before showing value is the biggest trust barrier. A single **api** skill owns setup, safety and execution, and a **recipes** skill owns how each idea is built. The default output is a local HTML report plus a saved "routine" the owner reruns with one sentence. The executor is a small `sh` + `curl` wrapper split into `read` and `write` commands, so the harness's own permission prompt is the write gate, not a model-typed flag (builds on the lead's response in `rt:` bottom section).

Two reorderings versus the brief's step list, both deliberate:
1. **Interview before connect, fact-check after connect.** Ask only what the owner alone knows (goals, pains, boundaries) before any key exists. After connecting, the agent looks up facts itself (member count, locations, classes) and confirms them. This follows grilling's rule: finding facts is the agent's job.
2. **Setup is a gate inside the api skill, not its own skill** (justified in section 4).

---

## 1. The journey, step by step

Flagship first message: *"Hey, how can I use Arbox and Claude Code? What can I build?"*

| # | Step | What the agent does | Skill | Exit evidence |
|---|---|---|---|---|
| 1 | First message | Matches the guide skill from description text ("Arbox", "gym/studio owner", "what can I build"). | arbox-guide | Skill body loaded |
| 2 | Detect context | Silent checks, no questions. Does `~/Arbox/business-profile.md` exist? Does `~/.arbox/profiles` exist (**test with `-f` only, never read it**)? Which OS? Is `curl` present? Output feeds the branch below. | arbox-guide | Branch chosen: *new owner* / *returning owner* / *connected, no profile* |
| 3 | Explain what's possible | 6 to 8 lines, zero jargon: Claude can read your Arbox (members, classes, leads, payments), turn it into answers, lists and reports, draft messages for you to approve, and do a few small updates with your OK. Honest limits: it works from what Arbox exposes, reports are snapshots not live screens, and nothing is sent or changed without a yes. | arbox-guide | Owner replies / asks a follow-up |
| 4 | Round 1 interview: the business | 3 to 4 questions: business type, rough size, locations, how they use Arbox today. Each question carries a recommended answer inferred from the first message. | arbox-guide | Answers recorded in profile draft |
| 5 | Round 2 interview: goals and pains | Branches by business type (section 3). Owner picks their top 2 pains from a short menu, plus free text. | arbox-guide | Top pains ranked |
| 6 | Round 3 interview: boundaries | Look-only vs "do things for me", messages (draft or send), who sees reports, data they don't want Claude to see, tools they already use (Excel, Sheets, WhatsApp). | arbox-guide | Boundaries recorded |
| 7 | Propose 3 ideas | Pick 3 from the catalog (section 2) that match pains and boundaries: one quick win (answer in 2 minutes, read-only), one weekly-value idea, one stretch. Each in owner language with "what you'd see Monday morning". | arbox-guide | Owner picks one (or asks for others) |
| 8 | Setup gate | Hands off to **arbox-api**. Walks the owner through getting the key from Arbox (**ASSUMED path, see Q4**), saving it without pasting it into chat, testing the connection, and choosing safety defaults. | arbox-api | `arbox doctor` passes; `GET /v3/locations` returns the studio's name |
| 9 | Fact-check | The agent now looks up real facts and confirms them: "I see 1 location, 212 active members, 38 classes this week. Right?" Corrects the profile. Re-ranks ideas if reality contradicts them (e.g., waiting lists are empty, so skip the class-fill idea). | arbox-guide + arbox-api | Profile updated with looked-up facts |
| 10 | Build | Hands off to **arbox-recipes**. Runs the picked idea's recipe: fetch via `arbox read`, compute, write an HTML report and/or CSV into `~/Arbox/reports/`, open it in the browser. | arbox-recipes (+ api) | File exists; first rows spot-checked against a number the owner knows |
| 11 | Run and verify | Owner looks at it. Agent asks one question: "Does this match what you know about your studio?" A mismatch means the recipe is wrong, not the owner. | arbox-recipes | Owner confirms or agent fixes |
| 12 | Save as routine | Offers to save it as `~/Arbox/routines/<name>.md` so next time the owner says "run my weekly digest". | arbox-recipes | Routine file exists |
| 13 | Next ideas | Offers the 2 other proposed ideas plus 1 or 2 that this build unlocked (e.g., churn list unlocks "draft check-in messages"). Updates `business-profile.md` with what was built. | arbox-guide | Profile lists built ideas |

**Returning owner branch** (profile and key exist): skip steps 3 to 8. Greet by profile ("Last time we built your weekly digest"), ask "run it again, tweak it, or try something new?", then jump to 7 or 10.

**Connected but no profile** (e.g., a developer, or an owner who set up the key elsewhere): offer a 2-minute version of rounds 1 to 3, skippable.

**Failure branches** the guide must handle in plain language: no key yet (explain where to ask Arbox or find it, do not stall the interview); key rejected (401-like error, see Live checks); `curl` missing (stop, explain, no workaround attempts); owner says "just do it" (offer the 3 default ideas by business type, still run the fact-check).

### Sample transcript: Pilates studio owner (condensed)

```
Owner:  Hey, how can I use Arbox and Claude Code? What can I build?
Claude: Great question. In plain terms: Claude can read the information in your Arbox
        (members, classes, leads, payments), turn it into answers, lists and reports,
        and draft messages for you to approve. It can also make a few small updates, but
        only after you say yes. Nothing is sent or changed on its own.
        A few quick questions so I suggest things that fit YOU, not a generic list.

        Q1 - Type of studio: It sounds like a Pilates studio. Is that right?
        -> Yes, Pilates (reformer and/or mat).
        Q2 - Size: About how many active members, and how many locations?
        -> Roughly 150 members, 1 location.
        Q3 - Arbox today: Are you mostly using it for bookings and memberships, plus
           leads and payments?
        -> Yes, bookings and memberships; leads are tracked loosely.
Owner:  Yes Pilates. ~180 members, one studio. We mostly use it for bookings and packs.
Claude: Thanks. Round 2, what actually hurts?
        Q4 - Top pains (pick two): (a) classes half empty or always full with a waiting
           list, (b) members drifting away and I only notice when they're gone, (c) packs
           expiring and nobody renews, (d) chasing payments, (e) new leads/trials not
           followed up, (f) something else.
        -> I'd guess (b) and (c).
Owner:  b and c. I only find out someone left when they stop showing up for a month.
Claude: Q5 - Boundaries: Should I only look and report, or may I also draft messages for
           you to review and send yourself?
        -> Draft messages for me to review. I send them myself.
Owner:  Drafts, yes. I send them myself.
Claude: Got it. Three ideas for you:
        1. "Who's drifting" list (quick win, look-only): members who used to come weekly
           and haven't booked in 3+ weeks, with their pack and last visit.
        2. Pack-expiry watch (weekly): packs ending or running out in 14 days, with a
           friendly renewal message drafted per person for you to approve.
        3. Class-fill view (stretch): which times are empty vs. always full.
        Which one first? I'd start with #1; you could have it in about 10 minutes.
Owner:  #1 please.
Claude: To read your Arbox, I need a key from your Arbox account. I will NOT ask you to
        paste it here. I'll open a small file for you to paste it into and save.
        [creates a private file, opens it in a text editor]
Owner:  Done, saved.
Claude: [runs connection test] Connected: "Studio Flow", 1 location. I can see 183 active
        members and 41 classes this week. Does that match?
Owner:  183, yes!
Claude: [fetches absence data, builds ~/Arbox/reports/drifting-members.html, opens it]
        Here are 27 members who usually come weekly but haven't booked in 21+ days. Does
        Dana K. on top look right to you? Want me to save this as "my drifting list" so
        you can say "run my drifting list" every Monday?
```

Notes on the transcript: the agent never says "API", "endpoint" or "key" before the owner needs the key; it states the recommended answer to each question; it spot-checks a named member; the report is described by what the owner sees.

---

## 2. Ideas catalog

Legend:
- **Risk**: R0 read-only. R1 reversible write to internal records (notes, tasks, lead status, create a lead). R2 member-facing or hard to undo (messages). R3 money, identity merges, deletes: **never in v1** (matches `rt:` 2.2.3 to 2.2.6).
- **Effort** (for a non-coder): *Chat* = answer in the conversation, nothing to run. *One report* = one HTML/CSV from one run. *Routine* = saved and rerun by a sentence. *Loop* = needs an approval loop each run.
- **Fits**: P Pilates, Y yoga, C CrossFit/functional, G gym, PT personal-training or boutique 1:1, K kids/"hugim" courses (**ASSUMED** that `hugim*Report` means activity/course series), M multi-location.
- Report names are values of the `reportName` path param of `GET /v3/reports/{reportName}` (46 values, `spec:/components/schemas/ReportName`). Response fields cited below come from the `*ReportResource` schemas. Which report returns which fields is typed in the spec but undocumented in prose (`api:` Odd things 8), so every recipe needs a live probe.
- **Cross-cutting rule for all message ideas**: report resources carry `allow_sms` / `allow_email` (e.g., `BirthdayReportResource`, `AbsenceReportResource`). Draft only for members who allow the channel.

| # | Idea (owner-language pitch) | Operations it needs | R/W, risk | Effort | Fits |
|---|---|---|---|---|---|
| 1 | **Who's drifting.** "Members who used to come and have gone quiet, so I can reach out before they cancel." | `GET /v3/reports/absenceReport` (fields `last_seen`, `future_registration`, `latest_registration`, `membership_name`, `debt`); `inactiveMembersReport`; `regularsReport` to find who *was* a regular; `GET /v3/users/searchUser` for lookups | Read, R0 | One report, then Routine | P Y C G PT |
| 2 | **Weekly studio digest.** "One page every Monday: how many came, who joined, who left, what I earned." | `GET /v3/schedule` (flags `registration_count`, `waiting_list_count`); `classesSummaryReport`; `bookingsReport`; `salesReport`; `canceledMembershipsReport`; `activeMembersReport` | Read, R0 | Routine | All |
| 3 | **Class-fill finder.** "Which times are empty and which are always full." | `GET /v3/schedule` (`max_participants`, `registration_count`, `waiting_list_count`); `classesSummaryReport` (`registration_percentage`, `check_in_percentage`); `bookingStatisticsReport` (**schema untyped in spec**, probe it) | Read, R0 | One report | P Y C K |
| 4 | **Waiting-list pressure.** "Where people are queuing, so I know what class to add." | `GET /v3/schedule/entryFromWaitingList` (params `confirm`, `from_date`, `to_date`); `GET /v3/schedule` `waiting_list_count` | Read, R0 | Chat or one report | P Y C |
| 5 | **Revenue snapshot.** "What I earned this month vs. last month, by what I sold." | `GET /v3/finance/reports/sales`, `cashFlow`, `invoices`, `receipts` (**31-day cap**, `api:` Pagination: loop month by month); `salesReport`; `revenueAnalysisReport` (schema untyped, probe) | Read, R0 | One report | All |
| 6 | **Payments to chase.** "Who owes me or whose card failed." | `GET /v3/reports/debtReport` (`debt`, `item_name`, `status`); `GET /v3/finance/reports/failedTransactions` (`amount`, `last_four_digits`) | Read, R0. Optional follow-up: create a task per person via `POST /v3/tasks` (R1) | One report | All |
| 7 | **Pack and membership expiry watch.** "Who's about to run out, with a friendly renewal message drafted for me." | `expiringSessionsReport`; `expiringMembershipsReport` (`end_date`, `has_another_plan`); `expiredMembershipsReport`; `renewalsReport`; `GET /v3/messageTemplates` for tone. Send path `POST /v3/message` is **not in v1** (see Q3) | Read R0 + drafts as a file; send is R2 | Loop (weekly) | P Y C G |
| 8 | **Birthday and milestone messages.** "Birthday wishes drafted for each member, ready for me to approve." | `GET /v3/reports/birthdayReport` (`birthday`, `age`, `allow_sms`, `allow_email`). Milestones (e.g., 100th visit) from `sessionsReport` or `bookingsReport` (**ASSUMED derivable, probe**) | Read, R0; send is R2 | Loop (daily or weekly) | All |
| 9 | **Lead follow-up assistant.** "Every new lead gets a call task so nobody falls through." | `GET /v3/leads`; `leadsInProcessReport`; `GET /v3/statuses`, `/v3/sources`; `POST /v3/tasks` (needs `location_id`, `task_type_id`, `reminder{date,time}`; `GET /v3/tasks/types`); `POST /v3/leads/createNote`; `POST /v3/leads/updateStatus` | Read + writes, R1 | Loop | P Y C G PT |
| 10 | **Trial-class tracker.** "Who tried a class, and who actually joined." | `GET /v3/schedule/booking/trial`; `trialClassesReport` (`status`, `days_passed`, `lost_reason_name`); `convertedLeadReport`; `GET /v3/leads/converted`, `/v3/leads/lost` | Read, R0 | One report, then Routine | All |
| 11 | **Where my customers come from.** "Which source or campaign brings people who actually sign up." | `GET /v3/sources`; `allLeadsReport`; `convertedLeadReport` (`lead_source`, `campaign`); `salesReport` (`lead_source`, `campaign_name`) | Read, R0 | One report | All |
| 12 | **Local dashboard.** "A page I can open any time that shows the whole studio on one screen." | Composition of ideas 1, 2, 3, 5 (their operations) | Read, R0 | One report, refreshed on rerun | All |
| 13 | **Late-cancel and no-show watch.** "Who keeps cancelling late or not turning up." | `lateCancellationReport`; `bookingCancellationReport`; `cancelledSessionsReport`; `absenceReport` | Read, R0 | One report | P Y PT |
| 14 | **Coach load and popularity.** "Which instructors fill their classes; who's overloaded." | `GET /v3/schedule` (`staff_member`, `registration_count`); `classesSummaryReport` (`staff_member`); `employeeAttendanceReport`; `GET /v3/users/allStaffMembers`. **Exclude** `GET /v3/users/staffSalary` and `salary` by default (privacy, see Q5) | Read, R0 | One report | All |
| 15 | **Schedule planner.** "Suggest which times to add or drop, based on real demand." | `GET /v3/schedule`; `staffAvailability`; `spacesAvailability`; `boxScheduleSettings`; `boxCategories`; `bookingStatisticsReport`. Output is a **proposal document only**; changes happen in Arbox (`PATCH /v3/schedule` is R3 in v1) | Read, R0 | One report | P Y C PT K |
| 16 | **Waiver and form chaser.** "Who hasn't signed their health declaration or waiver." | `GET /v3/digitalForms`; `signedFormsReport`; `GET /v3/users/waiver/{type}/{value}` (**duplicate path/query param, `api:` Odd things 3, probe**); optionally `POST /v3/digitalForms/createLink` (R1, creates a link, sends nothing by itself, **ASSUMED**) | Read, R0 (+R1 link) | One report | All, esp. P Y PT |
| 17 | **Why people leave.** "The reasons members cancel or freeze, and when it happens." | `canceledMembershipsReport` (its row shape is untyped here; `ExpiringMembershipsReportResource` carries `cancel_reason`, so probe); `GET /v3/membershipCancelReasons`, `/v3/membershipHoldReasons`; `membersOnHoldReport` | Read, R0 | One report | All |
| 18 | **Ask your studio anything.** "Type a question, get an answer: 'who's Dana's coach', 'how many on the 7am Tuesday'." | `GET /v3/users/searchUser`; `GET /v3/users/{userId}`; `GET /v3/users/memberships`; `GET /v3/schedule` | Read, R0 | Chat | All |
| 19 | **Daily front-desk briefing.** "Today's classes, who's booked, birthdays, expiring packs, open tasks." | `GET /v3/schedule` (today, `registration_details`); `birthdayReport`; `expiringSessionsReport`; `GET /v3/tasks` | Read, R0 | Routine (daily) | P Y C PT |
| 20 | **Data tidy-up list.** "Members missing a phone or email, or who blocked messages, so my records are clean." | `GET /v3/users` (`allow_sms`, `allow_email`, `email`, `phone`); `membersPropertiesReport`; `GET /v3/customFields`. Fixing records (`PATCH /v3/users`) is R3-adjacent, **report only in v1** | Read, R0 | One report | All |
| 21 | **Compare my branches.** "Both studios side by side." | `GET /v3/locations`; ideas 2 and 5 run once per named key profile (`api:` Conventions, D5) | Read, R0 | Routine | M |
| 22 | **Membership mix.** "Which memberships and packs sell, and which I could retire." | `GET /v3/membershipTypes`; `activeMembershipsReport`; `salesReport` | Read, R0 | One report | All |

Counts: 22 ideas. Read-only throughout: 19 (1-5, 7, 8, 10-15, 17-22). Optional or core R1 writes: 6 (task per person), 9 (tasks, notes, status), 16 (form link). Message drafts whose send would be R2: 7, 8, and optionally 1. Every operation above exists in `api:` Endpoints by group.

**Why the weight is read-heavy:** the audience is non-technical and the spec has no sandbox semantics (`rt:` 2.2.2, 2.6). Reads give the "wow" at zero risk. The first 6 recipes to ship (Q10): ideas 1, 2, 3, 5, 7 (drafts only), 9.

**Gaps this catalog does not close, to flag honestly to owners:** the API exposes no documented way to change class prices, run payments, or read WhatsApp history. Anything Arbox shows in its app but not in these operations is out of reach. **ASSUMED**: T1 may reveal Arbox features (e.g., app engagement, retail, Meta WhatsApp automation) that matter to owners and have no API operation; list those as "not possible yet" in the guide.

---

## 3. Discovery interview

Shape (from `grilling/SKILL.md`): rounds, numbered questions, **each carries a recommended answer worded so "yes" accepts it**, the frontier of unblocked questions asked together, the next round only after answers. Adaptations for non-technical owners:
- Max 3 or 4 questions per round. Plain words, no jargon.
- **Never ask what the agent can look up.** Before connect, ask only owner-only facts. After connect, state looked-up facts and ask "right?".
- Mirror the owner's language (Hebrew or English; **ASSUMED, see Q1**). The skill body is English; the transcript follows the owner.
- Record answers in `~/Arbox/business-profile.md` as the interview goes, so a dropped session resumes mid-interview and the interview is never repeated.
- "I don't know" is a valid answer. Move on and note it.

### Round 0: silent checks (no questions)
OS, `curl` present, profile file present, key file present (existence only), workspace folder. If a profile exists, skip rounds 1 to 3.

### Round 1: the business (ask together)
| Q | Question | Recommended answer to offer |
|---|---|---|
| 1.1 | What kind of business is it? (Pilates, yoga, CrossFit/functional, gym, personal training/boutique, kids' classes/courses, mix) | Inferred from the first message ("It sounds like a Pilates studio, right?") |
| 1.2 | Roughly how many members, and how many classes a week? | A range ("about 150 members, 30 classes") if inferrable, otherwise ask open |
| 1.3 | One location or several? If several, does each have its own Arbox login/key? (D5) | "One location" |
| 1.4 | What do you mainly use Arbox for today: bookings, memberships/packs, leads, payments, forms? | "Bookings and memberships" |

### Round 2: goals and pains (branch on 1.1)
Common question: **2.1 "Over the last month, what did you wish you'd known sooner?"** (free text, always ask), followed by a pick-two menu tuned to the type:

| Branch | Pick-two menu (plain-words) | Typical recommended answer |
|---|---|---|
| **Pilates / reformer / small-group studio** | (a) Empty or always-full classes and waiting lists, (b) members drifting away, (c) packs about to run out, (d) instructor schedule and load, (e) late cancellations and no-shows, (f) private-session availability | b + c |
| **Yoga / mat studio** | (a) Intro-offer buyers who don't come back, (b) workshops and series filling, (c) drifting regulars, (d) teacher popularity, (e) renewals | a + c |
| **CrossFit / functional / group-training box** | (a) Members quitting around month 3, (b) drop-ins and trials not converting, (c) coach attendance and class capacity, (d) memberships expiring, (e) failed payments | a + b |
| **Gym (large membership base)** | (a) Inactive members, (b) lead pipeline and sales follow-up, (c) payments and debt, (d) busy-hour crowding, (e) membership mix and pricing | a + b |
| **Personal training / boutique 1:1** | (a) Trainer availability vs. demand, (b) no-shows, (c) lead follow-up, (d) package renewals | a + b |
| **Kids / courses ("hugim")** (**ASSUMED naming**) | (a) Course enrollment vs. capacity, (b) trial to enrollment, (c) term-end renewals, (d) parent communication | a + c |
| **Several locations** (add-on) | (a) Compare branches, (b) one view across keys | a |

Follow-up probes (only if the owner is vague): "When did you last lose a member without noticing?", "What do you do on Sunday night to prepare for the week?", "What number do you check most?"

### Round 3: boundaries and form (ask together)
| Q | Question | Recommended answer |
|---|---|---|
| 3.1 | Should Claude only look and report, or also do small things for you, like add a note or create a follow-up task? | "Look first; I'll say yes to tasks and notes later" |
| 3.2 | For messages to members: should Claude only write drafts for you to send yourself? | "Drafts only" (default in v1; Q3) |
| 3.3 | Who will see these reports: only you, or staff too? | "Only me" |
| 3.4 | Anything about members you do not want Claude to look at (health notes, injuries, salaries)? | "Skip health, injury and salary details" (default; Q5) |
| 3.5 | Where do you like to work with data: a web page, Excel, Google Sheets, WhatsApp? | "A web page I can open; also a spreadsheet file if I need it" |

### Round 4: after the owner picks an idea
| Q | Question | Recommended answer |
|---|---|---|
| 4.1 | What would make this useful to you on Monday morning? (one sentence, becomes the acceptance test) | Offered from the idea's pitch |
| 4.2 | One time only, or every week? | "Every week" for digests and watch lists; "once" for dashboards |
| 4.3 | Which definition: for "drifting", haven't booked in 3 weeks? For "expiring", within 14 days? | The recipe's default threshold |

### Round 5: after the build
"Does this match what you know?" (spot check one named member or number), then "What would you change?", then the next-ideas offer.

### Rules for the interview skill
- Stop interviewing early if the owner gives a concrete request ("I want a list of members who owe me"). Go straight to setup and recipe.
- Frontier-empty test before proposing: type known, top pains known, write boundary known. Anything missing is asked or recorded as "default assumed: ...".
- If the owner reports a pain no catalog idea covers, say so and mark "build on request, from the API reference" instead of inventing a recipe.

---

## 4. Proposed skill set

**Recommendation: 3 skills.** Names are `name == directory`, standard frontmatter only (`rt:` 3.2).

### 4.1 `arbox-guide`
- **Trigger text (description):** "Use when an owner or manager of a gym, Pilates, yoga, CrossFit or fitness studio asks what they can do or build with Arbox and Claude Code, wants ideas, says they're new to this, or asks how Claude can help run the business using Arbox data. Interviews them, then proposes what to build."
- **Owns:** steps 1 to 7, 9 and 13 of the journey. The interview (section 3), the ideas catalog with pitches (`references/ideas-catalog.md`), the business profile file, the plain-language "what's possible and what's not" explanation, the "never use jargon" voice rules, the returning-owner branch.
- **Does not own:** keys, HTTP, safety rules, report building.
- **Hands off to:** `arbox-api` at step 8 (connect), `arbox-recipes` at step 10 (build). Receives control back at step 13.

### 4.2 `arbox-api`
- **Trigger text:** "Use for any request that reads or changes Arbox data, connects an Arbox API key, tests the connection, or hits an Arbox API error. Owns authentication, the safe read/write executor, safety rules, pagination, and the Arbox glossary (box, category, service, class, session, location)."
- **Owns:** the setup gate (`references/setup.md`): key acquisition guidance, key storage without chat paste, `arbox doctor`, connection test, workspace creation, safety defaults. The executor (`scripts/arbox.sh`), the read/write split and tier table (R0 to R3), glossary and quirks (id types, booleans, `location_id`, 31-day cap, the `fromDate` vs `from_date` drift), per-tag `references/*.md` (hand-written meaning, not generated signatures, `rt:` 2.3.3), error handling. Also serves developers: its references are the API knowledge.
- **Does not own:** deciding what to build, report layouts.
- **Hands off to:** `arbox-recipes` for build requests, back to `arbox-guide` if the owner is lost ("what can I do with this?").
- **Why setup lives here, not in a 4th skill:** the api skill must check "is a key configured?" on every use anyway, so a separate onboarding skill would duplicate that gate and make two skills compete for triggers like "connect" and "API key". A reference file loaded only when the gate fails gives the same progressive disclosure for zero extra catalog tokens (`vsp` section 3).

### 4.3 `arbox-recipes`
- **Trigger text:** "Use when asked to build, run or save one of these studio tasks from Arbox data: who's drifting or churn risk, weekly digest, class fill and waiting lists, revenue snapshot, pack and membership expiry, birthday messages, lead and trial follow-up, dashboards. Produces a local report and a rerunnable routine."
- **Owns:** one recipe file per idea (`references/recipe-<idea>.md`: exact operations, thresholds, computation rules, output spec, spot-check method, pitfalls), the output templates (`assets/report.html` with RTL-safe `dir="auto"`, CSV conventions), the routine file format, the "save as routine" and "run my X routine" behavior, the draft-for-approval pattern.
- **Does not own:** key handling, raw HTTP, interviewing.
- **Hands off to:** `arbox-api` for every call and for any write (all writes pass through its tier table).

### 4.4 Why three and not more or fewer

| Option | Verdict |
|---|---|
| 1 skill | Rejected: the guide would load 50 KB of API quirks to answer "what can I build?", and a direct request like "build my churn list" would drag in the whole interview. Descriptions for guide and execution are different triggers. |
| 2 skills (guide + api, recipes folded into api) | Plausible fallback. Rejected because recipe content is the part that grows most (22 ideas) and the part that needs distinct evals; folding it into api blurs the safety core, which must stay small and stable. |
| **3 skills (guide, api, recipes)** | Chosen. Each answers a different owner sentence: "what can I build?" / "connect or run something against Arbox" / "build me X". |
| 4+ (separate setup, one per business type, one per tag) | Rejected: business-type skills duplicate recipes, per-tag skills collide on triggers (`rt:` 2.5), separate setup duplicates the key gate. |

Trigger-collision discipline: guide fires on *exploration* words (what can I, ideas, new to this); api fires on *connect/error/raw access* words; recipes fires on *named tasks*. Needs a near-miss eval set run against all three installed together (`rt:` 2.5.6).

### 4.5 Install and cross-skill dependencies
- The three skills ship together. Each SKILL.md references the others **by name, never by relative path** (copy-mode installs break paths, `rt:` 2.4.4). If the api skill is missing, the guide tells the owner the one install command.
- The executor is copied by setup to a fixed home path, `~/.arbox/bin/arbox`, and always called by that absolute path. Reasons: independent of where any channel put the skill, no PATH edits, one stable string for permission allowlists. **LIVE CHECK** (see L6 in section 5b).
- **Install channel for owners:** primary = Claude Code plugin marketplace (`/plugin marketplace add ...`, `/plugin install ...`), because `npx skills` requires Node and a native-installer Claude Code install may not provide it. `npx skills add` stays the channel for developers and other agents. This weakens the lead's counter in `rt:` Lead response to 2.4 for the owner persona specifically: the Node assumption does hold for `npx` but the owner may not use `npx`. **LIVE CHECK.**

### 4.6 Workspace layout created by setup
```
~/Arbox/                      # owner-visible; plain English names
  business-profile.md         # from the interview; no secrets; loaded by guide on return
  CLAUDE.md                   # 5 lines: "this folder is the owner's Arbox workspace; use arbox-* skills"
  reports/                    # HTML/CSV outputs, dated
  routines/                   # saved "run my X" files
  logs/actions.log            # every write: time, operation, target count, no key, no member PII beyond ids
~/.arbox/                     # hidden; machine-owned
  profiles                    # name=key lines, chmod 600; read ONLY by the executor
  bin/arbox                   # the executor
```

---

## 5. What "build" means for a non-coder

| Artifact | When | Pros | Cons |
|---|---|---|---|
| **Chat answer** | Quick questions, ideas 4, 18, anything under ~20 rows | Instant, zero files | Not shareable, gone with the session |
| **Local HTML report** (single self-contained file, opened in the browser) | Anything the owner wants to look at, scroll, print, or show staff | No install, works offline, looks good, printable to PDF, RTL-safe | A snapshot, not live; refreshing means rerunning |
| **CSV file** | Lists to act on (call these 27 people) | Opens in Excel and imports into Google Sheets with no connector | Plain; no formatting |
| **Saved routine** (`~/Arbox/routines/<name>.md`) | Anything done twice | Owner reruns with one sentence; no script to maintain; recipe edits propagate | Needs Claude Code open; token cost each run; slight output variance |
| **Script the owner reruns** | Developers only | Deterministic | A non-coder cannot read, trust, or fix it. **Not offered to owners** |
| **Scheduled recurring report** | Later, if wanted | Real automation | See below |
| **Google Sheet** | If the owner already lives in Sheets | Familiar | Requires a connector/auth we do not control. **Bridge via CSV in v1** |

**Recommended default:** a **local HTML report generated by a saved routine**, with a **CSV beside it** whenever the output is a list of people to contact. A chat answer for one-off questions. Why: it matches what the owner can see, trust and show; it needs no installs; and a routine (a markdown file the owner can read) keeps the build inside Claude rather than in code the owner cannot verify. Determinism comes from the report template and from fixed thresholds written into the recipe, not from a generated script.

**Scheduling is a trap for v1.** Claude Code's cloud scheduled routines (`/schedule`) run off the owner's machine and therefore **cannot read `~/.arbox/profiles` or reach local files** (**ASSUMED**, **LIVE CHECK**). OS-level schedulers (launchd, Task Scheduler) are beyond a non-coder. Recommended: v1 = "rerun with one sentence". Revisit scheduling once the owner demand is known (open Q4 in `decisions.md`).

**Draft-for-approval pattern (all member-facing text):**
1. Agent writes drafts to `~/Arbox/reports/<name>-drafts.html` (or CSV) with one row per member: who, why selected, the exact message, channel allowed.
2. Owner edits and approves in the file or in chat.
3. v1: owner copies and sends it themselves (Arbox or WhatsApp). v1.1 (if Q3 approves): `arbox write` sends the approved batch, capped at 20 recipients, with a send-to-yourself test first, and a one-line log entry.

**Report hygiene:**
- Always show the date range, data freshness time, and the filter definition in the report header ("haven't booked in 21+ days").
- Truncation warning: if a list hit `limit=500` or the page cap (`api:` Pagination has no total), say so on the page and in chat. Never print "you have 312 members" when the count may be capped.
- Spot-check line: report names one member or one number the owner can verify.

---

## 5b. Execution for non-coders (the "least sure of" item)

**Constraint set:** `curl` is the only runtime guaranteed on macOS (**LIVE CHECK** on current macOS), Claude Code's native installer may not put Node on PATH, `python3` on a fresh Mac may be an Xcode-tools stub that triggers an install prompt (**LIVE CHECK**), and `jq` ships with recent macOS but not old ones (**LIVE CHECK**, version cutoff unverified).

**Proposal: `arbox` = one POSIX `sh` script around `curl`, with a hard read/write split.** Raw agent-composed curl is the documented fallback only.

```
~/.arbox/bin/arbox doctor                       # checks curl, jq, node, python3 (real, not stub), OS, profile file; no secrets printed
~/.arbox/bin/arbox read  [-p profile] GET <path> [key=value ...] [--out file] [--pages N]
~/.arbox/bin/arbox write [-p profile] <METHOD> <path> --body-file f.json     # separate verb on purpose
```

Design rules (each traced to a finding):
1. **Key never in argv, env of the model, transcript, or error output.** The executor reads `~/.arbox/profiles` itself and feeds the `api-key` header to `curl --config -` via stdin. No `--api-key` flag. Output and errors are scrubbed. (`rt:` 2.1.2 to 2.1.4)
2. **The agent never reads `profiles` or any `.env`.** SKILL.md says so; setup.md has the owner paste the key into the file in a text editor (`open -e` on macOS), so the key does not pass through chat. (**LIVE CHECK**: whether `! <command>` interactive input works as a simpler path.)
3. **Hard-coded base URL** `https://arboxserver.arboxapp.com/api/public`. An override is honored only for `localhost` (tests). (`rt:` 2.6.3)
4. **`read` accepts only GET.** `write` accepts POST/PATCH/DELETE. So the harness permission rule can allow `read` and prompt on `write`. Setup offers (not forces) an allow rule like `Bash(~/.arbox/bin/arbox read:*)` (**LIVE CHECK**: rule syntax with `~`). `write` is never allowlisted. Setup tells the owner not to use accept-everything mode. (Lead response in `rt:`.) A plugin-channel `PreToolUse` hook can enforce more strongly later.
5. **Big results go to files.** `--out` writes under `~/Arbox/work/`, prints row count, field names and a 3-row sample, not the whole payload. This keeps member data and tokens out of the chat. Auto-pagination is bounded (`--pages`, default 10, `limit=500`). **Weak spot:** without `jq`, merging pages in plain `sh` is awkward, so the fallback is one file per page plus a manifest, merged by whatever runtime `doctor` found (see rule 7). **LIVE CHECK** that `jq` is present on target Macs.
6. **No auto-retry on writes. Write receipts:** `write` prints the plan (method, path, target location, record count) and appends to `logs/actions.log` after a 2xx.
7. **Compute with whatever exists.** Recipes describe *what to compute* in runtime-neutral terms. The agent picks `jq`, then `node`, then a real `python3`, then does it directly in-model for under ~200 rows. `doctor` reports which exist. No runtime is required beyond `curl` for the *read-and-answer* path.
8. **Windows:** Claude Code on Windows runs commands through a bash shell (Git for Windows) that bundles `curl` (**ASSUMED**, **LIVE CHECK**). Treat Windows as best-effort until tested; macOS is the v1 target.

**Ranking of execution options for the owner persona:**
1. `sh`+`curl` wrapper with read/write split (recommended).
2. MCP server: better key isolation (`userConfig` secrets reach MCP env, `ccp` Secrets) and per-tool permission prompts, but 65-op schema weight and a process to run. Revisit if a live check shows the key-via-file flow confuses owners.
3. Node script: fine for developers, unreliable for owners.
4. Agent-composed raw curl: fallback when the wrapper cannot be installed (e.g., a web sandbox). Expands the key into the command string, so only with the key read from a file by the shell.

### LIVE CHECK list (ordered by blast radius)

| # | Check | Why it matters |
|---|---|---|
| L1 | On a clean Mac with only the native Claude Code install: `command -v curl node jq python3`; what `python3` does (stub prompt?) | Decides whether the compute fallback chain is real |
| L2 | `npx` availability in that state; does `/plugin marketplace add` install the three skills without Node? | Decides the owner install channel |
| L3 | Where owners get the API key in Arbox, and whether it is per location (D5), read-only or full-power (`api:` open Q1; T1 may answer) | Setup copy, safety tiers, multi-key design |
| L4 | `GET /v3/locations` with a good key and with a bad key: status codes and bodies (spec declares only 200/404/422, `rt:` 2.7.7) | Connection test and error messages |
| L5 | Pagination: does any list reveal a total or "last page"? What does `limit=500` return on the test gym? `extra` contents? Any rate limiting under 20 rapid calls? | Truncation warnings, `--pages` default |
| L6 | Harness: does the allow rule `Bash(~/.arbox/bin/arbox read:*)` auto-allow reads and still prompt for `write`? Does `!` accept hidden input? | The write gate and key-entry flow |
| L7 | Which reports return which fields; `bookingStatisticsReport`, `revenueAnalysisReport` shapes; whether `salesReport` obeys the 31-day cap | Recipe correctness |
| L8 | `POST /v3/message` behavior on the test gym: sends immediately? to yourself? WhatsApp vs push? | Whether v1.1 send is feasible |
| L9 | Hebrew: UTF-8 round-trip through curl JSON bodies and HTML reports; RTL rendering | Message drafts and member names |
| L10 | Cloud `/schedule` routines cannot reach local profile/files (**ASSUMED**) | Whether to promise scheduling at all |

---

## 6. Open questions for the human (with recommended answers)

| # | Question | Recommended answer | Why |
|---|---|---|---|
| Q1 | **Language.** Will many owners work in Hebrew? Should the guide mirror the owner's language (Hebrew or English) automatically? | Yes: mirror language; skill bodies in English; reports with `dir="auto"`; Hebrew fixtures in evals | Arbox is likely Israeli (**ASSUMED**; `decisions.md` has Hebrew open as Q7b). Cheap to design in, costly to retrofit (`rt:` Q10) |
| Q2 | **Install channel for owners:** Claude plugin marketplace as primary, `npx skills` for developers and other agents? | Yes | `npx` needs Node (L2); owners may not have it |
| Q3 | **Write policy.** v1 = reads free, R1 writes (notes, tasks, lead status) with in-chat confirmation showing count and target location, messages as **drafts only**, R3 never? Enable agent-sent messages in v1.1 only after the test gym passes eval (L8)? | Yes | Matches `rt:` Q3; D4 gives us a test gym to earn the right to send. Drafts already deliver the value |
| Q4 | **Where does an owner get the API key, and is it per location?** Can your Arbox friend tell us the exact steps and the key's permissions? | Get this from the Arbox contact before writing setup.md; until then setup says "ask Arbox support or your account manager" | Setup flow and tiering depend on it (L3); T1 may cover it |
| Q5 | **Privacy stance.** Member data (names, phones, activity) will flow through the owner's Claude session. By default exclude health/injury/medical fields (`PATCH /v3/users/injury`, waiver type `medical`) and salary (`staffSalary`), and show a one-paragraph plain-language notice in setup? | Yes | Health data is sensitive (`rt:` 2.2.8). The notice protects the owner; not legal advice, flag for review |
| Q6 | **Scheduling.** v1 offers "rerun by one sentence" only, no promise of automatic weekly runs? | Yes | L10; OS schedulers too technical; reconsider with owner demand (`decisions.md` Q4) |
| Q7 | **Day-one agents.** Claude Code only, others "best effort, untested"? | Yes | Only Claude Code can be eval'd (`rt:` 2.6.2); the owner persona is Claude Code (`decisions.md` Q5) |
| Q8 | **Workspace name and location.** `~/Arbox/` (visible) plus `~/.arbox/` (hidden)? | Yes | Owners need to find their reports; secrets stay out of sight |
| Q9 | **What ships on day one?** 3 skills; recipes for 6 ideas (1, 2, 3, 5, 7-drafts, 9); the other 16 catalog ideas answered ad hoc from `arbox-api` references? | Yes | Fewer, sharper; each recipe is eval'd; the rest degrade gracefully |
| Q10 | **Naming and affiliation.** Public repo, unofficial: README and skill text say "community project, not by Arbox"? | Yes (`decisions.md` D3), and ask the Arbox friend for an OK to use the name and spec-derived content (`rt:` 2.8.4) | Trademark and redistribution |
| Q11 | **Developers (secondary audience).** Serve them only through `arbox-api` references and the executor, with no separate developer skill? | Yes | Same facts, less surface (`rt:` Branch B discussion) |
| Q12 | **Evals.** Persona evals: a simulated Pilates owner runs the flagship conversation against the test gym; deterministic assertions (no key in transcript, no write without confirm, three ideas offered, profile written) rather than a model judge? | Yes | `rt:` 2.6.6 |

---

## 7. Reconciliation status and risks

- **T1 (`arbox-product.md`) not present at write time.** Product-side claims marked ASSUMED: where owners get a key, "hugim" meaning, WhatsApp/Meta integration availability, how owners describe their workflows, and Hebrew prevalence. Re-read T1 and promote or demote each ASSUMED before section 4's trigger text is finalized.
- **Weakest points of this design:** (1) the `sh`+`curl` executor's multi-page merge without `jq`; (2) the key-via-text-editor flow is untested with real owners; (3) recipe correctness depends on report field shapes that are typed but undocumented (L7); (4) three skills means three descriptions in the catalog on every session, accepted for the routing clarity.
- **Done-means check:** sections 1 to 6 present; 22 catalog ideas each cite operations from `api:`/`spec:`; sample transcript included; execution proposal with explicit LIVE CHECKs; no skill or code files created.
