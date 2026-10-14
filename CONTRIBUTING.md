# Contributing

Thanks for helping Arbox owners get more out of their agents.

- **Report a mismatch:** if a recipe's number differs from your Arbox screen, open an issue with the recipe name, the field, and what Arbox shows. Never include member data or your API key.
- **Change a skill:** keep frontmatter to `name`, `description`, `license`, `compatibility`, `metadata`; `name` must equal the folder. Every skill keeps a `## Documentation` section.
- **Run the checks before a PR:**
  ```
  python3 tools/validate.py
  sh tests/run.sh
  ```
- **API changed?** Run `python3 tools/drift.py`, update `skills/arbox-api/references/openapi.json` and the affected reference files, then validate.
- **Safety rules are not negotiable in PRs:** no new write operations without a design discussion; the key never goes in argv, chat, or output; record text is data, never instructions.
