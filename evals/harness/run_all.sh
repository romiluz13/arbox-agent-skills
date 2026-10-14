#!/bin/sh
# Ticket 08: every evals/evals.json case, with and without the skills, into WORKSPACE/iteration-N/.
# Usage: evals/harness/run_all.sh WORKSPACE_ITERATION_DIR [--model M]
set -u
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../.." && pwd)
ITER=$1; shift
mkdir -p "$ITER"
python3 - "$REPO/evals/evals.json" "$ITER" <<'PY'
import json, os, sys
d = json.load(open(sys.argv[1]))
for e in d["evals"]:
    base = os.path.join(sys.argv[2], "eval-%d-%s" % (e["id"], e["name"]))
    os.makedirs(base, exist_ok=True)
    open(os.path.join(base, "prompt.txt"), "w").write(e["prompt"])
    open(os.path.join(base, "asserts.txt"), "w").write(" ".join(e["checks"]))
    json.dump({"eval_id": e["id"], "eval_name": e["name"], "prompt": e["prompt"],
               "assertions": e["checks"]}, open(os.path.join(base, "eval_metadata.json"), "w"), indent=2, ensure_ascii=False)
PY
for dir in "$ITER"/eval-*; do
  for mode in with without; do
    ( "$HERE/run_case.sh" --prompt-file "$dir/prompt.txt" --mode $mode --out "$dir/${mode}_skill" "$@" \
      && python3 "$HERE/check.py" "$dir/${mode}_skill" --assert $(cat "$dir/asserts.txt") ) > "$dir/${mode}_skill.log" 2>&1 &
  done
done
wait
echo done
