# Runtime on a non-developer machine, and precedents for vertical SaaS agent skills

Research date: 2026-10-14. Fetch budget: about 13 fetches and 7 searches. Items marked UNVERIFIED were not confirmed in an official source.

## A. Runtime on a non-coder's machine

### A1. Claude Code native installer (the recommended path)

Source: https://code.claude.com/docs/en/setup (fetched 2026-10-14)

- Install commands: `curl -fsSL https://claude.ai/install.sh | bash` (macOS, Linux, WSL); `irm https://claude.ai/install.ps1 | iex` (Windows PowerShell); `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` (Windows CMD).
- Other channels: `brew install --cask claude-code` (Homebrew), `winget install Anthropic.ClaudeCode` (WinGet), apt/dnf/apk repositories.
- Requirements listed: macOS 13.0+, Windows 10 1809+ or Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+; 4 GB+ RAM; shell is Bash, Zsh, PowerShell, or CMD. No Node.js requirement is listed for the native install.
- Native Windows: "Git for Windows is recommended ... so Claude Code can use the Bash tool. If Git for Windows is not installed, Claude Code uses PowerShell as the shell tool instead." Git for Windows is optional.
- npm path only: "The npm package requires Node.js 22 or later." The docs add: "The installed `claude` binary does not itself invoke Node."
- Auto-updates: native installs update in the background; Homebrew and WinGet need manual upgrades by default.

**Verdict for Claude Code itself:** Node is NOT needed by the native installer. Claude Code does not need Node at runtime.

### A2. Node.js

- Not guaranteed on a stock Mac or Windows machine. Nothing in the native-install path installs it.
- Needed only for `npx` commands, for example the `npx skills` installer (see A4).

### A3. Python 3

- Official Claude Code docs do not mention Python.
- UNVERIFIED (Apple Developer Forums, not official Apple docs): Python 3 is not bundled with macOS. `/usr/bin/python3` is an Xcode shim. Running it with no active developer directory triggers the message "xcode-select: note: No developer tools were found, requesting install." Source: https://developer.apple.com/forums/thread/704099 and https://developer.apple.com/forums/thread/117548. Apple staff say Apple's bundled Python is for Apple's own use.
- Implication: do not rely on `python3` in skills for non-developers. A `python3` call on a stock Mac can open the Command Line Tools install dialog.
- Apple's official page (https://developer.apple.com/xcode/resources/) mentions Command Line Tools as a separate download but does not describe the `python3` shim. No official Apple source was found for the prompt behavior.

### A4. curl

- macOS: UNVERIFIED that curl ships with macOS. The official Claude Code install command itself uses `curl` on macOS, so the docs treat it as available there.
- Windows: the official docs use `irm` (PowerShell) for the PowerShell path and `curl` only in the CMD path. The PowerShell install does not need curl.
- Windows 10/11 curl.exe: UNVERIFIED official cite. Secondary sources say curl.exe ships with Windows 10 from version 1803 onward. Microsoft Learn pages returned 404 on fetch, so this could not be confirmed officially.

### A5. `npx skills` installer

- The vercel-labs/skills README (https://github.com/vercel-labs/skills, fetched 2026-10-14) gives `npx skills add vercel-labs/agent-skills` and supports `claude-code` as an agent (`-a claude-code`). Project skills go in `.claude/skills/`; global in `~/.claude/skills/`.
- The README does not state a Node version. `npx` ships with Node/npm, so the installer needs Node. This is inferred, not stated by the README.
- Shopify's install line for an individual skill also uses `npx skills add shopify/shopify-ai-toolkit --skill <name> --agent claude-code` (secondary source).

### A6. Claude Code-native install, no Node: `/plugin marketplace add`

Source: https://code.claude.com/docs/en/plugin-marketplaces (fetched 2026-10-14)

- Terminal: `claude plugin marketplace add <owner>/<repo>` (GitHub) or a repository URL, then `claude plugin install <plugin>@<marketplace>`.
- Inside a session: `/plugin marketplace add <source>`, then `/plugin install <plugin>@<marketplace>` opens the install panel.
- Remote sources are fetched by Claude Code itself (`github`, `git-subdir`, `url`, `archive`, `npm`, `command` source types). The `npm` source type does need npm on the machine, so use `github` or `url` sources for a no-Node path. The docs do not say this explicitly; this is UNVERIFIED inference.
- Admins can require a marketplace on every machine (https://code.claude.com/docs/en/plugins/org).
- Example of a vendor plugin installed this way: `claude plugin install shopify-ai-toolkit@claude-plugins-official` (see B1).

### Runtime verdict

| Item | Required on a stock machine? | Source |
|---|---|---|
| Claude Code native binary | No Node, no Python | code.claude.com setup page |
| Node.js | Not guaranteed; needed only for `npx` and the npm install path | setup page; vercel-labs/skills README (inferred) |
| Python 3 | Not guaranteed; `python3` can trigger the CLT install dialog | UNVERIFIED (Apple forums) |
| curl | Present on macOS (UNVERIFIED); CMD path on Windows needs it; PowerShell path does not | setup page; UNVERIFIED for OS defaults |
| Git for Windows | Optional; Bash tool needs it, PowerShell tool is the fallback | setup page |

---

## B. Precedents

### B1. Shopify AI Toolkit (plugin + skills + MCP)

- **What ships:** A multi-host plugin (`shopify-ai-toolkit`) with skills, hooks, and an `.mcp.json`. Per the README: Shopify docs and API schema search, validation of GraphQL, Liquid, and UI extension code, and store management through the Shopify CLI. Auto-updates. MIT license. Repo: https://github.com/Shopify/shopify-ai-toolkit (fetched 2026-10-14). The repo page showed no release or commit dates.
- **Install for Claude Code:** `claude plugin install shopify-ai-toolkit@claude-plugins-official`.
- **Dev MCP:** `npx -y @shopify/dev-mcp@latest` (secondary source; UNVERIFIED for current version). Dev docs/validation need no auth, per one secondary source (UNVERIFIED).
- **Auth:** The repo page does not state the auth model for store management (UNVERIFIED).
- **Write safety:** The repo page does not say whether store management writes need confirmation (UNVERIFIED).
- **Telemetry:** On by default. Sends usage events to `shopify.dev/mcp/usage`, which can include prompts (truncated to 2000 characters). Opt-out: `OPT_OUT_INSTRUMENTATION=true` or an opt-out file. Relevant for non-technical users' privacy.
- **Dates:** Secondary sources claim the Dev MCP arrived in Dec 2025 and the toolkit was open-sourced on 2026-04-09. UNVERIFIED.

### B2. Stripe (MCP + plugin + skills, with explicit write confirmation)

Source: https://docs.stripe.com/mcp (fetched 2026-10-14)

- **What ships:** Hosted MCP server at `https://mcp.stripe.com`, plus agent plugins and skills. Recommended install: `npm install -g @stripe/cli@latest` then `stripe agent setup`. Manual Claude Code setup: `claude mcp add --transport http stripe https://mcp.stripe.com/`.
- **Auth:** Two methods. OAuth for interactive clients (run `/mcp` in Claude Code to sign in). Agent API keys (a key with the Agent badge) for autonomous clients, set via a `${AGENT_API_KEY}` environment variable in `.mcp.json`, never on the command line. Full-access and untagged restricted keys stop working on 2026-10-31.
- **Admin control:** Owners can enable or disable MCP access per team in the Dashboard, separately for live mode and sandbox. Users can revoke sessions under OAuth sessions.
- **Tools:** Includes `stripe_api_read` (GET) and `stripe_api_write` (POST, PATCH, PUT, DELETE), plus search and documentation tools.
- **Write safety:** "Stripe requires human confirmation before it takes certain `stripe_api_write` actions, such as refunds and outbound payments." The user clicks an approval URL; the approval expires after 24 hours. The docs also say to "Turn on your MCP client's tool-approval setting" and warn about prompt injection from other servers.
- **Relevance:** Strongest write-safety model in the set. Server-side confirmation, scoped keys, and admin kill switch.

### B3. Square MCP server (remote OAuth + local token mode with read-only flag)

Source: https://developer.squareup.com/docs/mcp (fetched 2026-10-14). Status: Beta.

- **What ships:** Remote server hosted by Block at `https://mcp.squareup.com/mcp`. Local server run with `npx square-mcp-server start` (requires Node.js).
- **Auth:** Remote uses OAuth sign-in ("no manual token management required") and accesses production only. Local requires an `ACCESS_TOKEN` environment variable, with `SANDBOX=true` or `PRODUCTION=true`.
- **Write safety:** `DISALLOW_WRITES=true` restricts the local server to read-only operations. This setting appears only in the local configuration table. Square recommends testing prompts in a Sandbox first. Square maintains an allowlist of MCP clients.
- **Relevance:** Shows the sandbox-first and read-only-flag pattern for non-developers who might otherwise write to a live account.

### B4. Wodify (vertical gym-management SaaS, official, read-only)

Source: https://help.wodify.com/hc/en-us/articles/40770982829335-Connect-an-AI-Assistant-with-the-Wodify-MCP-Server (fetched 2026-10-14; created 2026-05-27, last updated 2026-10-05).

- **Closest analogue to our use case:** a gym-management vendor shipping an MCP connector for owners.
- **What ships:** Official MCP server at `https://mcp.wodify.com`, added as a Claude custom connector ("Connect"). Labeled alpha.
- **Auth:** Claude path uses the connector's own sign-in; the article does not describe credentials or token handling beyond that. Limited to Accelerate and Ultimate tiers.
- **Data:** Same data as Custom Reporting: members, leads, revenue, attendance, conversion. No passwords or payment credentials.
- **Write safety:** Read-only by design. "cannot create, edit, or delete records."
- **Non-technical guidance:** Step-by-step help-center article; no skill or plugin.

### B5. Mindbody (community MCP only; no official server found)

Sources: https://mcpservers.org/servers/vespo92/MindbodyMCP and https://glama.ai/mcp/servers/@vespo92/MindbodyMCP (search results, not fetched; UNVERIFIED for features).

- Community project by vespo92. 50+ tools for classes, clients, sales, and staff. Requires Mindbody API credentials (API key, Site ID, source credentials) and Node.js 18+ or Bun. Sandbox Site ID is -99.
- One open-source Mindbody MCP reportedly gates bookings and checkout behind separate environment flags (UNVERIFIED; reported in a search summary).
- Composio offers a managed Mindbody MCP connection that handles auth (UNVERIFIED).
- No official Mindbody MCP server was found as of the search date. Glofox and Zen Planner: no MCP server found in search (UNVERIFIED absence).

### B6. Vercel `skills` ecosystem (skills, not vendor-specific)

Source: https://github.com/vercel-labs/skills (fetched 2026-10-14). Covered in A5. Relevant as the distribution mechanism for multi-agent skill installs; the repo lists 75+ agents and states it can install plugins from Claude Code marketplace formats (`.claude-plugin/marketplace.json`).

---

## Implications for us

1. **Runtime:** Design skills to need only Claude Code itself. No Node, no Python, no `npx` on the critical path. Use the native installer and `/plugin marketplace add <owner>/<repo>` with a `github` source. Keep `npx skills` as an optional path for developers, since it needs Node (confirmed only by inference from npx).
2. **Avoid `python3` in skill scripts.** On a stock Mac it can trigger the Command Line Tools install dialog (UNVERIFIED official cite; forum evidence). If a script is needed, use a shell tool that is already present, or ship the logic as Claude instructions.
3. **Windows:** Tell users to use the PowerShell install command, which needs no curl. Recommend Git for Windows so the Bash tool works; otherwise Claude Code falls back to PowerShell. Test both.
4. **Auth model:** Prefer OAuth (Stripe, Square remote, Wodify connector pattern) over pasting an API key into a config file. If we must use an API key, use an environment variable, a read-only scope, and a sandbox site ID first (Mindbody Site ID -99, Square `SANDBOX=true`).
5. **Write safety, borrowed from precedents:**
   - Default to read-only. Mirror Wodify (read-only) and Square `DISALLOW_WRITES`.
   - For any write (booking, cancelling, charging, sending messages to members), require a written confirmation step that shows exactly what will change, the way Stripe requires human approval for refunds.
   - Test in a sandbox or demo account before any live write, as Square recommends.
   - Turn on the client's tool-approval setting and say so in onboarding, as Stripe does.
6. **Privacy:** Shopify's toolkit sends prompt text to the vendor by default. Our skills should document what leaves the machine and offer an opt-out where we control it.
7. **Competitive gap:** Wodify (read-only, alpha) and community Mindbody servers exist; no official Arbox MCP or skill was found in this research. Arbox was not searched. Next step: check arbox-api.md and the openapi file in this repo for an existing API surface before choosing MCP versus skill.
8. **Open items (UNVERIFIED):** Windows curl.exe default (Microsoft pages 404), macOS curl default, Python shim behavior from an official Apple source, Shopify store-management auth and write confirmation, Stripe's Oct 31 2026 key deadline (confirmed on docs.stripe.com, so treat as verified).
