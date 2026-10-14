# Eval harness

Runs one prompt through `claude -p` in a throwaway HOME, so the skills' `~/Arbox` and `~/.arbox` land in a sandbox, then checks the run deterministically. Layout matches skill-creator (`outputs/`, `transcript.jsonl`, `timing.json`, `final.md`, `grading.json`).

    ./run_case.sh --prompt-file P.txt --mode with|without --out DIR [--fake-server] [--model haiku] [--timeout 300] [--keep-sandbox]
    ./check.py DIR --assert no_key_in_transcript no_message_endpoint ...   # or: --assert all  (add --said-yes if the user confirmed a write)

`with` loads the repo via `--plugin-dir`; `without` loads nothing. `--fake-server` starts `tests/fake_server.py`, exports `ARBOX_BASE_URL=http://127.0.0.1:PORT/api/public` and writes `~/.arbox/profiles` with `test=FAKEKEY123`. Without it, use demo mode (`--demo`) in the prompt.

Extra files in DIR: `commands.txt` (every Bash command), `server.log` (+ `.body.N`), `executor_installed.txt`, `sandbox_files.txt`, `stderr.txt`. `outputs/Arbox/` is a copy of the sandbox `~/Arbox`. The sandbox `profiles` file is never copied out.

## Assertions
no_key_in_transcript, no_message_endpoint, no_write_without_confirm, used_executor, report_html_exists, html_escaped, asked_questions_first, hebrew_reply, docs_link.

## Auth findings
- Credentials live in the macOS keychain under a service name hashed from `CLAUDE_CONFIG_DIR` (`Claude Code-credentials-<hash>`). Keep the real `CLAUDE_CONFIG_DIR`; a sandbox config dir gives "Not logged in".
- Keychain lookup also follows `$HOME`: a bare temp HOME gives "Not logged in". Fix: symlink `$REAL_HOME/Library/Keychains` into `$SANDBOX_HOME/Library/Keychains`. Verified with haiku.
- No token is read or copied. Do not use `--bare` (it skips keychain reads).

## Permission findings
- `--permission-mode dontAsk` plus an allow list in a `--settings` file: `Bash`, `Skill`, `Glob`, `Grep`, `Read/Write/Edit(//SANDBOX/**)`, `Read(//REPO/**)`. Anything else is denied without a prompt. No bypass flag.
- A `.claude/settings.json` under the sandbox cwd was NOT honoured (everything denied); use `--settings`.
- `--setting-sources project` skips the user's settings, hooks and enabled plugins. Only bundled skills plus the plugin showed in the init skill list.
- Limit: Bash cannot be path-scoped. Containment is HOME and cwd being the sandbox, not a jail.

## Limits
- Timeout is a background sleep+kill (no `timeout` on macOS).
- `-p` is single turn: cases needing a user "yes" mid-run are not covered.
- In demo mode the skill ran `skills/arbox-api/scripts/arbox` from the plugin dir and did not install `~/.arbox/bin/arbox`.
- The model may run `open` on a report; harmless in the sandbox but it will open a browser tab on the host.
