# Claude Code plugins: research notes (2026-10-14)

Source: claude-code-guide researcher, code.claude.com docs, local Claude Code 2.1.299.

- Manifest `.claude-plugin/plugin.json`: only `name` is required. Auto-discovered: `skills/<name>/SKILL.md`, `commands/`, `agents/`, `hooks/hooks.json`, `.mcp.json`, `bin/`. (plugins/manifest-reference)
- Marketplace `.claude-plugin/marketplace.json` requires `name`, `owner`, `plugins[]{name,source}`. A relative source `"."` means the repo root, so one repo can be both marketplace and plugin (confirm with `claude plugin validate`). Reserved names include `agent-skills`, `claude-*`, `anthropic-*`.
- Versioning: manifest `version`, then entry `version`, then commit SHA. Auto-update is off by default for third-party marketplaces.
- Skills are namespaced as `/plugin:skill`. The Agent Skills standard frontmatter is name, description, license, compatibility, metadata, allowed-tools. Claude-only fields (disable-model-invocation, model, context, paths...) are rejected by claude.ai uploads and the Skills API, and ignored by Claude Code when unknown.
- Secrets: `userConfig` with `sensitive: true` uses secure storage. `${user_config.KEY}` resolves in MCP config `env`, LSP, hooks, and skill content (sensitive values appear as placeholders). It is NOT exported to Bash tool commands. GAP: no documented way for a sensitive key to reach a bundled skill script. The documented route is an MCP server env.
- MCP in a plugin: `.mcp.json` with `${CLAUDE_PLUGIN_ROOT}`. Tools are named `mcp__plugin_<plugin>_<server>__<tool>`.
- Quality gates: `claude plugin validate <path> --strict --json`; `claude plugin eval <path> --trust-plugin --json r.json --threshold 0.8` (makes real model calls, with a no-plugin baseline).
- Sharing one repo with other agents: not covered in the Claude docs. Keep shared SKILL.md files to standard fields, and keep `${CLAUDE_PLUGIN_ROOT}` and userConfig out of them.
