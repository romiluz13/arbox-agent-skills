# Vercel skills packaging: how it is distributed and what to reuse

Research date: 2026-10-14. Sources are primary only (GitHub repos, agentskills.io, local files).
Versions and commit dates are noted where visible. Anything not checked is marked UNVERIFIED.

Pinned sources at time of research:

| Source | Ref | Commit date |
| --- | --- | --- |
| https://github.com/vercel-labs/agent-skills (default `main`) | `063bee94c` | 2026-08-28 |
| https://github.com/vercel-labs/skills (the `skills` CLI, default `main`) | `13e4063a1` | 2026-10-09 |
| https://github.com/anthropics/skills (`main`) | `dbd4588f9` | 2026-10-09 |
| https://agentskills.io/specification (fetched via WebFetch) | no version shown | fetched 2026-10-14 |

---

## 1. vercel-labs/agent-skills: repo layout, frontmatter, tooling

Source: `gh api repos/vercel-labs/agent-skills/git/trees/main?recursive=1`, `README.md`, `AGENTS.md`, `CLAUDE.md`, `skills.sh.json`, `package.json`, `scripts/build-discovery-index.mjs` (all at `main`, 2026-08-28 snapshot). Stars at check time: 32,398.

### Directory tree (top level, trimmed)

```
agent-skills/
├── AGENTS.md                 # guidance for agents working IN this repo (CLAUDE.md is a byte-identical copy)
├── CLAUDE.md                 # same content as AGENTS.md
├── README.md                 # human install instructions
├── package.json              # private, type=module, only dep: yaml@2.9.0 (for the index script)
├── package-lock.json
├── skills.sh.json            # catalogue grouping for skills.sh (titles/descriptions per group)
├── scripts/
│   └── build-discovery-index.mjs
├── skills/
│   ├── composition-patterns/        SKILL.md, AGENTS.md, README.md, metadata.json, rules/*.md
│   ├── deploy-to-vercel/            SKILL.md, resources/{deploy.sh,deploy-codex.sh}
│   ├── react-best-practices/        SKILL.md, AGENTS.md, README.md, metadata.json, rules/*.md
│   ├── react-native-skills/         SKILL.md, AGENTS.md, README.md, metadata.json, rules/*.md
│   ├── react-view-transitions/      (dir; zip sibling present)
│   ├── vercel-cli-with-tokens/      SKILL.md
│   ├── vercel-optimize/             SKILL.md, AGENTS.md, CONTRIBUTING.md, README.md, metadata.json,
│   │                                lib/, references/, scripts/*.mjs (15 scripts)
│   ├── web-design-guidelines/       (dir; zip sibling present)
│   ├── writing-guidelines/          (dir)
│   └── *.zip                        (deploy-to-vercel.zip, react-best-practices.zip, ...) prebuilt archives
└── packages/
    ├── react-best-practices-build/  TypeScript build that generates rules/ from a source
    └── vercel-optimize-tests/       node:test suite (~80 *.test.mjs files + fixtures)
```

Tree source: `gh api .../git/trees/main?recursive=1` (445+ blobs). `.github/workflows` returned 404 via the contents API, so CI config is UNVERIFIED.

### Frontmatter used in the upstream SKILL.md files

Verified via `gh api -H 'Accept: application/vnd.github.raw' repos/vercel-labs/agent-skills/contents/skills/<name>/SKILL.md`.

`skills/deploy-to-vercel/SKILL.md` (commit `aed32ad76`, 2026-03-06 "Improved deploy to Vercel skill (#149)"):
```yaml
---
name: deploy-to-vercel
description: Deploy applications and websites to Vercel. Use when the user requests deployment actions like "deploy my app", "deploy and give me the link", "push this live", or "create a preview deployment".
metadata:
  author: vercel
  version: "3.0.0"
---
```

`skills/vercel-cli-with-tokens/SKILL.md` (last commit `77a6a1489`, 2026-04-17):
```yaml
---
name: vercel-cli-with-tokens
description: Deploy and manage projects on Vercel using token-based authentication. Use when working with Vercel CLI using access tokens rather than interactive login — e.g. "deploy to vercel", "set up vercel", "add environment variables to vercel".
metadata:
  author: vercel
  version: "1.0.0"
---
```

`skills/react-best-practices/SKILL.md`: note the **frontmatter name differs from the directory name**:
```yaml
---
name: vercel-react-best-practices      # directory is react-best-practices
description: React and Next.js performance optimization guidelines from Vercel Engineering. This skill should be used when writing, reviewing, or refactoring React/Next.js code ...
license: MIT
metadata:
  author: vercel
  version: "1.0.0"
---
```

`skills/vercel-optimize/SKILL.md` (metadata.version "1.2.0"):
```yaml
---
name: vercel-optimize
description: "Use for Vercel cost and performance optimization on deployed projects, ... Trigger for Vercel bill reduction, ..."
metadata:
  version: "1.2.0"
---
```

Observations:
- Only `name` and `description` are required by the spec. Vercel adds `metadata` (author, version) and sometimes `license`.
- The discovery index (section 3) keys on frontmatter `name`, not the directory name. The `vercel-` prefix is therefore the public skill id.
- `skills.sh.json` also uses the prefixed ids (`vercel-react-best-practices`, `vercel-composition-patterns`, `vercel-react-view-transitions`, `vercel-react-native-skills`) and the unprefixed `deploy-to-vercel`, `vercel-cli-with-tokens`, `vercel-optimize`, `web-design-guidelines`. Mixed naming is itself a gotcha.

### How skills reference scripts and references

- `AGENTS.md` (repo guidance, verified at `main`) says: "Reference scripts by relative path, for example `node scripts/{script}.mjs`", "File references work one level deep", "Keep SKILL.md under 500 lines", "Prefer scripts over inline code".
- The `AGENTS.md` template for a skill includes a hard-coded install path: `bash /mnt/skills/user/{skill-name}/scripts/{script}.sh [args]`. That path is a claude.ai sandbox location, not a portable one. This is a portability problem (see Anti-patterns).
- `vercel-optimize/AGENTS.md` (cross-agent entry point) lists Requirements (Node 20+, Vercel CLI v53+, Observability Plus), a 5-step procedure, and points to `references/doctrine.md`.

### Install instructions in README

Verified in `README.md` at `main`:
```bash
npx skills add vercel-labs/agent-skills
```
README also says: "Every change to a skill on `main` publishes an immutable GitHub release with an Agent Skills discovery index and one artifact per skill." Build locally with:
```bash
npm ci --ignore-scripts
node scripts/build-discovery-index.mjs https://example.com/skills
```
Manual install from `AGENTS.md`: `cp -r skills/{skill-name} ~/.claude/skills/` (Claude Code), or paste SKILL.md into claude.ai.

### Build and validation tooling

- `scripts/build-discovery-index.mjs` (verified, read in full at `main`):
  - Reads each `skills/<dir>/SKILL.md` from `git show HEAD:...`.
  - Parses frontmatter with `yaml`. Rejects if `name` or `description` is missing, if `name` is over 64 chars or not matching `^[a-z0-9]+(?:-[a-z0-9]+)*$`, or if `description` is over 1024 chars.
  - Requires unique `name` values across skills.
  - Packs each skill as either a bare `SKILL.md` (if it is the only file) or a deterministic `tar.gz` built via `git commit-tree` with fixed dates (2000-01-01) and `gzip -n`.
  - Writes `dist/<name>.(md|tar.gz)` and `dist/index.json` with `$schema: https://schemas.agentskills.io/discovery/0.2.0/schema.json`, and per-skill `name`, `description`, `type` (`skill-md` | `archive`), `url`, and `digest` (sha256).
- `packages/vercel-optimize-tests`: node:test suite with ~80 test files and fixtures of real CLI output. Run command not verified (no package.json scripts read).
- `packages/react-best-practices-build`: TypeScript generator (`build.ts`, `validate.ts`, `migrate.ts`) that builds the `rules/` folder. Not run.
- No lint or validation step for SKILL.md frontmatter was found in the repo outside the index script. UNVERIFIED whether CI runs these.

---

## 2. The `skills` CLI (vercel-labs/skills): discovery, agent paths, symlink vs copy

Source: `gh api repos/vercel-labs/skills/...` plus a shallow clone at commit `13e4063a1` (2026-10-09T10:54:46-07:00) inspected in the scratchpad (read-only, not executed). Stars: 34,863. (Clone was temporary.)

### Commands (README, verified)

```bash
npx skills add vercel-labs/agent-skills                    # GitHub shorthand
npx skills add vercel-labs/agent-skills --list             # list without installing
npx skills add vercel-labs/agent-skills --skill frontend-design --skill skill-creator
npx skills add vercel-labs/agent-skills -a claude-code -a opencode
npx skills add vercel-labs/agent-skills --skill frontend-design -g -a claude-code -y   # CI-friendly
npx skills add ./my-local-skills                           # local path
npx skills add https://example.com/download/my-skill       # direct SKILL.md or archive URL
npx skills use vercel-labs/agent-skills@web-design-guidelines | claude
npx skills update / list / remove / find / init / experimental_install
```

Source formats: GitHub shorthand, full URL, `.../tree/main/skills/<name>` direct path, GitLab, Azure Repos, any git URL, local path, and arbitrary HTTPS download URLs (`.zip`, `.tar`, `.tar.gz`, `.tgz`, or a bare SKILL.md). Download limits: 10 MiB, extracted 25 MiB, 1000 files, overridable by env vars.

### How it discovers skills in a repo (src/skills.ts, function returning `Skill[]`)

Verified by reading the source:

1. If the search root itself has `SKILL.md`, that single skill is added and the function returns early unless `--full-depth`.
2. Priority search dirs, in order:
   ```
   <root>
   <root>/skills
   <root>/skills/.curated
   <root>/skills/.experimental
   <root>/skills/.system
   <root>/<each AGENT_PROJECT_SKILL_DIRS entry>     e.g. .claude/skills, .agents/skills
   + directories declared in .claude-plugin/marketplace.json or plugin.json (plugin-manifest.ts)
   ```
3. Known container dirs (`skills/`, `skills/.curated`, etc.) are walked up to `DEFAULT_SKILL_CONTAINER_DEPTH` (3 levels), so `skills/<category>/<category>/<skill>/SKILL.md` works. The repo root is depth 1 only, so stray `examples/*/SKILL.md` are not picked up.
4. Skipped dirs: `node_modules`, `.git`, `dist`, `build`, `__pycache__`.
5. Fallback: if nothing was found, or `--full-depth` is set, it does a recursive `findSkillDirs`.
6. Dedupe by `name` (`seenNames`), unless `includeDuplicateNames`.
7. `parseSkillMd` (skills.ts:80) requires `name` and `description` in frontmatter. Missing either → warn and skip.

Well-known discovery (add.ts ~626): for an arbitrary URL, the CLI tries `/.well-known/agent-skills/index.json` (preferred, RFC 8615) then `/.well-known/skills/index.json` (legacy), then falls back to direct download.

Plugin manifests (plugin-manifest.ts): reads `.claude-plugin/marketplace.json` (multi-plugin, `metadata.pluginRoot`, `plugins[].skills`) or `.claude-plugin/plugin.json`. Paths must start with `./` and stay inside the repo base path (path-traversal check).

### Agent install paths (src/agents.ts, verified table in README)

Project path / global path, from README "Supported Agents" (generated from agents.ts):

| Agent (`--agent`) | Project path | Global path |
| --- | --- | --- |
| Claude Code (`claude-code`) | `.claude/skills/` | `~/.claude/skills/` |
| Codex (`codex`), Cline, Gemini CLI, GitHub Copilot, Cursor, OpenCode, Droid, Kilo, Warp, Zed, Pi, ... ("universal") | `.agents/skills/` | `~/.agents/skills/` (OpenCode global: `~/.config/opencode/skills/`; Gemini CLI global: `~/.gemini/skills/`; Copilot global: `~/.copilot/skills/`; Cursor global: `~/.cursor/skills/`) |
| Windsurf (`windsurf`) | `.windsurf/skills/` | `~/.codeium/windsurf/skills/` |
| Goose, Roo, Kiro, Continue, Qwen Code, ... | e.g. `.goose/skills/`, `.roo/skills/`, `.kiro/skills/` | `~/.config/goose/skills/`, `~/.roo/skills/`, ... |

Note: the README table lists Cursor, Gemini CLI, Copilot and OpenCode under `.agents/skills/` for project scope. Their global paths differ. The table is the authority; this was not cross-checked against each vendor's own docs (UNVERIFIED against vendor docs).

Scope: default is project (`./<agent-skills-dir>/`, committed to the repo). `-g` installs to the user dir.

### Symlink vs copy (src/installer.ts, verified)

- Modes: `symlink` (default, "Recommended"), `copy`, `link`.
- `symlink`: copies the skill once into the canonical dir `.agents/skills/<name>` (or `~/.agents/skills/<name>` for global) and creates symlinks from each agent dir (e.g. `.claude/skills/<name>`) to it. Relative symlink targets are computed from realpath-resolved parents.
- Universal agents always use the canonical dir and get no extra symlink. For global installs they skip the symlink entirely.
- Non-universal agents get a symlink in project scope only if their config dir already exists (`shouldSkipProjectAgentSymlink`), so the CLI does not create `.windsurf/` etc. unprompted.
- Windows uses junctions for symlinks. On failure it falls back to copy.
- `copy`: copies into each agent dir.

### Repo as skills source: lock file and `skills.sh.json`

- Project installs write `skills-lock.json` at the project root (`src/local-lock.ts`, `LOCAL_LOCK_FILE = 'skills-lock.json'`). `npx skills experimental_install` restores from it. Lock entries include `sourceType`, `skillFolderHash`, and `sourceUrl` (src/skill-lock.ts, `CURRENT_VERSION` with a v3 bump that adds `skillFolderHash`). Global lock is a separate file (UNVERIFIED path).
- A repo does NOT need a special file to be a source. Discovery works from the `skills/` convention and SKILL.md presence. `.claude-plugin/marketplace.json` is an optional extra that the CLI reads.
- `skills.sh.json` (in vercel-labs/agent-skills) is a grouping file for the skills.sh website. I found no reference to it in the `skills` CLI source (`grep -rn skills.sh.json src/` returned nothing), so the CLI does not read it. The website's use of it is UNVERIFIED.

---

## 3. Agent Skills open spec (agentskills.io) and anthropics/skills

### Spec (fetched 2026-10-14 from https://agentskills.io/specification and https://agentskills.io/client-implementation/adding-skills-support)

No version or last-updated date was shown on the fetched pages. Treat as "as of fetch date".

Directory layout:
```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files or directories
```

Frontmatter fields:

| Field | Required | Constraints |
| --- | --- | --- |
| `name` | Yes | 1–64 chars. `a-z`, `0-9`, `-` only. No leading/trailing hyphen, no `--`. **Must match the parent directory name.** |
| `description` | Yes | 1–1024 chars. Should say what it does AND when to use it, with keywords. |
| `license` | No | Short name or bundled license file reference. |
| `compatibility` | No | 1–500 chars. Environment requirements (product, system packages, network). |
| `metadata` | No | String→string map. Make key names unique. |
| `allowed-tools` | No | Space-separated pre-approved tools, e.g. `Bash(git:*) Bash(jq:*) Read`. Experimental. |

Body: no format restriction. Keep `SKILL.md` under 500 lines. Keep references one level deep from SKILL.md, using relative paths from the skill root.

Progressive disclosure (spec, "Progressive disclosure"):
1. Metadata (~100 tokens): name + description at startup for all skills.
2. Instructions (<5000 tokens recommended): full body on activation.
3. Resources (as needed): files in `scripts/`, `references/`, `assets/` loaded only when required.

Validation: `skills-ref validate ./my-skill` (reference library at https://github.com/agentskills/agentskills/tree/main/skills-ref). Not run; UNVERIFIED that it works.

Client-side discovery guidance (adding-skills-support page):
- Scan project scope (`<project>/.<client>/skills/` and `<project>/.agents/skills/`) and user scope (`~/.<client>/skills/` and `~/.agents/skills/`). Some clients also scan `.claude/skills/`.
- Within a scope, subdirectories containing a file named exactly `SKILL.md`. Skip `.git` and `node_modules`. Bound depth (4–6) and count (2000 dirs).
- Collision rule: project overrides user. Log a warning when shadowing.
- Trust: gate project-level skills on a trust check, since a cloned repo is untrusted.
- Lenient parsing: name/dir mismatch or name >64 chars → warn but load. Missing description → skip. Unquoted colons in description → retry with quoting.
- Catalog: `<available_skills>` XML with name, description, location. Hide filtered skills. Omit catalog if empty.

### anthropics/skills (verified via gh at `dbd4588f9`, 2026-10-09)

`skills/skill-creator/SKILL.md` frontmatter:
```yaml
---
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, ...
---
```
Its `docx` skill folder contains `LICENSE.txt`, `SKILL.md`, `scripts/`. Only the spec-required fields are used there, and `LICENSE.txt` is referenced as a license file. This matches the spec's `license` guidance.

---

## 4. Vercel skills that wrap an external API or CLI: auth and scripts

### Local copies (resolved; both are real directories, not symlinks)

- `~/.agents/skills/deploy-to-vercel/` → `SKILL.md`, `resources/deploy.sh`, `resources/deploy-codex.sh`
- `~/.agents/skills/vercel-cli-with-tokens/` → `SKILL.md`

Diff against upstream at `skills/<name>/` on `main`:
- `deploy-to-vercel/SKILL.md`: identical to upstream except the local copy appends a `<!-- self-improvement-loop -->` block (lines ~297–308). That block is not in upstream. Frontmatter is identical (version 3.0.0).
- `vercel-cli-with-tokens/SKILL.md`: identical to upstream except the same appended block.
- `deploy-to-vercel/resources/deploy.sh`: identical to upstream (0 diff lines).

Local file dates: Sep 1–2, 2026.

### deploy-to-vercel: auth and method ladder (local SKILL.md, matches upstream)

Decision ladder driven by four probes:
1. `git remote get-url origin`
2. `cat .vercel/project.json || cat .vercel/repo.json`
3. `vercel whoami`
4. `vercel teams list --format json`

Then picks one of: git push (linked + remote; asks user before push), `vercel deploy -y --no-wait` (linked, no remote), `vercel link --repo --scope <team>` then deploy, install CLI then `vercel login`, or the no-auth fallback.

Auth model: uses the user's existing CLI login. It never handles a token itself. Hard rules: always preview unless the user asks for `--prod`; never push without approval; do not curl the deployed URL.

No-auth fallback: `resources/deploy.sh` (claude.ai sandbox) and `resources/deploy-codex.sh` (Codex sandbox). Both upload a tarball with `curl -X POST "$DEPLOY_ENDPOINT" -F file=@$TARBALL -F framework=$FRAMEWORK`:
- `deploy.sh` → `DEPLOY_ENDPOINT="https://claude-skills-deploy.vercel.com/api/deploy"` (line 9)
- `deploy-codex.sh` → `DEPLOY_ENDPOINT="https://codex-deploy-skills.vercel.sh/api/deploy"` (line 9)

Both return JSON with `previewUrl` and `claimUrl`. This is an unauthenticated upload to a Vercel-hosted endpoint. The deployment is "claimable" (transferred to the user's account later). No token is used.

The script does `curl -s -o /dev/null -w "%{http_code}" "$PREVIEW_URL"` (line 266), i.e. it fetches the deployed URL, which the SKILL.md tells the agent not to do. That is a small inconsistency between script and prose.

Sandbox note: `SKILL.md` says in the claude.ai sandbox to use `bash /mnt/skills/user/deploy-to-vercel/resources/deploy.sh`, and for Claude Code to use `~/.claude/skills/deploy-to-vercel/resources/deploy.sh`. The path is hard-coded per environment, which is why the upstream AGENTS.md template contains `/mnt/skills/user/...`.

### vercel-cli-with-tokens: token handling (local SKILL.md, matches upstream)

Token discovery order, verified in the file:
- A) `printenv VERCEL_TOKEN`.
- B) `grep '^VERCEL_TOKEN=' .env` then `export VERCEL_TOKEN=$(grep ... | cut -d= -f2-)`.
- C) `grep -i vercel .env`, identify the variable by `vca_` prefix, export it under `VERCEL_TOKEN`.
- D) Ask the user; token created at vercel.com/account/tokens.

Hard rules:
- Never pass `--token` on the command line (shell history and process list exposure). Export `VERCEL_TOKEN` and let the CLI read it.
- Set `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID` together or not at all.
- Use `-y` to avoid prompts. Use `--format json` where structured output helps.
- Don't modify `.vercel/` files directly.

Deploy flows: quick deploy with env ids (`vercel deploy -y --no-wait`), or link (`vercel link --repo --scope <slug> -y`) then deploy. Also covers env vars (`vercel env add/ls/pull/rm`), domains, logs, and a Stripe Projects plan change section that requires asking the user first.

Upstream git history (verified): created 2026-03-18 (`93470e2cb`), hardened 2026-03-18 (`73589c3d5`, "improve token handling and security"), fixed 2026-04-17 (`77a6a1489`, "fix 5 real bugs + document Stripe Projects plan changes").

Scripts: none. This skill tells the agent to run the Vercel CLI directly. No curl to the Vercel API.

### vercel-optimize (upstream, wraps CLI + metrics, ships scripts)

Ships 15 `.mjs` scripts (`collect-signals.mjs`, `merge-signals.mjs`, `gate-investigations.mjs`, `reconcile-candidates.mjs`, `verify-finding.mjs`, `render-report.mjs`, etc.), plus `lib/`, `references/` (including `doctrine.md`), `AGENTS.md`, `CONTRIBUTING.md`. Requirements: Node 20+, Vercel CLI v53+ (`vercel metrics`, `vercel usage`, `vercel contract`, `vercel api`), authenticated CLI, linked project dir, Observability Plus. Procedure: collect signals with the CLI first, gate with deterministic scripts, investigate only what the gates name, verify mechanically, then render. Auth is the user's CLI session. The skill does not take a token. This is the strongest example of a skill that ships scripts for heavy work and keeps SKILL.md short.

---

## Patterns to steal

1. **Ship SKILL.md plus a folder of plain scripts and a `references/` folder, with one-level-deep relative links.** Vercel's `AGENTS.md` makes this a rule ("File references work one level deep"). The `vercel-optimize` skill is the largest example (15 scripts, a `references/doctrine.md`, `lib/`).
2. **Make `name` the stable public id and keep it equal to the directory name.** The spec requires the match, and the discovery index keys on frontmatter `name`. Upstream violates this in `react-best-practices` (name `vercel-react-best-practices`), which is a bug to avoid, not copy.
3. **Use a generated discovery index and immutable release artifacts.** `scripts/build-discovery-index.mjs` validates frontmatter (name regex, 64/1024 limits, unique names), packs each skill deterministically (fixed dates, `gzip -n`), and writes `index.json` with sha256 digests. This makes the repo distributable to any host that serves a static index.
4. **Cross-agent install path table plus a canonical dir with symlinks.** The `skills` CLI puts one copy in `.agents/skills/` and symlinks each agent's native dir to it. Per-agent project vs global paths are data in one file (`agents.ts`), so adding an agent is a one-line change.
5. **Auth by reuse, not by storage.** `deploy-to-vercel` relies on the user's existing `vercel` login and `vercel-cli-with-tokens` reads `VERCEL_TOKEN` from env without passing it as a flag. Scripts never handle secrets directly.

## Anti-patterns / limits

1. **Hard-coded environment paths.** Upstream AGENTS.md templates use `bash /mnt/skills/user/{skill}/scripts/...` and SKILL.md uses `~/.claude/skills/...`. These break in any other agent. For an agent-agnostic library, resolve the skill's own base directory at runtime and use relative paths (the spec's `location` approach).
2. **Name mismatch in the flagship skill.** `react-best-practices` has a directory name that differs from its frontmatter name. Mixed `vercel-` prefixes between `skills.sh.json` and directories add confusion. Enforce `name == dirname` with a validator.
3. **Unauthenticated third-party deploy endpoints in a shipped script.** `deploy.sh` and `deploy-codex.sh` upload user code to `claude-skills-deploy.vercel.com` / `codex-deploy-skills.vercel.sh`. Installing such a skill sends code off the machine without a token check. Review before shipping; the `skills` CLI's own docs say to vet sources.
4. **Prose vs script drift.** SKILL.md says "do not curl the deployed URL", but `deploy.sh` line 266 curls the preview URL. Add a test that checks prose rules against scripts, or remove the contradiction.
5. **Local edits on top of an upstream copy.** The local copies in `~/.agents/skills/` diverge from upstream by an appended `self-improvement-loop` block. Future `npx skills update` will either conflict or overwrite it. Keep local overrides separate from upstream content (the global AGENTS.md hygiene rule).
6. **Limits in the CLI itself.** Symlink mode fails over to copy on some platforms. The lock file is per-project and experimental (`experimental_install`). Discovery depth is capped at 3 for known containers and 1 for the root. Discovery will skip a skill with no description, with only a warning.
7. **Spec leniency.** The spec says name must match the directory, but the client guide says clients should warn and load anyway. Clients will disagree on strictness, so the library should validate strictly itself.
8. **Opaque tooling for skills.sh.** `skills.sh.json` is not read by the `skills` CLI (verified by grep). The website's use of it is UNVERIFIED.

## Open items (UNVERIFIED)

- Whether vercel-labs/agent-skills CI runs the index script or tests (no `.github/workflows` visible via API).
- Vendor-side install directories for Cursor, Gemini CLI, Copilot, OpenCode (taken from the `skills` CLI table, not from vendor docs).
- The agentskills.io spec version. Pages showed no version. Fetched 2026-10-14.
- `skills-ref validate` behavior (not run).
- Whether `skills.sh` website consumes `skills.sh.json`.
