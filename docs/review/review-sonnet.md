# P1 review (sonnet): plugin vs the official Claude Code docs, and B04 vs the executor

Date: 2026-10-15. Claude Code under test: 2.1.300. Docs read (code.claude.com, fetched today): plugins/manifest-reference, plugins/marketplace-reference, plugins/create-marketplace, plugins/install, plugins/loading, plugins/host-marketplace, plugins/cli-reference, skills, permissions.

Method: fetched the docs; ran `claude plugin validate . --strict`; installed the plugin from the local folder in a **throwaway config** (`CLAUDE_CONFIG_DIR` and `HOME` pointed at a scratch folder; afterwards `claude plugin marketplace list` in the real config shows no `arbox-agent-skills`, so nothing leaked); tried the README install line against GitHub; re-read B04 against the executor line by line; fixed three small executor items.

Format: where / trigger / consequence / evidence / fix. Severity is my read: **High** = users hit it on day one, **Medium** = real but works around, **Low** = polish.

## Verdict in one paragraph

The plugin is structurally sound: strict validation passes on the marketplace and the manifest, the isolated install works (v0.9.0, 3 skills, 0 agents/hooks/MCP, about 680 tokens always-on), names and frontmatter obey the docs. Two things stop it from being "perfect": **the GitHub remote does not yet contain `.claude-plugin/`, so the README's first install line fails today**, and **nothing tells owners how updates arrive** (third-party marketplaces do not auto-update, and `plugin.json` pins the version). Everything else is small.

---

## A. Plugin and marketplace audit

### A1 (High): the README install line fails because the remote has no manifest
- **Where:** `README.md` Quickstart; GitHub `romiluz13/arbox-agent-skills` `main`.
- **Trigger:** anyone runs `/plugin install arbox --marketplace romiluz13/arbox-agent-skills`.
- **Consequence:** `Failed to add marketplace: Marketplace file not found at …/.claude-plugin/marketplace.json`. The first thing a new owner types fails.
- **Evidence:** isolated config, `claude plugin install arbox --marketplace romiluz13/arbox-agent-skills` gave exactly that error. `curl` on raw.githubusercontent.com: `.claude-plugin/marketplace.json` 404, `.claude-plugin/plugin.json` 404, `README.md` 200. Locally `git ls-files .claude-plugin` lists both files, and `git status` shows many uncommitted changes, so this is "not pushed yet", not "not committed".
- **Fix:** push (the lead or user decides when). Then repeat the isolated install against the remote; that is the only way to test the copied-into-cache path (my local install loads the folder in place, see A9). I did not push or commit.

### A2 (Medium): updates will not reach owners unless someone does something
- **Where:** README (no Updating section); `plugin.json` `"version": "0.9.0"`.
- **Trigger:** a fix ships after owners installed.
- **Consequence:** (1) Auto-update is **off by default for third-party marketplaces** (only official and claude.ai marketplaces default on). (2) With `version` set in `plugin.json`, users keep the cached copy "until the string changes, however many commits you push". A push without a version bump reaches nobody, even with auto-update on. (3) Even after the plugin updates, `~/.arbox/bin/arbox` is a separate copy; it only refreshes when an agent runs `install`.
- **Evidence:** install.md "Keep plugins updated"; loading.md "How Claude Code computes the version" (manifest `version` wins, then entry `version`, then commit SHA); host-marketplace "Release a new version": "If you set "version": "1.0.0" and push new commits without changing it, users don't receive them."
- **Fix:** (a) every release bumps `plugin.json` `version` (keep it only there; the docs say do not set it in both places; `claude plugin validate` warns on a mismatch). (b) Add a short README "Updating" section: `claude plugin update arbox@arbox-agent-skills` then `/reload-plugins`, or `/plugin` → Marketplaces → arbox-agent-skills → **Enable auto-update**. (c) The skill already re-runs `install` when versions differ (SKILL.md §1) and `doctor` now prints `installed copy: … OLDER than this copy`; keep that wording in the changelog template ("run any Arbox request once; the helper refreshes itself").

### A3 (Medium): release tags should follow `claude plugin tag`
- **Where:** `tools/validate.py`, CI, CHANGELOG, README (pin example).
- **Trigger:** cutting v0.9.0.
- **Consequence:** `claude plugin tag` creates annotated tags named `<name>--v<version>` (here `arbox--v0.9.0`) and refuses to tag if `plugin.json` and the marketplace entry disagree on version or the tree is dirty. If we hand-make `v0.9.0`, tools that resolve `<plugin>--v<version>` (dependency version ranges) will not see it, and the README pin example must match whatever tag exists. The lead-response promised a "tag == version" check; I found none in `tools/validate.py`, the CI workflow, CONTRIBUTING or the CHANGELOG (`grep tag` finds nothing).
- **Evidence:** cli-reference "plugin tag"; grep above.
- **Fix:** release with `claude plugin tag . --push` (dry-run first with `--dry-run`); pin example for cautious owners: `/plugin marketplace add romiluz13/arbox-agent-skills#arbox--v0.9.0`; optionally add a CI step `claude plugin tag . --dry-run` or a three-line check that `plugin.json` version equals the CHANGELOG top entry.

### A4 (Medium): skills are namespaced and the README never says so
- **Where:** README, `arbox-guide` first-contact text, CONTRIBUTING.
- **Trigger:** an owner types `/` to find the skill, or a developer wants to force one.
- **Consequence:** As a plugin the skills are `/arbox:arbox-guide`, `/arbox:arbox-api`, `/arbox:arbox-recipes` (plugin name, colon, skill name). Through `npx skills add` they are plain `/arbox-guide` and so on. Owners mostly talk in sentences and the skills auto-trigger, so this is not blocking; developers and the "I typed the wrong thing" case need one line.
- **Evidence:** skills page "Plugin skill namespacing"; create-marketplace walkthrough (`/my-first-plugin:hello`); `grep "arbox:arbox"` over README, skills and docs finds nothing.
- **Fix:** one README line under Quickstart: "Skills show up as `/arbox:arbox-guide`, `/arbox:arbox-api` and `/arbox:arbox-recipes`; you rarely need them, just talk." Do **not** rename the skills to `guide`/`api`/`recipes`: the `npx skills` channel has no plugin prefix, so `arbox-*` names keep them unambiguous there.

### A5 (Medium): the install line needs two clarifications
- **Where:** README Quickstart.
- **Trigger:** owner pastes `/plugin install arbox --marketplace …`.
- **Consequence:** In a session this "doesn't install right away: it opens the `/plugin` panel on that plugin's details so you can review it and choose a scope first" and asks the owner to pick user, project or local scope; for an owner who expects a one-liner this is a surprise stall. Also the shell form (`claude plugin install … --marketplace …`) needs Claude Code **2.1.292+**, while the in-session form needs **2.1.275+**; the README only states the second threshold.
- **Evidence:** install.md "Install a plugin", "Add a marketplace and install in one command".
- **Fix:** add: "Claude shows the plugin's details; choose **Install for you (user scope)**." and, for scripts, `claude plugin install arbox --marketplace romiluz13/arbox-agent-skills` (2.1.292+). The two-step fallback in the README (`/plugin marketplace add …` then `/plugin install arbox@arbox-agent-skills`) is correct as written.

### A6 (Low): marketplace entry lacked search metadata; plugin keywords were English-only
- **Where:** `.claude-plugin/marketplace.json`, `plugin.json`.
- **Fix applied:** entry gets `"category": "business"` and `"tags"` (free-form, used for search in `/plugin`); `plugin.json` keywords add `reports`, `hebrew`, `israel`, `ארבוקס`. Strict validation still passes on both files and on the repo root.

### A7 (Low): manifest fields we do not use, and whether we should
| Field | Verdict |
|---|---|
| `author`, `homepage`, `repository`, `license`, `keywords`, `description`, `version` | Present and correct. |
| `$schema` (both files) | Accepted, ignored at load; useful only for editor autocomplete. The docs I fetched do not print the schema URL, so I did not invent one. Add only if the lead has the URL. |
| `displayName` | Optional UI label; `arbox` is already readable. Skip. |
| `icon`, `documentationUrl`, `supportUrl`, `privacyPolicyUrl`, `termsOfServiceUrl` | Read only by Anthropic's directory when you **submit** there; Claude Code ignores them. `validate` accepts them on 2.1.281+ and warns on older versions (a `--strict` CI on an old Claude Code would fail). Add at submission time; the README Privacy section is the natural privacy URL. |
| `defaultEnabled`, `dependencies`, `userConfig`, `settings`, `hooks`, `mcpServers`, `agents`, `commands` | Not needed. `userConfig` with `sensitive: true` stores a value in the OS credential store, but it reaches only MCP/hook config and hook env, not skill text or our `sh` helper, so it cannot replace `~/.arbox/profiles` today. |
| Marketplace `metadata.description` vs top-level `description` | Docs call `metadata.description` the "alternate location"; strict validation passes with it. Fine. |
| Marketplace `strict`, `version` on the entry | Leave `strict` default; do **not** add `version` to the entry (plugin.json wins and `validate` warns). |
| Marketplace `source: "./"` | Accepted (`"."` means the root); validated and installed. |

### A8 (Low): features a top plugin could use that we do not (all optional, each needs a LIVE CHECK)
1. **`allowed-tools` in `arbox-api` / `arbox-recipes` frontmatter** (e.g. `Bash(~/.arbox/bin/arbox read *) Bash(~/.arbox/bin/arbox doctor *)`): pre-approves reads while the skill runs, so owners would not have to edit `settings.json` at all. Writes would still hit the `ask` rule (order is deny, ask, allow). The key is allowed outside Claude Code too (it is one of the six keys other surfaces accept). LIVE CHECK: that a `~/` Bash pattern in a skill's `allowed-tools` is honored, and that "ask" beats it.
2. **`${CLAUDE_PLUGIN_ROOT}` inside SKILL.md**: the docs say it is substituted inline in skill content, so the install line could read `sh "${CLAUDE_PLUGIN_ROOT}/skills/arbox-api/scripts/arbox" install` for Claude Code and `<skill-dir>` stays for other agents. Removes the "where is the skill folder" guess. LIVE CHECK substitution from a plugin skill.
3. **Plugin `bin/`**: executables there are on the Bash tool's PATH while the plugin is enabled. We deliberately install to `~/.arbox/bin/arbox` (stable path for permission rules, works in every agent), so I would not change this; noting it so nobody "discovers" it later and breaks the rule paths. (claude.ai and Cowork refuse a plugin with a top-level `bin/`.)
4. **`compatibility` frontmatter** (≤500 chars, accepted): "Needs POSIX sh and curl; macOS recommended". Nice for the npx channel.
5. **`claude plugin details arbox`** reports "Always-on ~678 tokens" (arbox-api ~240, arbox-guide ~230, arbox-recipes ~220; on-invoke 1.8k to 2.8k). That is a citable number for the README ("costs about 700 tokens per session").
6. **`claude plugin eval`** and an `evals/` folder: the docs describe plugin evals; our `evals/` is our own format. Out of scope for v1.

### A9 (info): what the isolated install proved and did not
- Proved: `claude plugin marketplace add <folder>` then `claude plugin install arbox@arbox-agent-skills` succeed; `claude plugin list` shows `arbox@arbox-agent-skills`, Version 0.9.0, Scope user, enabled; `claude plugin details arbox` shows Skills (3): arbox-api, arbox-guide, arbox-recipes.
- Not proved: (a) install from the hosted GitHub source (blocked by A1); (b) the copy-into-cache path (a folder marketplace loads **in place**, "Source: Folder"); (c) skill triggering in a live session (needs a model call; the lead's eval runs cover it); (d) auto-update behavior; (e) Windows.
- Limits of my isolation: I used `CLAUDE_CONFIG_DIR` plus `HOME`. The built-in "anthropic-plugin-directory" marketplace appeared in the scratch config; nothing else was touched.

### A10 (verified OK, no action)
- Names: plugin `arbox`, marketplace `arbox-agent-skills`: not reserved, not impersonating, valid characters (strict validation passes).
- Layout: `.claude-plugin/{plugin,marketplace}.json` at root, `skills/<name>/SKILL.md` in the default location, nothing else inside `.claude-plugin/`. No `CLAUDE.md` at the plugin root (the docs say it is not loaded and validate warns).
- SKILL frontmatter: only `name`, `description`, `license`, `metadata`; descriptions are 932, 881 and 844 characters, under the 1,536-character listing cap; SKILL.md bodies are 135, 151 and 71 lines (limit advice: under 500). `license` and `metadata` are accepted and ignored by Claude Code, and are among the six keys other surfaces allow, so the files also upload to claude.ai without errors.
- Install commands: in-session one-step (2.1.275+), two-step fallback, `npx skills add` for other agents: all consistent with the docs.

---

## B. Review of B04 against the executor

Checked every command, flag, message and exit code that SKILL.md, `references/setup.md` and `references/safety.md` quote, against `skills/arbox-api/scripts/arbox` at 0.9.0. **Verified present and correct:** `install`, `doctor`, `doctor --online`, `--version`, `setup --prompt`, `setup <name> --prompt`, `setup --open`, `read … --all --out`, `read --demo`, `write POST … --body-file … --yes-i-confirmed`, `-p <name>`; exit codes 3, 4, 5; the seven allowed writes and their exact paths; `--out` limited to `~/Arbox/`; 500 per page and the 20-page cap with `INCOMPLETE`; the `confirm` refusal on `entryFromWaitingList`; activity log path and "no key"; the quoted message "contains unexpected characters (spaces or quotes?)"; the R2 refusals (messages, bookings, cancellations, trial bookings, `PATCH /v3/schedule`); `--yes-i-confirmed` described as a record, not a gate. The `ask`-before-`allow` precedence and the claim that `Read`/`Edit` deny rules also stop `cat`/`head`/`tail`/`sed` on that path are both in the permissions docs.

Findings (nothing in B04 is dangerous; these are accuracy and completeness):

### B1 (Medium): "any read works with `--demo`" is not true
- **Where:** SKILL.md §2, "Not ready to connect?".
- **Trigger:** owner without a key; agent runs `--demo` on a path with no fixture.
- **Consequence:** exit 4, "There is no sample data for /v3/… in demo mode." Only 26 fixtures exist (`assets/demo/v3__*.json`). An agent following the sentence literally promises more than it can show.
- **Evidence:** `demo_dir`/`serve_demo` in the executor; test "demo: page above 1 is empty, a missing fixture is exit 4".
- **Fix:** "any read of the sample studio works with `--demo` (locations, users, schedule, leads, tasks, membership types and the reports the recipes use); other paths say there is no sample data."

### B2 (Medium): `--all` without jq does not produce the file the skill tells you to read
- **Where:** SKILL.md §5 "Pagination" and the `--out ~/Arbox/work/users.json` example.
- **Trigger:** owner's computer has no jq (doctor lists jq as optional).
- **Consequence:** the helper then refuses `--all` without `--out`, and with `--out FILE` writes `FILE.page-1.json`, `FILE.page-2.json`… plus `FILE.manifest.txt`, but **no `FILE` itself**. An agent that then reads `users.json` finds nothing and may retry or improvise.
- **Evidence:** `fetch_all` non-jq branch; test "--all without jq writes page files plus a manifest and says so".
- **Fix:** one sentence in §5: "Without jq the pages are not merged: read `<file>.manifest.txt` and the `<file>.page-N.json` files it lists. `doctor` shows whether jq is installed."

### B3 (Medium): setup.md step 3 and the `--open` fallback miss the new key-shape messages
- **Where:** setup.md "Step 3" bullet list and "Fallback" under Step 2.
- **Trigger:** owner pastes with a label or a space, or TextEdit saves as Rich Text.
- **Consequence:** the executor now says "The key for profile 'x' has spaces inside it. Copy only the key…" and "…was saved as a Rich Text file by TextEdit… choose Format > Make Plain Text…"; `doctor` lists "key has spaces inside it (copy only the key)" or "file was saved as Rich Text (open it in TextEdit, Format > Make Plain Text)". setup.md only knows "unexpected characters". The fallback text says "with no spaces or quotes" but the executor now strips surrounding spaces and straight/curly quotes itself; Rich Text is the real hazard of the TextEdit path.
- **Evidence:** `check_key_shape`, `profile_state`; tests "keys are sanitized…" and "keys with inner spaces and RTF files…".
- **Fix:** add two bullets to Step 3 for those messages, and in the fallback: "If TextEdit looks formatted, choose Format → Make Plain Text before saving; paste only the key."

### B4 (Low): deny rules are narrower than the lead addendum asked
- **Where:** SKILL.md §3 JSON: `deny` has `Read(~/.arbox/profiles)` and `Edit(~/.arbox/profiles)` only. B04 addendum 3 listed `Read(~/.arbox/**)` and `Edit(~/.arbox/**)`.
- **Consequence:** the profiles file is covered, but nothing stops an agent editing `~/.arbox/bin/arbox` (the executor, i.e. the real policy gate). The consultant flagged executor tampering (docs/review/consult-security.md §2.5).
- **Evidence:** permissions doc: `Edit` rules cover all built-in editing tools; `~/path` is home-relative.
- **Fix:** add `"Edit(~/.arbox/**)"` (and keep `Read(~/.arbox/profiles)`; a blanket `Read(~/.arbox/**)` would also block reading the sample data and is not needed). Mark the rule syntax LIVE CHECK as before.

### B5 (Low): permission rules match command text, so the exact spelling matters (the skill already says so)
- **Where:** SKILL.md §1 bold sentence and §3. Documented to be right: rules match the typed text (`Bash(curl *)` does not match `/usr/bin/curl`); `Bash(x *)` also matches bare `x`; the `:*` form is equivalent. So `~/.arbox/bin/arbox read *` matches `~/.arbox/bin/arbox read /v3/x …` and not `/Users/me/.arbox/bin/arbox read …`.
- **Residual risk:** whether the harness compares the literal `~/…` text rather than the expanded path is not stated in the docs. **LIVE CHECK** on a real session (a prompt for `~/.arbox/bin/arbox read` after adding the rule means it did not match). Say "unverified" in setup if it cannot be tested before release.

### B6 (Low): text polish and gaps
- SKILL.md §2 step 2 says "If they can't find it" twice in consecutive sentences; merge.
- The helper prints `tip: run 'sh <path> install' once…` on stderr when run from the plugin folder. SKILL.md §1 already says to install first; add "if you ever see that tip line, run the install command it prints".
- `~/.arbox/bin/arbox profiles` exists but is not mentioned; fine (doctor covers it).
- safety.md's "more than 20 records in one batch: split it" is policy for the agent; the executor has no cap (consultant N8, deferred). Say so if a reviewer asks.

---

## C. Executor changes I made (P1 task items)

All test-first; `sh tests/run.sh` and `TEST_SH=dash` runs recorded in the Return of `.team/tasks/P1.md`.
1. **`doctor --online` location names:** names were printed as raw JSON escapes (`ס…`). Now decoded (Hebrew, accents, emoji surrogate pairs, `\"`, `\\`, `\/`) with a small awk decoder that works with or without jq (one code path, so the no-jq machine gets the same output). Fake server gained a `heb-*` key that answers like PHP's `json_encode`. Test: "doctor --online shows Hebrew and emoji location names as text, with and without jq".
2. **Setup hint text (lead amendment 1):** every "no key / not filled in / profiles empty / doctor NOT READY / 401-403" hint now reads `Run: ~/.arbox/bin/arbox setup --prompt (in a new Terminal tab)`; for a named profile `setup <name> --prompt`. Tests updated to the exact wording.
3. **Zero-row `--all` (lead amendment 2):** no page with rows now writes `{"statusCode":200,"data":[],"extra":[]}` and prints `Saved 0 rows to FILE` (with jq, without jq, and printed to stdout without `--out`); no manifest or empty file. Test: "--all with zero rows writes an empty envelope…".
4. **Plain 404:** `{"statusCode":404,"error":{…},"data":null}` now gets the first line "Arbox could not find that (HTTP 404). The address or an id in it may be wrong, or the record may be gone." followed by the usual "Arbox said: …". Test: "HTTP 404 with a JSON error body: the first line stays plain English".
5. **Manifests:** A6 above. Nothing else under `.claude-plugin/` changed.

## D. What I did not do
- No commit, no push, no edits to B04 files, README, or Haiku's references (listed above for the lead).
- No live Arbox calls; no model-driven skill trigger test in a real session.

## Vouch

I vouch that, as of today, the plugin manifest and marketplace pass `claude plugin validate --strict`, install and enable cleanly from a local folder on Claude Code 2.1.300 in an isolated config, and that every executor command, flag and exit code quoted in B04 exists and behaves as described except the three accuracy gaps B1, B2 and B3. I do **not** vouch for the hosted install path until A1 is fixed and re-tested, for the permission-rule `~` matching (B5, LIVE CHECK), or for anything involving a real Arbox account.
