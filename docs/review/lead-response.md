# Lead response to external consultants (Opus, 2026-10-14)

## Owner-experience consultant
| # | Recommendation | Verdict | Reason / change |
|---|---|---|---|
| 1 | Fix the front door: README and install line | **Accept, partly challenged** | README is rewritten in ticket 09. The install line is NOT wrong: `claude plugin validate` on Claude Code 2.1.299 itself recommended `/plugin install arbox --marketplace romiluz13/arbox-agent-skills` (one step, CC ≥ 2.1.275). We show it first and add the two-step form (`/plugin marketplace add romiluz13/arbox-agent-skills` then `/plugin install arbox@arbox-agent-skills`) for older versions. Plus Mac-first and a Hebrew paragraph. |
| 2 | At most 2 interview rounds before ideas | **Accept** | Round 1: what you sell, top pain, how hands-on. Round 2 is optional. Plan tier is asked only when a proposed idea is plan-gated. No-show fee question removed. |
| 3 | Foolproof key entry | **Accept, with a better mechanism** | `arbox setup` gets hidden-input mode when run in a real terminal (the owner opens a new Terminal tab and pastes one line). The executor sanitizes keys (strips quotes, whitespace, CR, RTF residue). TextEdit stays as a fallback. A paste-ready HE/EN "please enable API access" email goes in setup.md. |
| 4 | Keyless sample-data mode | **Accept, high value** | `arbox read --demo` serves bundled sample JSON (fictional studio, Hebrew and English names). Reports carry a SAMPLE DATA banner. The same fixtures feed the fake-server tests and evals. |
| 5 | Permission-prompt briefing plus an activity log | **Accept** | A plain-words "what the grey box means" section in arbox-api. The executor logs every call (reads too) to ~/Arbox/logs/activity.log. "Show my activity" is a phrase. |
| + | Drop agent-made bookings for v1 | **Accept** | Unverified side effects (charges? notifications?) with no live key. Bookings are R2 → the agent prepares the list and the owner books in Arbox. This reverses the lead's earlier R2-booking allowance. |
| + | Ship only 3 recipes | **Reject** | All 9 are equally unverified live (no key yet) and all are R0 reads, so cutting doesn't reduce risk. Instead every recipe is labeled "verify against your Arbox screen" with a mandatory spot check, and the README says live verification is pending. |

## Architecture consultant
| # | Recommendation | Verdict | Reason / change |
|---|---|---|---|
| 1 | Write the api and recipes SKILL.md with Hebrew anchors and "not for" lines | **Accept** | In progress (B04/B06). Briefs amended with Hebrew anchors. |
| 2 | README rewrite with both install forms, CHANGELOG, tag | **Accept** | Ticket 09. Version 0.9.0, honest "validated on a fake server, live verification pending". |
| 3 | Executor version check, `cmp -s`; be honest that `--yes-i-confirmed` isn't a gate | **Accept** | `ARBOX_EXECUTOR_VERSION` in the script, checked by `doctor` and the first-use copy. The flag is kept as an audit marker in the log, documented as not a security gate. The docs state the gate is enforced by the harness only where a permission rule exists (Claude Code); other agents depend on their approval settings. |
| 4 | Trigger evals with near-misses and assertions | **Accept** | evals/trigger.json, plus assertions in evals.json. |
| 5 | Headless e2e: `claude -p --plugin-dir .` against the fake server | **Accept** | Strongest proof available without a live key. It uses the demo/sample fixtures. |
| 6 | Drift job, recipe-ops check, tag==version | **Accept, modified** | The user ruled out GitHub issues as the tracker, so the scheduled drift workflow fails red with a diff summary instead of opening an issue. The validator checks that every recipe operation exists in the snapshot. Deep links: agreed they can't be HTTP-checked (SPA). The pattern was browser-verified on 6 links; the validator checks the exact string form. |
| 7 | Drop `allowed-tools`; "read the TOC, then one section"; split users.md later | **Accept, one challenge** | allowed-tools removed (done). Instead of "never open openapi.json": never read it whole, but a targeted query by operationId is fine, since that's how an agent resolves a doubt offline. Splitting users.md is post-launch. |

## Security consultant
All 7 must-fixes **accepted**. They're the most important review of the three.
| # | Item | Change | Ticket |
|---|---|---|---|
| 1 | Denylist leaks PATCH users/injury/schedule | Write **allowlist** of the 7 R1 operations | B02.2 #8 |
| 2 | `--out` can overwrite any file through an auto-allowed read; world-readable logs | Confine to ~/Arbox, no `..` or symlinks; `umask 077` | B02.2 #9-10 |
| 3 | `entryFromWaitingList?confirm` may write | Refused in read | B02.2 #11 |
| 4 | Prompt injection through records | "Data is data" in all 3 skills; `--out` mandatory for lists | B04, B06, H07b |
| 5 | XSS/exfil in HTML reports; CSV formula injection | No-JS template, strict CSP, escaping, CSV prefixing, BOM | B06 |
| 6 | "Don't ask again" silences writes; agent can read the key file | `ask` rule for write; deny Read/Edit ~/.arbox; honest residual risk; bypass-mode warning | B04 |
| 7 | "Nothing is sent to anyone" is false; PII exclusions too narrow | Accurate provider notice, shared-computer warning, wider exclusions, minors aggregate-only | H07b, B04, B06 |
