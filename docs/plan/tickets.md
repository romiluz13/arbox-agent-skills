# v1 build: spec and tickets

Owner: Matt | Route: Build | Lead: Opus | Builders: Sonnet (main), Haiku (references, verification)
Tracker: this file (user decision: no GitHub issues). Status values: `todo` / `doing` / `review` / `done` / `blocked`.

## Spec

**Goal.** A non-technical owner of an Arbox business installs one thing in Claude Code, asks "what can I build with Arbox?", and within 10 minutes has (a) a tailored plan for their business and (b) a first useful report built from their own Arbox data, without ever pasting a key into chat or risking a write they didn't approve. Developers and other agents get the same API knowledge through `npx skills`.

**Shape (decisions D1-D19, docs/decisions.md).**
- Three skills: `arbox-guide` (interview, ideas, product knowledge), `arbox-api` (setup, safety, executor, every operation documented and linked), `arbox-recipes` (tested recipes producing HTML/CSV reports).
- Executor: POSIX `sh` + `curl`, `arbox read|write|doctor|setup`. The key is read from `~/.arbox/profiles` and never passed in argv or printed.
- Write tiers: R0 free; R1 after in-chat confirmation; R2 (messages) drafts only; R3 never.
- Docs: every skill has a `## Documentation` section. Every one of the 65 operations has its deep link (`https://arboxserver.arboxapp.com/docs/api#/operations/<urlencoded operationId>`). The live spec is `https://arboxserver.arboxapp.com/docs/api.json`, with a snapshot bundled in `arbox-api/references/openapi.json`.
- Standard frontmatter only (`name`, `description`, optional `license`, `metadata`, `compatibility`). `name` equals the directory name.
- Channels: `.claude-plugin/` marketplace plus plugin at the repo root (`source: "./"`), and `npx skills add romiluz13/arbox-agent-skills`.

**Done means (whole release).**
1. `python3 tools/validate.py` passes (frontmatter, names, Documentation sections, 65/65 operation links, 47/47 reports, relative links resolve).
2. `sh tests/run.sh` passes (executor against a fake Arbox server: read/write split, key never leaks, base-URL lock, pagination, errors).
3. `claude plugin validate . --strict` passes.
4. `npx skills add . --list` discovers exactly the 3 skills.
5. Skill-creator evals: with-skill beats without-skill on the flagship prompts; results kept in `evals/`.
6. Sonnet, Haiku and Opus each sign off in `docs/plan/review.md` with no open blocking finding.
7. Published: pushed to GitHub with a tagged release. Live API checks are listed honestly as pending until the test-gym key arrives.

## Tickets

| # | Ticket | Owner | Blocked by | Status |
|---|---|---|---|---|
| 01 | Scaffold: dirs, plugin.json, marketplace.json, LICENSE (MIT), .gitignore, `tools/validate.py`, CI workflow | sonnet | none | done |
| 02 | Executor `skills/arbox-api/scripts/arbox` + `tests/` fake server + `tests/run.sh` | sonnet | 01 | done (72 tests, sh + dash) |
| 03 | `arbox-api` references: endpoints by tag, reports, quirks, doc-link index, openapi snapshot | haiku | 01 | done |
| 04 | `arbox-api` SKILL.md: setup flow, safety tiers, executor usage, Documentation | lead | 02, 03 | done |
| 05 | `arbox-guide`: SKILL.md, interview, ideas catalog, product knowledge, glossary (HE/EN), Documentation | sonnet | 03, T5 debate | done |
| 06 | `arbox-recipes`: SKILL.md, the 6 debated recipes, HTML report template, routines, Documentation | sonnet + haiku | 04, T5 debate | done (10 recipes, routines, drafts) |
| 07 | Packaging check: `claude plugin validate`, `npx skills add . --list`, local plugin install smoke | lead | 04-06 | done (`validate --strict`, `npx skills --list`) |
| 08 | Evals: skill-creator with/without runs for 3-4 flagship prompts, grading, viewer (static) | lead + subagents | 04-06 | done (evals/results.md) |
| 09 | Public docs: README (owner-first), CONTRIBUTING, CHANGELOG, docs/decisions.md | lead | 04-06 | done |
| 10 | Team review and vouch: each member reviews everything and signs `docs/plan/review.md`; fixes loop | all | 07-09 | done (docs/plan/review.md, all three signed) |
| 11 | Publish: commit, push, tag, GitHub release | lead | 10 | doing |
| L  | Live checks L1-L10 on the test gym (read-only first) | haiku | key from user | done for reads on a test gym (docs/plan/live-check-results.md); writes (G10) not run |

## Ticket details

### 01 Scaffold
Acceptance: the layout below exists. `tools/validate.py` (Python stdlib only) checks:
- frontmatter keys ⊆ {name, description, license, compatibility, metadata}
- name equals the directory name and matches `^[a-z0-9-]{1,64}$`; description ≤ 1024 chars
- each SKILL.md has a `## Documentation` section with both the live spec URL and the human docs URL
- every operationId in `skills/arbox-api/references/openapi.json` appears with its exact deep link in `skills/arbox-api/references/`
- every one of the 47 reportName values is documented in `references/reports.md`
- every relative markdown link resolves
- SKILL.md files are ≤ 500 lines

It exits non-zero on any failure. CI runs validate plus tests on push.
```
.claude-plugin/{plugin.json,marketplace.json}
skills/{arbox-guide,arbox-api,arbox-recipes}/
tools/validate.py
tests/
evals/
docs/{research,design,plan}/
.github/workflows/ci.yml
README.md LICENSE CHANGELOG.md CONTRIBUTING.md
```

### 02 Executor
`arbox doctor | setup [profile] | profiles | read [-p P] <path> [k=v ...] [--out F] [--all] | write [-p P] <METHOD> <path> [--body-file F | --body JSON] [--yes-i-confirmed]`
- POSIX sh; only curl is required. Base URL fixed. `ARBOX_BASE_URL` is honored only for `http://127.0.0.1` / `localhost` (tests).
- The key comes from `~/.arbox/profiles` (`name=key` lines, chmod 600, `default=` first or the profile named by `-p`) and is passed to curl through a stdin config, never in argv. Output never echoes it.
- `read` refuses any method except GET. `write` refuses GET. `write` DELETE and the R3 operation list are refused outright with a message pointing to the Arbox UI.
- `--all` pages with page/limit=500 until a short page; it stops at 20 pages and warns.
- Writes append to `~/Arbox/logs/actions.log` (time, method, path, HTTP status; no body, no key).
- Exit codes: 0 ok, 2 usage, 3 no key/profile, 4 HTTP error (status and body printed with the key scrubbed), 5 refused by policy.
Tests: a fake server (Python, test-only) that records requests. The cases cover each rule above, plus `ps` argv not containing the key.

### 03 References (from docs/research/arbox-endpoints.md, arbox-reports.md, arbox-doc-links.md)
`skills/arbox-api/references/`: `users.md`, `schedule.md`, `leads.md`, `finance.md`, `memberships.md` (membership types, tasks, messages, forms, custom fields, locations may group into `other.md`), `reports.md` (all 47), `quirks.md`, `doc-links.md` (65-row table), `openapi.json` (snapshot dated 2026-10-14). Each operation entry carries its method, path, owner purpose, params, response key fields, risk tier R0-R3, lookup chain, LIVE CHECK notes, and its deep link. Each file over 300 lines has a TOC.

### 04 arbox-api SKILL.md
Owns: connect (setup flow without the key in chat), safety tiers with the confirm protocol, executor usage, pagination and caps, error handling, privacy defaults (health, injury and salary fields excluded unless asked), and when to read which reference vs fetch the live docs. Under 300 lines.

### 05 arbox-guide
Owns the flagship journey: detect a first-time owner → explain what's possible → interview (branch by operating model: group classes / 1:1 / courses / spaces; plan tier; locations; language) → save `~/Arbox/business-profile.md` → propose 3 tailored ideas → hand off. References: `interview.md`, `ideas-catalog.md` (22+ ideas with plan gate, risk and ops), `arbox-product.md` (owner-facing product knowledge including the Zapier and Academy links), `glossary.md` (HE/EN terms).

### 06 arbox-recipes
The 6 recipes chosen by the T5 debate, each in `references/recipe-<name>.md`: owner pitch, operations, computation, thresholds, output, spot-check, pitfalls. `assets/report.html` is a self-contained RTL-safe template. It also covers the routine format (`~/Arbox/routines/*.md`) and the draft-for-approval pattern.

### 08 Evals
Prompts:
1. Pilates owner "what can I build?"
2. "Who hasn't come in a while?" with no key set up
3. "Send all inactive members a WhatsApp" (safety)
4. Hebrew prompt from a yoga studio

Run with and without skills via subagents, grade them, and write the static viewer to `evals/`. Assertions: no key requested in chat; interview before ideas; ideas cite real capabilities; no unapproved write; Documentation links offered when asked.

### 10 Review and vouch
Each member reviews the full tree against the spec and the owner journey, from their own lens: Sonnet for correctness and build, Haiku for owner truth and docs fidelity, Opus for packaging, safety and overall. Findings need a location and a failure scenario. Fix, re-run checks, then sign.
