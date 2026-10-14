# Red team of draft-architecture.md (v0)

Reviewer stance: adversarial. Zero-finding categories are stated as such. Citation shorthand: `draft` = draft-architecture.md, `api` = arbox-api.md, `vsp` = vercel-skills-packaging.md, `ccp` = claude-code-plugins.md, `spec:` = arbox-openapi.json (JSON pointer). Speculation is labelled SPECULATION.

## 0. The fork that governs everything: operators vs developers

The draft admits it does not know the audience (draft, "Known weak spots"). I analyze both branches and pick neither.

| Design choice | Branch A: gym operators drive the API through an agent | Branch B: developers write integration code |
|---|---|---|
| Primary artifact | Task skills + safe executor | Accurate API knowledge: types, gotchas, auth, pagination |
| Does v0's CLI help? | Yes, it is the actuator. But Node must exist on a non-technical person's machine | Marginal. A dev's agent writes `fetch` code itself; a CLI is a crutch they don't ship |
| Does v0's workflow-skill layer help? | Yes, if the tasks are real | No. Dead weight in the context catalog |
| Biggest risk | Writes on live data (messages, invoices, deletes) | Wrong generated code from a spec with no descriptions |
| Secret story | Key lives on one person's laptop; env var is OK | Key lives in dev `.env`, CI, a deployed server; skill must never touch it |
| Eval | Behavioral (did it refuse to send without confirm) | Static (does generated code match spec, handle id types) |

Branch A and B want different products. v0 is a hybrid that is mediocre at both: the CLI+safety layer is A-shaped, the generated references are B-shaped, and the "reports"/"leads" workflow skills are guesses for A.


---

## 1. Strongest alternative architectures

### Alt 1. MCP-first (Arbox MCP server, thin skills on top)

- Best case: The only documented secret route is MCP env: `userConfig` `sensitive: true` resolves into MCP `env` but is not exported to Bash or skill scripts (ccp, "Secrets"; GAP note). An MCP server is therefore the only way to keep the key out of the model context and out of shell history on Claude Code. It also gives per-tool permission prompts (Claude Code asks per `mcp__plugin_*` tool), so write gating is enforced by the harness and not by an `--yes` flag the model can type itself. Tool schemas carry types, so the ID-type drift (see 2.7) is fixed once in the server. Pagination, `api-key` header, `"0"/"1"` flag coercion and the `reportName` union are hidden behind tools.
- Cost: needs a running process per agent (stdio), MCP config is per-agent (no `npx skills` channel; skills CLI installs only SKILL.md trees, vsp section 2). 65 tools would bloat context unless trimmed (SPECULATION: 65 tool schemas is on the order of tens of thousands of tokens; measure). Not every agent in the `skills` CLI table supports MCP equally (UNVERIFIED).
- What decides it vs v0: (a) Does the owner need Claude Code only, or the whole `npx skills` agent list (vsp section 2 table)? MCP wins for a Claude-only operator audience. (b) Whether the secret leak model matters: if keys are in `.env` anyway, MCP's advantage shrinks. (c) Whether Arbox keys are location-scoped and low-privilege (api: open question 1). A narrowly scoped key weakens the case for MCP.

### Alt 2. One skill, no CLI: curl/fetch recipes plus curated references

- Best case: kills the generator, the Node dependency and the drift pipeline. A single `SKILL.md` (<500 lines per spec, vsp section 3) holds auth, pagination, id-type rules, safety rules; `references/` holds hand-written per-tag notes. The spec has no descriptions anyway (api, Odd things 1), so a generator can emit only signatures, not meaning; the value is in hand-written glossary and gotchas, which a human has to write regardless. Works in every agent that has a shell, and for developers it is actually the right artifact (Branch B).
- Cost: the agent composes curl each time, so the key is expanded into a command line (see 2.1), and quoting JSON bodies in zsh/bash/PowerShell is error-prone (SPECULATION, common failure mode, not measured here). No structural write gate.
- What decides it: a pilot. Give 10 representative tasks to an agent with only references and curl. If task success is within a few points of the CLI variant, the CLI is not earning its dependency.

### Alt 3. Codegen'd typed SDK/types skill (Branch B product)

- Best case: generate TypeScript types and a typed client from `spec:` with the known drift fixed in a normalization layer (string ids in responses, numbers in requests; api Odd things 4, 5, 6). The skill teaches the agent to import it and write integration code. Contract tests against the spec catch breakage. Distribute as an npm package plus a small skill that says "use this package".
- Cost: only useful if the audience writes code. For operators it is irrelevant and adds a toolchain.
- What decides it: Branch B being true. If the owner says "I want Claude to write my integration," this beats v0 outright.

### Alt 4. One skill per API tag (11 skills) mirroring `spec:/tags`

- Best case: the spec has 11 tags (Leads, Tasks, Membership Types, Users, Schedule, Custom Fields, Locations, Message, Reports, Digital Forms, Finance; `spec:/tags`) which are real units. Triggering is by noun ("lead", "invoice"), which is how users speak. No invented workflow layer.
- Cost: Users has 23 ops (api, counts), Reports is one endpoint hiding 46 reports (`spec:/components/schemas/ReportName`), so the tag boundary is uneven. 11 descriptions in the always-loaded catalog (about 100 tokens each, vsp section 3 progressive disclosure) is cheap. Cross-tag tasks (create member, sell membership, issue invoice) span three tags and need a coordinator, which is the core skill again.
- What decides it: task-frequency data from the owner. If 80% of use is 3 tags, ship 3 skills and leave the rest to references.

### Alt 5. Hybrid: core skill + read-only CLI, writes delegated to a confirmed channel

- Best case: ship the CLI as read-only (37 GETs), and make every write a printed, human-reviewable payload that the human (or the agent with explicit per-call approval via the harness permission system) executes. Removes the "model typed --yes" hole and halves the generated surface.
- Cost: slower for bulk operations; operators lose the automation they came for.
- What decides it: whether the owner values write automation more than write safety (Q3 below).

My strongest alternative: **Alt 2 for Branch B, Alt 1 (MCP-first with trimmed tools) for Branch A on Claude Code**. In both cases the CLI-as-key-carrier is the weak element of v0.

---

## 2. Attacks on v0

Severity: H = could harm real members or money or leak the key; M = degrades quality or maintenance; L = polish.

### 2.1 Secret handling (H)

Claim in draft: "Key comes from the `ARBOX_API_KEY` env var" and "userConfig secrets reach MCP env, but NOT Bash or skill scripts" (draft, Facts).

Failure scenarios:

1. **The documented secure channel does not feed v0's executor.** ccp says plainly: "GAP: no documented way for a sensitive key to reach a bundled skill script." So on the Claude plugin channel v0 offers no secure key path; the user must still export an env var by hand. The plugin packaging gives no secret benefit for the very thing the plugin is bundled for. The draft knows this (it defers MCP "if userConfig secret UX matters") but does not weigh that this makes the plugin channel strictly equal to the `npx skills` channel on secrets.
2. **Agent discovers the key by itself, copying the Vercel pattern.** `vercel-cli-with-tokens` documents discovery order: `printenv VERCEL_TOKEN`, then `grep '^VERCEL_TOKEN=' .env`, then `grep -i vercel .env` (vsp section 4). If v0 copies that "Auth by reuse" pattern (vsp, Patterns to steal 5), the `grep .env` step prints the key into the transcript, which is sent to the model provider and may be logged. Scenario: `.env` contains `ARBOX_API_KEY=...` plus DB passwords; the agent runs `cat .env` to find it; all secrets enter context. Mitigation to require: SKILL.md must say never read `.env`; CLI should read `.env` itself (not the agent), or only the process env.
3. **Key in argv.** The draft says env var, good, but if the CLI offers `--api-key` for convenience, it lands in shell history and `ps` (the Vercel skill's explicit rule "Never pass `--token` on the command line", vsp section 4). Alt 2's curl recipes make this worse: `curl -H "api-key: $ARBOX_API_KEY"` expands in the command string that the harness logs and shows (SPECULATION on harness logging details; command text is visible to the model and user at minimum).
4. **Error echo.** A generated CLI that prints the request on failure (`dry-run plan`, verbose mode) will print the `api-key` header. Dry-run output is returned to the model. Test: dry-run output must never contain the key.
5. **Key scope unknown.** How the key is obtained and what it can do is undocumented (api, Open question 1). `CreateDocumentRequest.location_id` "Defaults to the API user's location" (`spec:/components/schemas/CreateDocumentRequest/properties/location_id`), so a key is bound to a user and probably a location (inference). Multi-location gyms may need multiple keys; v0 has one env var. SPECULATION: the key is full-power for that location, so a leak means invoices, deletes and mass messages.

Where v0 is not wrong: choosing an env var over a CLI flag is the right default.

### 2.2 Write safety on live gym data (H)

1. **`--yes` is not a gate.** "Writes print a dry-run plan and need `--yes`" (draft, Safety). The same model that ran the dry-run can append `--yes` in the next call, or in the first. The user never sees it unless the harness prompts. A flag the actor controls is not authorization. The draft's second layer ("explicit user confirmation in the conversation") is prose in SKILL.md, which a model can misjudge (e.g., treat "go ahead and fix everyone's data" as confirmation for 400 messages).
2. **The dry run is client-side fiction.** The spec has no dry-run or validate mode and no documented idempotency (api, "No endpoint is documented as idempotent or as safe to retry"). The plan the CLI prints is only the request it would send; it cannot predict server effects such as whether `POST /v3/users/memberships` duplicates an existing membership (api, Open question 9).
3. **Bulk blast.** `SendMessageRequest.users_ids` is an array with no maxItems (`spec:/components/schemas/SendMessageRequest/properties/users_ids`; `message` and `subject` are nullable). One call can push or WhatsApp every member. Failure: "remind everyone with debt" resolved by a bad filter (e.g. `active` encoded wrong, see 2.7) hits all members. Required guard: cap recipients per call, require the recipient count and a sample in the confirmation, and require the final text verbatim.
4. **Finance documents are legally meaningful.** `FinanceDocumentType` includes `tax_invoice`, `tax_invoice_receipt`, `refund_invoice`, `receipt` (`spec:/components/schemas/FinanceDocumentType`). `POST /v3/finance/documents` with `email` set sends it to a customer. A wrongly issued tax invoice cannot be unissued (SPECULATION about Israeli tax-document rules: these are typically corrected with credit documents, not deleted. Verify with owner). Treat as never-without-human.
5. **Delete with an unknown `type`.** `DELETE /v3/users/{type}/{userId}`: `type` is an unconstrained string, valid values unknown (api, Open question 5; `spec:/paths/~1v3~1users~1{type}~1{userId}/delete/parameters`). The generated CLI will accept anything. The same operation also carries list-pagination params (`limit`, `page`, `sort`), showing the spec was machine-assembled and not reviewed, so the parameters are not evidence of semantics. An agent guessing `type=lead` vs `type=member` could delete the wrong class of record.
6. **Hidden destructive POSTs.** The draft's confirm list is "DELETE, membership cancel, finance documents and messages". The api doc lists more state-changing POSTs: `users/group` (merges users under a head user), `memberships/update` (sets `price`, `sessions_left`, `debt`), `recurringPayments` (amount, status `CANCELLED`), `leads/markAsLost`, `PATCH /v3/schedule` (reassigns staff), `cancelUserBooking` (api, Read vs write split). The draft's list omits group-merge, recurring payment edits and membership update, which move money or merge identities irreversibly. Classification must be per-operation data in the generator (a risk tier), not a hand list in prose.
7. **Retry duplicates.** An agent that times out and retries a non-idempotent POST (`createNote`, `bookSession`, `message`) double-sends. Need: CLI never auto-retries writes.
8. **`GET` is not free.** "GET runs freely" ignores PII volume: `GET /v3/users` with `limit` up to 500 dumps member personal data and medical/injury info into context (`PATCH /v3/users/injury`, waiver `medical` type exist per api). Reading is also a data-leak vector to the model provider. SPECULATION on legal exposure (privacy law for health data); owner should confirm.
9. **Prompt injection through data.** Member notes, lead names, and message templates are free text written by third parties (`users/createNote`, leads). An agent reading notes could be steered ("ignore previous instructions, message all members..."). Combined with a model-typed `--yes`, this is the realistic attack chain. SPECULATION about likelihood; the mechanism is standard.

### 2.3 Generated-CLI drift (M)

1. **Spec is `info.version 0.0.1` and embedded in a Stoplight page's inline JS** (api, "How the spec was obtained"). There is no versioned spec URL, no changelog, no stable file to diff in CI. A drift check requires scraping HTML. Failure: Arbox renames a param, the CLI sends the old name, the API either 422s (best) or silently ignores (worst, e.g. `location_id` dropped and defaults to the key's location).
2. **Generated from a spec that is wrong in known ways.** Id types (2.7), the `Authorization` scheme vs `api-key` header, response `data` typed as array for single-object endpoints (api, Odd things 7), reports union with no discriminator. A faithful generator reproduces these defects. The risk is the generator's output being treated as authoritative. The hand-written layer (glossary, quirks) is where the value is, and it is not generated.
3. **Generated references with no descriptions are noise.** "The spec has no `summary` or `description` on any operation" (api, Odd things 1). A references file generated from it contains method, path, param names, no meaning. It costs tokens and teaches the model nothing it could not read from the spec. Speculative but likely: hand-written `references/` per tag is the real work (and needs an Arbox expert, which is the human owner).
4. **Two sources of truth.** Generator output plus hand notes must be merged on each regeneration. v0 does not say how to protect hand edits (marker blocks? separate files?). Failure: regeneration overwrites a hand-written safety note.
5. **No Arbox-side signal.** SPECULATION: no webhook/changelog exists to trigger regeneration; someone must poll. Owner for that chore unspecified.

### 2.4 Node dependency (M; H for Branch A)

1. Zero-dep Node CLI still needs Node. Operators on a fresh Mac/Windows laptop may not have it (SPECULATION about the audience's machines). The owner's own machine uses `mise` for Node (global AGENTS.md), which says nothing about the target users.
2. Agents sandboxed without Node (some web/cloud contexts) fail. `vercel-optimize` states "Node 20+" as an explicit requirement (vsp section 4), so the precedent exists, but its audience is developers. Declare `compatibility` in frontmatter (spec field, vsp section 3).
3. A Node script plus `skills` CLI installs: the `skills` CLI copies the whole skill directory, so `scripts/arbox.mjs` is present, but path resolution is on the agent. Upstream hard-codes `/mnt/skills/user/...` and `~/.claude/skills/...` and calls it an anti-pattern (vsp, Anti-patterns 1). v0 must say how SKILL.md references the script portably ("relative to this skill's directory") and test it under at least `.claude/skills` and `.agents/skills` installs, symlink mode included (vsp section 2, symlink vs copy).
4. Workflow skills depending on the core skill's script: if the user installs only `arbox-leads` (`--skill arbox-leads`, vsp section 2 commands), the core's `scripts/arbox.mjs` does not exist. The `skills` CLI has no dependency resolution that I found (UNVERIFIED; no dependency mechanism appears in vsp). Cross-skill relative paths (`../arbox/scripts/arbox.mjs`) break under copy mode when only one skill is selected.
5. Python or plain shell would have the same issue in different clothes. Alt 2 (curl) avoids it for the price of 2.1.3.

### 2.5 Skill-trigger collisions (M)

1. **Core `arbox` vs `arbox-members`/`arbox-leads`/`arbox-schedule`/`arbox-reports`.** All descriptions contain "Arbox". On "show me yesterday's class bookings" the model may load core, a workflow skill, or both. Two skills each telling the model "how to run the CLI" produce conflicting instructions. The skill catalog shows name+description only (vsp section 3), so description wording is the only routing signal.
2. **Overlap by domain:** `arbox-members` vs `arbox-leads` (a lead becoming a member: `leads/converted`, `users/memberships`), `arbox-reports` vs finance GETs vs `GET /v3/reports/{reportName}` with 46 names. A request "how much revenue this month" hits reports (`revenueAnalysisReport`, `salesReport`) and finance reports (`cashFlow`, `sales`) with no documented difference (api, Odd things 2, 8).
3. **Auto-trigger is the wrong default for write skills.** Claude has `disable-model-invocation`, but ccp says Claude-only fields are rejected by claude.ai uploads and the Skills API, and the draft commits to standard-only frontmatter ("identical across channels"). So v0 cannot mark write-capable skills as manual-only without breaking its own cross-channel purity. Trade-off not acknowledged.
4. **Namespacing differs by channel.** In the plugin, skills appear as `/plugin:skill` (ccp), in `npx skills` as bare names. A user who installs both channels gets duplicate skills (SPECULATION: name collision handling across `~/.claude/skills` and plugin dir is unverified). Spec says project overrides user, with a warning (vsp section 3).
5. **Reserved names:** marketplace names `agent-skills`, `claude-*`, `anthropic-*` are reserved (ccp). `arbox-agent-skills` as a repo/marketplace name is fine, but check `claude plugin validate`.
6. Test needed: a trigger-eval set of near-miss prompts per skill (positive and negative), run against the full installed set, not each skill alone.

### 2.6 Eval strategy without a sandbox (H)

1. **The draft's own evals dir has a "fake Arbox server" for offline tests.** That is sensible, but the fake encodes our beliefs about the API (api has 11 open questions on semantics). The fake passes while production behaves differently. It verifies CLI mechanics and agent behavior, not API truth. State this limit in the eval report; do not claim "end-to-end tested".
2. **`claude plugin eval` makes real model calls with a no-plugin baseline** (ccp, Quality gates). It runs only Claude Code, so the cross-agent promise (`npx skills` for Codex, Cursor etc.) has zero eval coverage. The shared-folder property "identical across channels" is untested by anything in v0.
3. **Eval pointed at a real key.** If any eval or author "just checks one thing" against production, it triggers a real write. Guard: eval harness sets `ARBOX_BASE_URL` to the fake, and CLI refuses to send writes to the production host unless an explicit env flag is set (a code-level guard, not prose). This requires a base-URL override in the CLI, which the draft does not mention; note the override itself is a key-exfiltration vector if a prompt-injected agent sets it to an attacker host (SPECULATION, standard SSRF/credential-forwarding pattern). Restrict override to localhost.
4. **Is there a sandbox at all?** Unknown (draft: "No sandbox is known"). Ask Arbox / owner for a demo or test gym account. Many gym SaaS give a trial account (SPECULATION). A dedicated test location with a test key changes the entire eval plan.
5. **Eval of read-only paths is cheap and safe**; the risky ones are writes and messages. A reasonable split: live eval for GETs with a read-scoped key (if scopes exist, unknown), fake server for writes.
6. **Judge risk:** model-graded evals where the author wrote both the skill and the rubric agree with themselves (the exact bias this document is meant to counter). Prefer deterministic assertions: "no write call was made without the confirm token", "key never appears in transcript".

### 2.7 Spec defects: missing descriptions and id-type inconsistencies (M)

1. **No descriptions** (api, Odd things 1): the generator cannot produce semantic docs. Vocabulary (box, category, service, session, class) is undefined; `GET /v3/schedule/boxCategories` is named "Get Services" (`spec:/paths/~1v3~1schedule~1boxCategories/get/operationId`). An agent using the wrong noun picks the wrong endpoint. Must hand-write a glossary and confirm with the owner.
2. **Id types:** responses give ids as strings (`LeadsResource.user_id` etc.), requests as `number`/`integer` (api, Odd things 4; `spec:/components/schemas/SendMessageRequest/properties/users_ids/items` = number; `GroupUsersRequest` ids number). Failure: agent copies `"123"` from a response into `users_ids`, gets a 422 (best case) or coercion; or JS numeric precision loss if ids exceed 2^53 (SPECULATION, unlikely). The CLI must coerce, and the generator should emit a per-field coercion table. The draft is silent.
3. **Same entity, different id names:** `user_id` vs `membership_user_id` for the person (api, Odd things 6). `membership_user_id` is a membership record id in `GroupUsersRequest` (`spec:/components/schemas/GroupUsersRequest`). Mixing them merges the wrong things.
4. **Boolean zoo:** `"0"/"1"` strings, `yes/no`, JSON booleans, and `active` as boolean/number/string depending on op (api, Odd things 5). A CLI flag `--active true` must map per-operation. Unit tests per op.
5. **Date and param naming drift:** `fromDate`/`toDate` in reports vs `from_date`/`to_date` elsewhere (api, Odd things 6); 31-day cap documented on 4 finance GETs only (api, Pagination). The CLI should not hide the cap; either enforce or leave to the API error, and state which.
6. **Pagination without totals** (api, "Rate limits and pagination"): an agent cannot know when to stop except by an empty or short page. Failure: a loop that fetches until `data` empty with no rate-limit knowledge, hammering the API (no rate limit documented). Also "report completeness" claims ("you have 312 members") are unfounded if the agent stops at `limit=500` once. The CLI needs a documented `--all` with a page cap and the SKILL.md must say how to detect truncation.
7. **Error model:** only 200/422/404 declared; no 401/403/429 (`spec` responses scan: codes {200, 404, 422}). The CLI has no documented way to distinguish a bad key, a rate limit, or a server error. Do not generate retry logic based on imagined codes; log observed codes into references after manual probing.
8. **Duplicate names across path and query** (`reportName`, waiver `type`/`value`; api, Odd things 3). The generator may emit conflicting flags. Needs a manual override table.
9. **Ids in DELETE trial booking:** `DELETE /v3/schedule/booking/trial` takes `user_id` and `schedule_id` as query params with `force` (`spec:/paths/~1v3~1schedule~1booking~1trial/delete/parameters`). `force` semantics unknown (api, Destructive); a generated CLI will expose it as a plain flag.

### 2.8 Other attacks

1. **Four invented workflow skills** (draft, own admission "Workflow skills are invented"). Each skill added is catalog tokens on every session for every user, plus a maintenance and trigger-collision surface (2.5). Zero evidence for `arbox-reports` or `arbox-members` as units. Cut to the core skill plus whichever tasks the owner names.
2. **Two channels = two test matrices.** The packaging doc says the `skills` CLI reads `.claude-plugin/marketplace.json` (vsp section 2), so a relative source `"."` is plausible, but ccp says to confirm with `claude plugin validate`. Dual-channel with a plugin that has no bundled value (no hooks, no MCP, no commands; draft defers MCP) means the plugin channel is only a different install command. Plugin channel earns its keep only if it ships something the skills CLI cannot: MCP, hooks (e.g. a PreToolUse hook that blocks write commands without confirmation, which would solve 2.2.1 for Claude Code), or `bin/`.
3. **`tools/gen.mjs` validator duplicates** `skills-ref validate` (vsp section 3) and the Vercel index script rules (vsp section 1). Reuse before writing (note: `skills-ref` behavior is UNVERIFIED).
4. **No licensing / ToS check.** The spec was extracted from a vendor's docs page (api, "How the spec was obtained"). Redistributing the spec-derived references in a public repo may need Arbox's permission (SPECULATION; check ToS). Also trademark: naming the repo/skill "arbox" implies affiliation; ask whether Arbox endorses it.
5. **Instruction injection via references.** Hand-written reference content becomes trusted instructions loaded into the model. If the repo is public and accepts PRs, a malicious reference file is a supply-chain attack on every user's agent (the agentskills client guide itself says cloned skills are untrusted; vsp section 3, Trust). Needs a review policy, pinned releases, and the `skills` lock file hash (`skills-lock.json`, vsp section 2).

---

## 3. Where v0 is right

Honest list; I tried to break each and did not.

1. **Env var over flag/argv for the key** (draft, Execution). Matches the Vercel hardening rule (vsp section 4).
2. **Standard-only frontmatter, `name == dirname`, validated by a script** (draft, Proposal). Directly addresses the flagship upstream bug (vsp, Anti-patterns 2) and spec strictness variance (Anti-patterns 7). Keep. (The cost is 2.5.3 and is worth paying.)
3. **One repo serving both channels** is consistent with discovery logic in the `skills` CLI (it reads `.claude-plugin/marketplace.json` and `plugin.json`; vsp section 2) and with ccp (relative source `"."`). Plausible, pending `claude plugin validate`.
4. **Deferring MCP is a reasonable sequencing choice** given 65 ops and unknown audience. My objection is only that it is decided before the audience question, not that it is wrong.
5. **Safety posture exists at all.** Splitting reads from writes and listing money/messaging/delete as needing confirmation (draft, Safety) is aligned with the 28 writes in the spec. The structure is right; the enforcement (2.2.1) and the list's completeness (2.2.6) are the defects.
6. **Naming the weak spots explicitly** (draft, "Known weak spots"): audience, Node, invented workflows, no sandbox. All four are real; none are overstated.
7. **Progressive disclosure layout** (short SKILL.md, per-tag references one level deep) matches the spec and the `vercel-optimize` precedent (vsp, Patterns to steal 1). Keep.
8. **Offline fake server for evals** is the correct instinct, with the caveat in 2.6.1.
9. **Generating, rather than hand-typing, the 65-op surface** is sensible for the signature layer. My objection is only to treating generated output as documentation.
10. Categories with zero findings: none; every requested category had at least one substantive issue, but several (frontmatter strategy, env var choice, progressive disclosure) are confirmed correct above.

---

## 4. Questions only the human can answer (ranked by design impact)

1. **Who is the user: a gym operator (non-coder) asking an agent to do things, or a developer building an integration?** Impact: decides CLI vs curl vs SDK vs MCP, whether workflow skills exist at all, secret model, eval type. Recommended answer: pick operators as primary (SPECULATION: matches "gym-management API" framing and the fact that a skill with a safe executor is a bigger gap than "write fetch code", which models already do), and make the references good enough that developers get value for free. Why: the operator branch is the harder, riskier, more valuable one; the developer branch is a subset of its content.
2. **Is there a sandbox, demo gym or test location with its own API key, and what can a key do (scopes, location binding)?** Impact: eval design, write-safety design, whether live tests are allowed. Recommended answer: obtain a test location from Arbox support before building evals; if none exists, ship read-only CLI v1 and gate writes behind a human-run step (Alt 5). Why: without it, every write path is untested against reality (2.6) and a key leak may be unbounded (2.1.5).
3. **Which writes, if any, may the agent perform without a human clicking something?** Impact: whether v1 is read-only, whether we need a harness-level gate (PreToolUse hook or MCP permission) instead of `--yes`. Recommended answer: reads free; low-risk writes (notes, tasks, lead status) with in-conversation confirmation; messages, finance documents, deletes, group merges, recurring-payment and membership edits never agent-executed in v1 (print the payload for the human). Why: those are irreversible or touch money and third parties (2.2.3, 2.2.4, 2.2.6), and `--yes` is not a real gate (2.2.1).
4. **Which agents must be supported, in priority order?** Impact: MCP viability, hooks, plugin channel value, eval coverage (only Claude is eval-able, 2.6.2). Recommended answer: Claude Code first (daily driver per the environment context), others best-effort and labelled untested. Why: honest support claims beat an unverified "works in every agent".
5. **What are the 5 tasks you or your users actually do every week?** Impact: replaces the four invented workflow skills (2.8.1) and the per-tag reference priorities. Recommended answer: ship the core skill plus at most the 2-3 workflows named; delete the rest. Why: every extra skill is catalog tokens and a collision surface for no demonstrated demand.
6. **Is Node acceptable for the target users, and can a Python/shell/pre-built binary be allowed instead?** Impact: executor language, install friction. Recommended answer: if Q1 is operators, assume no Node and test it first; if Q1 is developers, Node is fine. Why: the Node assumption silently fails for non-technical users (2.4.1).
7. **Is the repo public, who may contribute, and does Arbox permit redistributing spec-derived content and the "Arbox" name?** Impact: supply-chain review process, licensing, naming. Recommended answer: public with CODEOWNERS-reviewed `references/` and tagged releases, after a short permission note to Arbox. Why: instruction files are executable-adjacent (2.8.5) and the spec came from a vendor page (2.8.4).
8. **Multi-location / multi-key setups: does one gym org have several location ids and keys?** Impact: config shape (single env var vs named profiles), `location_id` defaulting rules, which can silently target the wrong site. Recommended answer: support named profiles, never default `location_id` silently, always echo target location in write confirmations. Why: `location_id` is required in some bodies and defaults to the key's location in others (api, Conventions; `spec:` CreateDocumentRequest), a classic wrong-site write.
9. **Who owns spec-drift upkeep and how often?** Impact: whether generation is worth it or a hand-maintained reference is lighter. Recommended answer: monthly manual diff of the extracted spec, scripted extraction from the docs page, no automation promise. Why: no versioned spec endpoint exists (2.3.1); a promise of freshness we cannot keep is worse than none.
10. **Hebrew/RTL and localisation:** will message texts, member names and report labels be Hebrew? Impact: quoting and encoding in CLI args, message template handling, glossary language. SPECULATION: likely for an Israeli vendor (`arboxapp`), unverified. Recommended answer: ask; add Hebrew fixtures to the fake server and tests either way. Why: argv encoding and RTL text in confirmations are cheap to test early and expensive to retrofit.

---

## Bottom line

v0's skeleton (standard frontmatter, one repo, progressive disclosure, reads vs writes) survives. What does not survive: `--yes` as the write gate, the env-var-only secret story on the plugin channel (no benefit over plain skills), the unvalidated four workflow skills, and the assumption that a spec-generated reference is documentation. The audience answer (Q1) and the sandbox answer (Q2) should be obtained before any further architecture work.

---

## Lead response (Opus, 2026-10-14)

- Accepted: `--yes` is not a gate. The confirm list was incomplete (users/group, recurringPayments, memberships/update). The workflow skills were invented. The plugin channel adds no secret benefit for script-based skills. (Checked: SendMessageRequest.users_ids has no maxItems; FinanceDocumentType includes tax_invoice and refund_invoice.)
- Counter to 2.4 (Node): `npx skills` itself needs Node, so the agnostic install channel already assumes Node. The Node cost only applies to operators who would install through a Claude plugin without Node. That's a weaker attack than stated.
- Counter to Alt 1: MCP is also cross-agent (Cursor, Codex, Gemini CLI, and others speak it). So "MCP vs skills" isn't the same question as "agnostic vs Claude". The real tradeoff is install and secret ergonomics against transparency.
- New idea from the red team: a real gate can live at the command boundary. Split the executor into `arbox read ...` and `arbox write ...` so each agent's own permission system (Claude allowlist/hook, Codex approvals, Cursor command allowlist) can auto-allow reads and prompt on writes. The gate then sits with the harness, not the model.
