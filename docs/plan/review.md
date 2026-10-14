# v0.9.0 review and vouch

Ticket 10. Each member reviewed independently; findings and fixes are in the linked files. A vouch covers what its author checked, nothing more.

| Member | Scope | Review | Vouch |
|---|---|---|---|
| **Haiku** (researcher) | API references vs the spec and a live test gym (84 checks: 50 pass, 0 fail, 31 blocked by an empty test account, 3 not run); recipes run live; owner-facing copy and Hebrew | [review-haiku.md](../review/review-haiku.md) rounds 1-3, [live-check-results.md](live-check-results.md) | **Yes**, on its round-3 conditions: F1-F13 applied by the lead; helper reinstalled with the zero-row fix. Open: the "Settings → Club Information" menu path is from Arbox's Zapier guide and is labelled unconfirmed everywhere it appears. |
| **Sonnet** (workhorse) | The `arbox` helper (72 tests, sh and dash, mutation-checked); plugin and marketplace vs the Claude Code docs; isolated install; arbox-api SKILL/setup/safety vs the helper | [review-sonnet.md](../review/review-sonnet.md) | **Yes** for the manifest, the local install and every helper command the skills quote (B1-B3 fixed by the lead). Not vouched until tested after the push: the hosted install from GitHub (A1). LIVE CHECK: `~` matching in permission rules (B5). |
| **Opus** (lead) | Every line of the three SKILL.md files, setup, safety, README, decisions; triggering and with/without evals; security read of the helper's key handling, write allowlist and output confinement; the owner one-minute start | [evals/results.md](../../evals/results.md), [decisions.md](../decisions.md), [lead-response.md](../review/lead-response.md) | **Yes** for v0.9.0 as a release candidate, after the post-push checks below pass. |

## Release gate (run after the push)

1. Hosted install in an isolated config: `claude plugin marketplace add romiluz13/arbox-agent-skills` + `claude plugin install arbox@arbox-agent-skills` succeed, three skills listed.
2. The owner one-minute start: a fresh Claude Code given only the sentence "Install the Arbox skills from https://github.com/romiluz13/arbox-agent-skills and then help me get started" runs the install commands and asks for `/reload-plugins`.
3. `npx skills@1.7.2 add romiluz13/arbox-agent-skills --list` lists the three skills.
4. Tag and release: `claude plugin tag . --dry-run`, then `claude plugin tag . --push` (creates `arbox--v0.9.0`), then the GitHub release from that tag.

Known limits shipped with v0.9.0: live numbers on a busy studio are unconfirmed (each recipe asks the owner to check one number first); Windows is untested; the directory listing name may be held for review.
