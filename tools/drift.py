#!/usr/bin/env python3
"""Compare the live Arbox spec with the bundled snapshot. Exit 1 on drift.

Usage: python3 tools/drift.py [--live-url URL]
"""
import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SNAPSHOT = ROOT / "skills" / "arbox-api" / "references" / "openapi.json"
LIVE = "https://arboxserver.arboxapp.com/docs/api.json"
METHODS = {"get", "post", "put", "patch", "delete"}


def ops(spec):
    return {
        (m.upper(), p): o.get("operationId")
        for p, v in spec.get("paths", {}).items()
        for m, o in v.items()
        if m in METHODS
    }


def main():
    url = sys.argv[sys.argv.index("--live-url") + 1] if "--live-url" in sys.argv else LIVE
    req = urllib.request.Request(url, headers={"User-Agent": "arbox-agent-skills-drift/1.0 (+https://github.com/romiluz13/arbox-agent-skills)", "Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=30) as r:
        live = json.load(r)
    snap = json.loads(SNAPSHOT.read_text(encoding="utf-8"))
    if live == snap:
        print("no drift: live spec identical to snapshot")
        return
    a, b = ops(snap), ops(live)
    added = sorted(set(b) - set(a))
    removed = sorted(set(a) - set(b))
    renamed = sorted(k for k in set(a) & set(b) if a[k] != b[k])
    reports_a = set(snap["components"]["schemas"].get("ReportName", {}).get("enum", []))
    reports_b = set(live["components"]["schemas"].get("ReportName", {}).get("enum", []))
    print("DRIFT: live spec differs from skills/arbox-api/references/openapi.json")
    for k in added:
        print(f"  + {k[0]} {k[1]} ({b[k]})")
    for k in removed:
        print(f"  - {k[0]} {k[1]} ({a[k]})")
    for k in renamed:
        print(f"  ~ {k[0]} {k[1]}: {a[k]} -> {b[k]}")
    for r in sorted(reports_b - reports_a):
        print(f"  + report {r}")
    for r in sorted(reports_a - reports_b):
        print(f"  - report {r}")
    if not (added or removed or renamed or reports_a ^ reports_b):
        print("  (schemas or descriptions changed; operations and reports unchanged)")
    print("Update the snapshot and the affected references, then rerun tools/validate.py.")
    sys.exit(1)


if __name__ == "__main__":
    main()
