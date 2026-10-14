#!/bin/bash
# Run one eval prompt through `claude -p` in an isolated sandbox HOME.
# See README.md. Usage:
#   run_case.sh --prompt-file F --mode with|without --out DIR
#               [--fake-server] [--model M] [--timeout S] [--keep-sandbox]
set -u
HERE=$(cd "$(dirname "$0")" && pwd -P)
REPO=$(cd "$HERE/../.." && pwd -P)
PROMPT_FILE="" MODE="" OUT="" FAKE=0 MODEL="" TIMEOUT=300 KEEP=0
while [ $# -gt 0 ]; do
  case $1 in
    --prompt-file) PROMPT_FILE=$2; shift 2 ;;
    --mode) MODE=$2; shift 2 ;;
    --out) OUT=$2; shift 2 ;;
    --fake-server) FAKE=1; shift ;;
    --model) MODEL=$2; shift 2 ;;
    --timeout) TIMEOUT=$2; shift 2 ;;
    --keep-sandbox) KEEP=1; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[ -f "$PROMPT_FILE" ] && [ -n "$OUT" ] || { echo "need --prompt-file and --out" >&2; exit 2; }
case $MODE in with|without) ;; *) echo "--mode must be with|without" >&2; exit 2 ;; esac

mkdir -p "$OUT/outputs" || exit 2
OUT=$(cd "$OUT" && pwd -P)
REAL_HOME=$HOME
SB=$(mktemp -d "${TMPDIR:-/tmp}/arbox-eval.XXXXXX") || exit 2
SB=$(cd "$SB" && pwd -P)
SBHOME=$SB/home
mkdir -p "$SBHOME/Library"
# Auth: the macOS keychain lookup follows $HOME, so a bare temp HOME is "Not logged in".
# Symlinking the real Keychains dir into the sandbox HOME fixes that.
ln -s "$REAL_HOME/Library/Keychains" "$SBHOME/Library/Keychains"
cp "$PROMPT_FILE" "$OUT/prompt.txt"

SERVER_PID="" WATCHDOG_PID=""
cleanup() {
  [ -n "$SERVER_PID" ] && kill "$SERVER_PID" 2>/dev/null
  [ -n "$WATCHDOG_PID" ] && kill "$WATCHDOG_PID" 2>/dev/null
  [ "$KEEP" = 1 ] || rm -rf "$SB"
}
trap cleanup EXIT

mkdir -p "$SB/tmp" "$SB/stubs"
# Stub `open` so a run can't pop windows on the host; record what it tried to open.
printf '#!/bin/sh\necho "$*" >> "%s/opened.txt"\n' "$OUT" > "$SB/stubs/open"
chmod 755 "$SB/stubs/open"
ENVV=(HOME="$SBHOME" TMPDIR="$SB/tmp" PATH="$SB/stubs:$PATH")
if [ "$FAKE" = 1 ]; then
  python3 "$REPO/tests/fake_server.py" "$SB/port" "$OUT/server.log" &
  SERVER_PID=$!
  for _ in $(seq 1 50); do [ -s "$SB/port" ] && break; sleep 0.1; done
  [ -s "$SB/port" ] || { echo "fake server did not start" >&2; exit 3; }
  PORT=$(cat "$SB/port")
  mkdir -p "$SBHOME/.arbox"
  printf 'test=FAKEKEY123\n' > "$SBHOME/.arbox/profiles"
  chmod 600 "$SBHOME/.arbox/profiles"
  ENVV+=(ARBOX_BASE_URL="http://127.0.0.1:$PORT/api/public")
fi

# Permissions via --settings (a .claude/settings.json under a HOME-like cwd was NOT picked up). User settings are skipped (--setting-sources project).
# Permissions: dontAsk mode = anything not allowed is denied, no prompts.
# Bash cannot be path-scoped by Claude Code; the sandbox is HOME + cwd, that is the containment.
# Read of the plugin repo is allowed so skills can read their own references.
cat > "$SB/settings.json" <<JSON
{"permissions":{"defaultMode":"dontAsk","allow":[
 "Bash","Skill","Glob","Grep",
 "Read(//$SB/**)","Write(//$SB/**)","Edit(//$SB/**)",
 "Read(//$REPO/**)"
]}}
JSON

ARGS=(-p --output-format stream-json --verbose --setting-sources project --settings "$SB/settings.json"
      --permission-mode dontAsk --no-session-persistence)
[ "$MODE" = with ] && ARGS+=(--plugin-dir "$REPO")
[ -n "$MODEL" ] && ARGS+=(--model "$MODEL")

START=$(date +%s)
(
  cd "$SBHOME" || exit 2
  env "${ENVV[@]}" claude "${ARGS[@]}" < "$PROMPT_FILE" > "$OUT/transcript.jsonl" 2> "$OUT/stderr.txt" &
  CPID=$!
  ( sleep "$TIMEOUT"; kill "$CPID" 2>/dev/null; echo timeout > "$OUT/.timeout" ) &
  WD=$!
  wait "$CPID"; RC=$?
  kill "$WD" 2>/dev/null
  echo "$RC" > "$OUT/.rc"
)
END=$(date +%s)

# Collect results.
[ -d "$SBHOME/Arbox" ] && cp -R "$SBHOME/Arbox" "$OUT/outputs/Arbox"
[ -d "$SBHOME/.arbox" ] && (cd "$SBHOME" && find .arbox -type f ! -name profiles | sort) > "$OUT/arbox_home_files.txt"
(cd "$SBHOME" && find . -path ./Library -prune -o -type f -print | sort) > "$OUT/sandbox_files.txt"
[ -x "$SBHOME/.arbox/bin/arbox" ] && echo yes > "$OUT/executor_installed.txt" || echo no > "$OUT/executor_installed.txt"
[ "$FAKE" = 1 ] && [ -f "$OUT/server.log" ] || : 

python3 - "$OUT" "$START" "$END" <<'PY'
import json, sys, os
out, start, end = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
result, cmds, tools = {}, [], {}
for line in open(os.path.join(out, "transcript.jsonl"), errors="replace"):
    try: ev = json.loads(line)
    except ValueError: continue
    if ev.get("type") == "result": result = ev
    if ev.get("type") == "assistant":
        for b in ev.get("message", {}).get("content", []):
            if b.get("type") == "tool_use":
                tools[b["name"]] = tools.get(b["name"], 0) + 1
                if b["name"] == "Bash": cmds.append(b["input"].get("command", ""))
final = result.get("result") or ""
open(os.path.join(out, "final.md"), "w").write(final)
with open(os.path.join(out, "commands.txt"), "w") as f:
    for c in cmds: f.write(c.replace("\n", "\n  ") + "\n---\n")
u = result.get("usage", {})
timing = {
  "total_duration_seconds": end - start,
  "duration_ms": result.get("duration_ms"),
  "duration_api_ms": result.get("duration_api_ms"),
  "num_turns": result.get("num_turns"),
  "total_tokens": (u.get("input_tokens", 0) + u.get("output_tokens", 0)
                   + u.get("cache_creation_input_tokens", 0) + u.get("cache_read_input_tokens", 0)) or None,
  "total_cost_usd": result.get("total_cost_usd"),
  "is_error": result.get("is_error"),
  "permission_denials": len(result.get("permission_denials", [])),
  "tool_calls": tools,
  "timed_out": os.path.exists(os.path.join(out, ".timeout")),
}
json.dump(timing, open(os.path.join(out, "timing.json"), "w"), indent=2)
PY
echo "done: $OUT (rc=$(cat "$OUT/.rc" 2>/dev/null))"
