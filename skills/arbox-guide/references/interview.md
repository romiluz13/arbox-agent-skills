# Interview question bank

Adapted from the grilling style for a non-technical owner: at most two rounds before the first idea, 3 questions in round 1, every question carries a recommended answer worded so "yes" accepts it, one round at a time, wait for answers. Plain words only. Mirror the owner's language (Hebrew or English). Save to `~/Arbox/business-profile.md` after every round.

## Rules

- Never ask what you can look up. Before the owner connects, ask only what only they know. After connecting, state facts you looked up and ask "right?".
- Guess from their first message and offer the guess as the recommended answer.
- A question that depends on an unanswered question belongs to a later round.
- "Not sure" is valid. Write it in the profile and move on.
- The plan tier is never asked up front. Ask it only when a proposed idea is plan-gated, as one question. If unsure, assume Free for gating and say so.
- Never ask about no-show or late-cancel fees. That is a recipe-time question.
- Stop early if the owner makes a concrete request. Go to the hand-off.
- Done when: operating model, top pain and hands-on level are known. Anything missing is written as "assumed: ...".

## Format of a question

```
Q2 - Size: About how many active members, and how many classes a week?
My guess: around 150 members and 30 classes. Close?
```

In Hebrew keep the same shape ("השערה שלי: ..."). One short line of context at most.

## Round 1: three questions (ask together)

| Q | Question | Recommended answer to offer |
|---|---|---|
| 1.1 | What do you mainly sell: group classes, one-on-one sessions, courses/workshops, or bookable spaces/venues? (Operating model; decides the branch knowledge below.) | Inferred from their first message |
| 1.2 | What is your biggest headache right now? Free text first. If they are vague, offer the pick-two menu for their model (below). | The bold answer in the menu for their model |
| 1.3 | How hands-on should I be: only look and report, drafts for you to send, or small updates with your yes? | "Drafts, and ask me before any change" |

## Round 2: only if an idea needs it (ask together)

Skip this round unless a proposed idea depends on one of these answers, or the owner wants more tailoring.

| Q | Question | Recommended answer |
|---|---|---|
| 2.1 | Roughly how many customers and classes a week, and how many locations? | A range from their message; "one location" if not said |
| 2.2 | Hebrew or English for the reports and drafts? | Their language |
| 2.3 | Where do you like to see results: a web page, Excel, Google Sheets, or chat? | "A web page I can open, plus a spreadsheet file if I need it" |

If several locations, ask after connecting: "Do the branches share one Arbox login?" Do not promise branch-by-branch reports until `arbox-api` confirms how connections work for them.

## Plan tier (ask only when gated)

Plan gates to remember: leads and tasks, auto actions, email, smart insights and advanced reports need Standard or higher. Branded app and spaces management need Professional. Whether API access depends on plan is not confirmed; `arbox-api` finds out when connecting.

When an idea is plan-gated and the plan is unknown, ask once: "Which Arbox plan are you on? Not sure is fine." Not sure: assume Free for gating and say so.

## Branch knowledge (material for you, not questions to read out)

Use the menu for the owner's model to guess the headache in 1.2 and to rank ideas. Offer it as a pick-two only when the owner is vague. Recommended answer in bold.

**Group classes and memberships** (Pilates, yoga, CrossFit, gym, martial arts, dance, spinning)
- (a) Classes half empty, or always full with a waiting list
- (b) Members drifting away; I notice only when they are gone
- (c) Packs and memberships expiring and nobody renews
- (d) Late cancellations and no-shows
- (e) New members who try us and never come back
- (f) Failed or overdue payments
- (g) New leads and trials not followed up
- Recommended: Pilates/yoga **b + c**; CrossFit **e + b**; gym **b + g**.

**One-on-one appointments** (personal trainer, clinic, therapist, beauty, tutor)
- (a) No-shows and last-minute cancels
- (b) Empty slots versus demand
- (c) Clients who stop rebooking
- (d) Package renewals
- (e) Leads and first appointments not converting
- (f) Forms and paperwork not signed
- Recommended: **a + c**.

**Courses and workshops** (kids' classes, education, activities, corporate)
- (a) Courses not filling, or too full
- (b) Trial to enrollment
- (c) Term-end renewals
- (d) Waivers and parent forms not signed
- (e) Reminders and communication with families
- Recommended: **a + c**.

**Spaces and venues** (rooms, courts, equipment, group bookings)
- (a) Utilization: which slots sit empty
- (b) Group bookings and payment collection
- (c) Waivers
- (d) Repeat customers
- Recommended: **a + d**.

**Several locations** add: (x) compare branches side by side. Recommended: yes if they said several.

Follow-up probes only if the owner is vague: "When did you last lose a member without noticing?", "What do you do on Sunday night to prepare for the week?", "Which number do you check most?"

If their pain is not about members at all ("I never have time to post", "my website is old"), that is a no-connection idea; see the table in [SKILL.md](../SKILL.md).

## Stated defaults (not asked)

- Drafts only for messages to members. This is a rule; the owner cannot switch it off here.
- Health, injury and salary details are skipped unless the owner asks. Written into the profile as the default.

## Ask when the first report is ready

| Q | Question | Recommended answer |
|---|---|---|
| R.1 | Who will see these reports: only you, or staff too? | "Only me" |
| R.2 | Once, or every week? | "Every week" for watch lists; "once" for one-off analysis |

## Round 5: after they pick an idea

| Q | Question | Recommended answer |
|---|---|---|
| 5.1 | What would make this useful on Monday morning? (one sentence, becomes the check) | Offered from the idea's pitch |
| 5.2 | Your definition: "drifting" = no visit for 3 weeks? "Expiring" = within 14 days? | The recipe's default |

Hand the answers to the next skill. Do not re-ask in the recipe.

## After connecting (facts, not questions)

Once `arbox-api` has connected and the recipe starts, confirm facts the agent found: "I see one location, about 183 active members and 41 classes this week. Is that right?" Correct the profile. If reality contradicts an idea (no waiting lists, no leads), say so and re-pick.

## After the build

Spot check: "Does Dana K. at the top look right to you?" Then "What would you change?" then offer the next two ideas and update the profile.

## Worked example (Hebrew, condensed)

```
Owner:  היי, איך אפשר להשתמש בארבוקס וקלוד קוד? מה אפשר לבנות?
Claude: שאלה מצוינת. קלוד יכול לקרוא את המידע שלך בארבוקס (מתאמנים, שיעורים, לידים, תשלומים),
        להפוך אותו לרשימות ודוחות, ולנסח הודעות שאתה שולח בעצמך. הוא גם יעזור בדברים שלא קשורים
        לארבוקס: תיאורי שיעורים, פוסטים, אתר פשוט. שום דבר לא משתנה ולא נשלח בלי אישור שלך.
        כמה שאלות קצרות כדי שאציע דברים שמתאימים לך:
        ש1 - מה אתה מוכר: נשמע סטודיו פילאטיס עם שיעורים קבוצתיים. נכון?
        ההשערה שלי: כן.
        ש2 - מה הכי כואב לך עכשיו: מתאמנים שנעלמים בלי שאתה שם לב?
        ההשערה שלי: כן.
        ש3 - עד כמה להיות מעורב: לקרוא ולהציע טיוטות, או גם לעדכן דברים בארבוקס בהסכמה שלך?
        ההשערה שלי: טיוטות, ושאלה לפני כל שינוי.
```
