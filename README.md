# Arbox Agent Skills

**Turn Claude Code into a business partner that knows your Arbox studio.**

You run a gym, Pilates or yoga studio, CrossFit box, clinic or salon on [Arbox](https://www.arboxapp.com). You installed Claude Code. Now ask it:

> *"How can I use Arbox and Claude Code? What can I build?"*

With these skills, Claude:

1. **Explains what's possible** in plain words, in Hebrew or English.
2. **Asks a few quick questions** about your business: what you sell, your biggest headache, how hands-on you want it.
3. **Suggests three ideas that fit you**, including ones that need no connection at all (class descriptions, social posts, member messages, a simple website).
4. **Builds them**: reports from your real Arbox data that you can open, print and rerun with one sentence.

> Community project, not affiliated with or endorsed by Arbox.

---

## Install

**Claude Code (recommended, Mac first):** type this inside Claude Code:

```
/plugin install arbox --marketplace romiluz13/arbox-agent-skills
```

On Claude Code older than 2.1.275, use two steps:

```
/plugin marketplace add romiluz13/arbox-agent-skills
/plugin install arbox@arbox-agent-skills
```

**Other agents** (Cursor, Codex, Gemini CLI, OpenCode, Windsurf and others) or developers, using [`skills`](https://github.com/vercel-labs/skills), which needs Node:

```
npx skills add romiluz13/arbox-agent-skills
```

Pick one channel, not both. Then just talk to your agent: *"what can I build with Arbox?"*

---

## What's inside

| Skill | What it does | Say things like |
|---|---|---|
| **arbox-guide** | Learns your business, explains what's possible, proposes ideas, points you to Arbox features you already pay for | "What can I build?" · "I'm new to Claude Code" · "מה אפשר לעשות עם ארבוקס?" |
| **arbox-api** | Connects safely to your Arbox: key setup without pasting it into chat, safety rules, every API operation documented with a link to the official docs | "Connect my Arbox" · "Is my key working?" · "How do I book a member via the API?" |
| **arbox-recipes** | Ready-made reports, rerunnable with one sentence | "Who's drifting?" · "Who owes me money?" · "Run my Monday page" |

### Recipes

| Recipe | The question it answers |
|---|---|
| Renewal watch | Whose pack or membership runs out soon, and who has unused sessions? |
| Who's drifting | Which regulars have gone quiet? |
| Payments to chase | Who owes money, and whose card failed? |
| Leads and trials | Where's every lead and trial guest, and who didn't convert? |
| Sales snapshot | How am I doing this month vs last month? |
| Class fill | Which classes are empty, which are full, where are the waiting lists? |
| No-shows and late cancels | Who keeps missing or cancelling late? |
| First 30 days | Which new members haven't come back? |
| Waivers and forms | Who hasn't signed their health form or waiver? |
| **Monday page** | All of the above on one printable page |

**Want to see it before connecting?** Ask for any recipe "with sample data". It runs on a pretend studio, clearly labeled SAMPLE.

---

## Safe by design

- **Your key never goes in the chat.** You type it once, hidden, in a Terminal tab. It's stored in `~/.arbox/profiles`, readable only by you, and the helper never prints it.
- **Reading is safe. Changing needs your yes.** Claude can only make small, reversible updates (a lead note, a task, a lead status), and only after you approve each one. Claude Code asks you every time.
- **Messages are drafts.** Claude writes them; you send them.
- **Money, deletes, bookings and membership changes stay in the Arbox app.** The helper refuses them even if asked.
- **Privacy defaults:** health and injury details, ID numbers, addresses, card digits and staff salaries are left out. What Claude reads is processed by Anthropic like anything you type in Claude Code. Check your Claude privacy settings, and don't run this on a shared front-desk computer.
- **Everything is logged** in `~/Arbox/logs/activity.log`. Ask "show my activity".

## Getting your Arbox API key

In Arbox, look under **Settings → Business information** for the API key. If you don't see it, your plan may not include API access. The `arbox-api` skill gives you a ready-to-send email to Arbox support (Hebrew and English).

## Status

**v0.9.0: release candidate.** Every skill, safety rule and recipe is validated against the official API spec and a fake Arbox server, with automated tests and evals. **Verification against a live Arbox account is pending.** Each recipe asks you to compare one number with your Arbox screen on first run. Please [open an issue](https://github.com/romiluz13/arbox-agent-skills/issues) if something doesn't match.

---

## For developers

- The `arbox-api` references document all 65 operations and 47 reports. Every operation links to its exact page in the [official docs](https://arboxserver.arboxapp.com/docs/api). The machine-readable spec lives at <https://arboxserver.arboxapp.com/docs/api.json>, with a dated snapshot in `skills/arbox-api/references/openapi.json`.
- `skills/arbox-api/scripts/arbox` is a POSIX `sh` + `curl` helper with separate `read` and `write` verbs.
- Checks: `python3 tools/validate.py` (structure, links, 65/65 operations), `sh tests/run.sh` (helper against a fake server), `python3 tools/drift.py` (live spec vs snapshot, weekly in CI).
- Design decisions: [docs/decisions.md](docs/decisions.md). Research: [docs/research/](docs/research/).

---

### בעברית

**Arbox Agent Skills** עוזר לבעלי סטודיו, חדר כושר, קליניקה או מספרה שעובדים עם ארבוקס להשתמש ב-Claude Code. פשוט שאלו: *"מה אפשר לבנות עם ארבוקס וקלוד קוד?"*. Claude ישאל כמה שאלות על העסק, יציע רעיונות מותאמים, ויבנה דוחות מהנתונים שלכם: מי הפסיק להגיע, מנויים שמסתיימים, חובות, לידים ועוד. המפתח שלכם לא מוקלד בצ'אט, שום דבר לא משתנה בארבוקס בלי אישור שלכם, והודעות ללקוחות הן טיוטות שאתם שולחים. פרויקט קהילתי, לא של חברת ארבוקס.

## License

MIT
