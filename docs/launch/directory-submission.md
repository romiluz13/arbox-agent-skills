# Submitting to the Claude plugin directory

Anthropic's official marketplace (`claude-plugins-official`) "doesn't take submissions through the directory portal" ([publish docs](https://code.claude.com/docs/en/plugins/publish)). The public **Claude plugin directory** does, from the developer portal at <https://claude.ai/directory/manage>. Submitting needs a paid claude.ai plan and the submitter's own acknowledgements, so a person does the last step. Directory installs reach Claude Code as `arbox@synced` (same page: "Claude Code loads it as `<name>@synced`"). Sources: [submit a plugin](https://claude.com/docs/plugins/submit), [pre-submission checklist](https://claude.com/docs/plugins/pre-submission-checklist).

## Before you submit

| Checklist item | Status |
|---|---|
| `.claude-plugin/plugin.json` at the repository root; `claude plugin validate . --strict` passes | Done |
| Name: lowercase, ≤ 64 chars | `arbox` |
| Name not a brand you don't own | **May be held for a reviewer** ("Name matches a known brand"). "Arbox" is Arbox's brand. Best: Arbox submits it from its own organization (the name then matches the publisher). Otherwise expect a review hold; the listing says "Community project, not affiliated with Arbox". |
| `description`, `author`, `version` set | Done |
| README ≥ 40 words, LICENSE present | Done (MIT) |
| No `.DS_Store`, symlinks, submodules, LFS | Done (`.gitignore`) |
| Every non-image file < 256 KiB, < 512 files | Done (largest text file: the spec snapshot, under the limit; count the files at submission time) |
| Images complete PNG/GIF, each < 5 MiB | Done |
| No hooks, no MCP servers, no package launchers in the plugin | Done |
| No real credentials in any file | Done (tests use a fake key) |
| README describes everything the plugin runs, sends or fetches | Done: "What it runs and sends" |
| Behaviour tested with and without the plugin | Done: [evals/results.md](../../evals/results.md) |

## Form fields

**What would you like to submit?** Plugin bundle

**Source**
- Repository: `https://github.com/romiluz13/arbox-agent-skills`
- Plugin path: *(empty, the root)*
- Branch or tag: `arbox--v0.9.0` (the release tag `claude plugin tag` creates; or leave empty to follow `main`)

**Listing details**
- Display name: Arbox Agent Skills
- Short description: Ask Claude Code about your studio in plain words and get answers from your own Arbox: who stopped coming, whose pack is ending, who owes you. Reports and message drafts you send yourself; small changes only after your yes.
- Category: Productivity / Business
- Long description: use the README (the directory shows it).
- Links: repository; issues `https://github.com/romiluz13/arbox-agent-skills/issues`

**Data handling** (answer in these words)
- What it accesses: the user's own Arbox account through the Arbox public API, with the API key the user enters into a local file (`~/.arbox/profiles`, mode 600). The key never enters the chat.
- Where data goes: requests go only to `arboxserver.arboxapp.com`. Results are saved as local files under `~/Arbox/`. What Claude reads is processed by Anthropic as part of the conversation, like anything the user types. No other destination, no telemetry, no analytics.
- Writes: only seven small internal changes (create a lead, change a lead status, mark a lead lost, add a lead note, create a task, complete a task, add a member note), each after the user's explicit yes. Messages, bookings, payments, memberships and deletes are refused by the bundled script.
- Personal data: member names and contact details appear in local reports the user asks for; health details, ID numbers, addresses and card digits are left out by default.
- Retention (confirm): nothing is stored by the plugin outside the owner's computer; local reports and logs stay until the owner deletes them.
- Age (confirm): for business owners and their staff; not intended for people under 18. Reports about minors show totals only.

**Compliance:** contact email and the four acknowledgements are the submitter's own. Read the [Anthropic Software Directory Policy](https://support.claude.com/en/articles/13145358-anthropic-software-directory-policy) before ticking them.

## After you submit

- Fix anything marked **Blocking** after **Validate**, push, then **Re-validate**.
- A "Policy hold" (possible for the brand name) is not a rejection; a reviewer reads it.
- Every release: bump `version` in `.claude-plugin/plugin.json`, add a CHANGELOG entry, then `claude plugin tag . --push` (tags `arbox--v<version>`).
