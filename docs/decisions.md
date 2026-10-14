# Design decisions

Short records of what we decided and why. Sources: docs/research/ and docs/design/.

| # | Decision | Why |
|---|---|---|
| D1 | **Audience: owners of Arbox businesses** (gyms, Pilates, yoga, CrossFit, studios, clinics, salons, educators) who use Claude Code. Developers come second. | Owners now open Claude Code and ask "what can I build?". Nobody guides them. |
| D2 | **Two layers: guide plus API.** The skills teach the agent what Arbox is, interview the owner, suggest what to build, and only then call the API. | Raw API knowledge doesn't help someone who doesn't know what to ask for. |
| D3 | **Public community project**, not affiliated with Arbox. | Open to every Arbox customer; it can be handed to Arbox later. |
| D4 | **Three skills: `arbox-guide`, `arbox-api`, `arbox-recipes`.** | One skill would load API details just to answer "what can I build?". More skills compete for the same triggers. Each answers a different owner sentence. |
| D5 | **Executor is a POSIX `sh` script around `curl`** with separate `read` and `write` verbs. | The native Claude Code installer doesn't bring Node or Python, but curl is on every Mac. Separate verbs let the agent's own permission system allow reads and prompt on writes, so the gate is enforced outside the model. |
| D6 | **The API key lives in `~/.arbox/profiles`, never in chat**, and reaches curl only via stdin. | Chat transcripts are stored. A key in argv shows up in `ps`. |
| D7 | **Write tiers.** R0 reads are free. R1 (notes, tasks, lead status, create lead) needs in-chat confirmation. R2 (messages) is drafts only. R3 (money, deletes, merges, membership changes, recurring payments) is never done by the agent. | Same line as Wodify's read-only gym connector and Stripe's human approval for money moves. These are live customers and real money. |
| D8 | **Several named profiles** (one per branch or key). | Branches can have separate keys. Writes must name the target location. |
| D9 | **Docs links everywhere.** Every skill has a Documentation section, every one of the 65 operations has its deep link, and the live spec is `https://arboxserver.arboxapp.com/docs/api.json`, with a dated snapshot bundled. | LLMs can't trust a summary alone. They need to be able to read the source. |
| D10 | **The guide branches on operating model** (group classes / 1:1 appointments / courses / spaces) and plan tier, not on vertical. | Arbox's vertical pages share one template. Plan tier gates features (leads, auto actions, insights need Standard+). |
| D11 | **Mirror the owner's language** (often Hebrew). Skill files are in English. Reports are RTL-safe. | Arbox's home market and help center are Hebrew-first. |
| D12 | **Privacy defaults:** health, injury and medical-waiver fields and staff salary are excluded unless the owner asks. A short notice is shown in setup. | Member health data is sensitive. |
| D13 | **Default output: a local HTML report plus a CSV**, rerunnable by one sentence. No scheduling in v1. | Owners can see, print and share HTML. Cloud schedulers can't reach a key on the owner's machine. |
| D14 | **One repo, two install channels:** Claude Code plugin marketplace (no Node needed) and `npx skills add` for other agents and developers. | The `skills` CLI reads the same `skills/` folder and the plugin manifests. |
| D15 | **Standard frontmatter only**, `name` = directory, validated in CI. | Portable across Claude Code, Cursor, Codex, Gemini CLI, OpenCode and others. |
