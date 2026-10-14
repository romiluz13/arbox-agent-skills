# Draft architecture v0 (Opus, 2026-10-14). Written to be attacked.

Inputs: arbox-api.md, vercel-skills-packaging.md, claude-code-plugins.md (same folder).

## Facts this draft rests on
- Arbox public API: 65 ops (37 GET / 28 write), base https://arboxserver.arboxapp.com/api/public/v3, auth header `api-key`. The spec has no descriptions, inconsistent id types, and pagination with no total.
- The `skills` CLI discovers `skills/<name>/SKILL.md` AND reads `.claude-plugin/marketplace.json`, so one repo serves both channels.
- Claude plugin `userConfig` secrets reach MCP env, but NOT Bash or skill scripts.

## Proposal
```
arbox-agent-skills/
├── skills/
│   ├── arbox/                 # core: auth, safety rules, CLI usage, domain glossary
│   │   ├── SKILL.md
│   │   ├── scripts/arbox.mjs  # zero-dep Node CLI generated from OpenAPI; reads ARBOX_API_KEY
│   │   └── references/        # one file per tag (users.md, schedule.md, leads.md, finance.md...)
│   ├── arbox-leads/           # workflow skills: task-shaped, depend on the core
│   ├── arbox-schedule/
│   ├── arbox-members/
│   └── arbox-reports/
├── .claude-plugin/{plugin.json, marketplace.json}   # source "."
├── tools/gen.mjs              # OpenAPI → CLI + references; validator (name==dir, frontmatter std-only)
├── evals/                     # claude plugin eval suites + a fake Arbox server for offline tests
└── AGENTS.md / README.md
```
- Execution: a bundled CLI script (not curl prose, not MCP) works in every agent. Key comes from the `ARBOX_API_KEY` env var.
- Safety: GET runs freely. Writes print a dry-run plan and need `--yes`. DELETE, membership cancel, finance documents and messages need an explicit user confirmation in the conversation first.
- Frontmatter uses standard fields only, so the files are identical across channels.
- MCP: deferred. Add it later as an optional Claude-plugin extra if userConfig secret UX matters.

## Known weak spots (attack these)
- I don't know the audience: gym operators driving the API through an agent, or developers writing integration code. That flips everything.
- Requiring Node for the script: is that OK for the target users?
- Workflow skills are invented. Nobody has said which tasks matter.
- No sandbox is known, so evals against the real API would touch production data.
