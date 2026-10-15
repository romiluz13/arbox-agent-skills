#!/usr/bin/env python3
"""Validate the skills tree. Stdlib only. Exit 1 on any failure.

Checks: standard frontmatter, name == dir, Documentation sections,
65/65 operation deep links, 47/47 reports, relative links, size limits,
recipe jq helpers copied word for word from fields.md.
"""
import json
import re
import sys
from pathlib import Path
from urllib.parse import quote, unquote

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"
SPEC = SKILLS / "arbox-api" / "references" / "openapi.json"
API_REFS = SKILLS / "arbox-api" / "references"
LIVE_SPEC = "https://arboxserver.arboxapp.com/docs/api.json"
HUMAN_DOCS = "https://arboxserver.arboxapp.com/docs/api"
ALLOWED_KEYS = {"name", "description", "license", "compatibility", "metadata"}
METHODS = {"get", "post", "put", "patch", "delete"}

errors = []


def fail(msg):
    errors.append(msg)


def frontmatter(text):
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None
    keys, fields = [], {}
    for line in m.group(1).splitlines():
        km = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if km:
            keys.append(km.group(1))
            fields[km.group(1)] = km.group(2).strip().strip('"').strip("'")
    return keys, fields


def op_link(op_id):
    return f"{HUMAN_DOCS}#/operations/{quote(op_id, safe='')}"


def check_skills():
    dirs = sorted(p for p in SKILLS.iterdir() if p.is_dir())
    if not dirs:
        fail("no skills found")
    for d in dirs:
        skill = d / "SKILL.md"
        if not skill.exists():
            fail(f"{d.name}: missing SKILL.md")
            continue
        text = skill.read_text(encoding="utf-8")
        fm = frontmatter(text)
        if fm is None:
            fail(f"{d.name}: missing frontmatter")
            continue
        keys, fields = fm
        extra = set(keys) - ALLOWED_KEYS
        if extra:
            fail(f"{d.name}: non-standard frontmatter keys {sorted(extra)}")
        name = fields.get("name", "")
        if name != d.name:
            fail(f"{d.name}: name '{name}' != directory")
        if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", name or "x-") or len(name) > 64:
            fail(f"{d.name}: invalid name")
        desc = fields.get("description", "")
        if not desc or len(desc) > 1024:
            fail(f"{d.name}: description missing or > 1024 chars ({len(desc)})")
        if "\n## Documentation" not in text:
            fail(f"{d.name}: no '## Documentation' section")
        else:
            doc = text.split("\n## Documentation", 1)[1].split("\n## ", 1)[0]
            for url in (LIVE_SPEC, HUMAN_DOCS):
                if url not in doc:
                    fail(f"{d.name}: Documentation section lacks {url}")
        lines = text.count("\n") + 1
        if lines > 500:
            fail(f"{d.name}: SKILL.md has {lines} lines (> 500)")


def check_operations():
    if not SPEC.exists():
        fail(f"missing spec snapshot {SPEC.relative_to(ROOT)}")
        return
    spec = json.loads(SPEC.read_text(encoding="utf-8"))
    refs = "\n".join(p.read_text(encoding="utf-8") for p in API_REFS.glob("*.md"))
    ops = [o["operationId"] for v in spec["paths"].values() for m, o in v.items() if m in METHODS]
    missing = [o for o in ops if op_link(o) not in refs]
    for o in missing:
        fail(f"operation link missing in arbox-api references: {o} -> {op_link(o)}")
    reports_md = API_REFS / "reports.md"
    names = spec["components"]["schemas"]["ReportName"]["enum"]
    text = reports_md.read_text(encoding="utf-8") if reports_md.exists() else ""
    for r in names:
        if not re.search(rf"\b{re.escape(r)}\b", text):
            fail(f"report not documented in reports.md: {r}")
    print(f"operations: {len(ops) - len(missing)}/{len(ops)} linked; reports: {len(names)} checked")


def check_links():
    for md in ROOT.rglob("*.md"):
        if any(part in {"node_modules", ".git", ".team"} or part.endswith("-workspace") for part in md.parts):
            continue
        if "docs/research" in md.as_posix():
            continue
        text = md.read_text(encoding="utf-8")
        for target in re.findall(r"\]\(([^)\s]+)\)", text):
            if re.match(r"^[a-z]+:", target) or target.startswith("#"):
                continue
            path = target.split("#", 1)[0]
            if path and not (md.parent / path).exists():
                fail(f"{md.relative_to(ROOT)}: broken relative link {target}")


def check_cited_operations():
    """Every API path and docs deep link cited in a skill must exist in the snapshot."""
    if not SPEC.exists():
        return
    spec = json.loads(SPEC.read_text(encoding="utf-8"))
    paths = list(spec["paths"])
    op_ids = {o["operationId"] for v in spec["paths"].values() for m, o in v.items() if m in METHODS}
    reports = set(spec["components"]["schemas"]["ReportName"]["enum"])
    patterns = [re.compile("^" + re.sub(r"\\\{[^}]+\\\}", "[^/]+", re.escape(p)) + "$") for p in paths]
    for md in SKILLS.rglob("*.md"):
        text = md.read_text(encoding="utf-8")
        rel = md.relative_to(ROOT)
        for p in set(re.findall(r"(/v3/[A-Za-z0-9_/{}\-]*[A-Za-z0-9_}])", text)):
            if p.startswith("/v3/reports/") and p.split("/")[3] in reports:
                continue
            if not any(pt.match(p) for pt in patterns):
                fail(f"{rel}: cites unknown API path {p}")
        for enc in set(re.findall(r"docs/api#/operations/([^\s)`|>\]]+)", text)):
            if enc == "<operationId>" or "<" in enc:
                continue
            if unquote(enc) not in op_ids:
                fail(f"{rel}: deep link to unknown operation {enc}")


def check_versions():
    plugin = json.loads((ROOT / ".claude-plugin/plugin.json").read_text(encoding="utf-8"))
    version = plugin.get("version")
    script = SKILLS / "arbox-api" / "scripts" / "arbox"
    if script.exists():
        m = re.search(r'ARBOX_EXECUTOR_VERSION="([^"]+)"', script.read_text(encoding="utf-8"))
        if not m or m.group(1) != version:
            fail(f"executor version {m.group(1) if m else 'missing'} != plugin.json {version}")
    changelog = ROOT / "CHANGELOG.md"
    if changelog.exists() and f"## {version}" not in changelog.read_text(encoding="utf-8"):
        fail(f"CHANGELOG.md has no '## {version}' entry")


def check_manifests():
    for f in (".claude-plugin/plugin.json", ".claude-plugin/marketplace.json"):
        try:
            json.loads((ROOT / f).read_text(encoding="utf-8"))
        except Exception as e:  # noqa: BLE001
            fail(f"{f}: {e}")


def jq_defs(text):
    """name -> whitespace-normalized text of each top-level jq `def` in the fenced blocks."""
    defs = {}
    for block in re.findall(r"```[a-z]*\n(.*?)```", text, re.S):
        lines = block.split("\n")
        for i, line in enumerate(lines):
            m = re.match(r"def ([a-z_]+)", line)
            if m:
                body = [line]
                for more in lines[i + 1:]:
                    if body[-1].rstrip().endswith(";"):
                        break
                    body.append(more)
                defs[m.group(1)] = " ".join(" ".join(body).split())
    return defs


def check_recipe_field_rules():
    """A recipe that defines a jq helper from fields.md must copy it word for word."""
    refs = ROOT / "skills/arbox-recipes/references"
    shared = jq_defs((refs / "fields.md").read_text(encoding="utf-8"))
    for f in sorted(refs.glob("recipe-*.md")):
        for name, body in jq_defs(f.read_text(encoding="utf-8")).items():
            if name in shared and body != shared[name]:
                fail(f"{f.relative_to(ROOT)}: jq def {name} differs from fields.md")


def main():
    check_manifests()
    check_versions()
    check_skills()
    check_operations()
    check_cited_operations()
    check_links()
    check_recipe_field_rules()
    if errors:
        print("\n".join(f"FAIL {e}" for e in errors))
        print(f"{len(errors)} problem(s)")
        sys.exit(1)
    print("OK")


if __name__ == "__main__":
    main()
