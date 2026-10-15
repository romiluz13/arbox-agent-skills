# Changelog

## 0.9.1 (2026-10-15)

Fixes from a field run of all ten recipes on a live test account (`docs/plan/live-check-results.md`).

- **sales-snapshot, first-30-days:** sales rows are classified by the live `action` values (`New purchase`, `Renew`, `Purchase`, `Lead converted purchase`). The old "empty action" rule reported revenue 0 and no new buyers. `Free` items are counted apart from sales.
- **waivers-and-forms, whos-drifting, no-shows, renewal-watch:** flags are read with one shared rule (`"yes"`/`"no"`, `"true"`/`"false"`, `"1"`/`"0"`; anything else is unknown). `future_registration` `"no"` now means nothing booked. Signed forms are matched by type (`HASWAIVER`, `MEDICALCERT`), not by `form_id`.
- **leads-and-trials:** `task_status` `taskNone` and `taskPast` count as no current task, so leads waiting for a call show again.
- **Phones** are compared by key (digits, leading `972` to `0`), so `05x` and `+972` rows match.
- New `arbox-recipes/references/fields.md`: the field rules every recipe shares.
- **Helper:** reads retry twice on HTTP 429 (seen when two calls with one key overlapped); writes never retry. `read /v3/reports/<name>?a=b&c=d` is accepted when the values carry no URL codes (`%`, `+`, `#`).
- References: required dates, caps and field values from the live run (reports, quirks, users).
- Demo data uses the live value shapes, and `tests/recipes.sh` checks the recipes' jq against each spot-check.

## 0.9.0 (2026-10-15)

First release candidate.

- **Start in one minute:** an owner pastes one sentence into Claude Code ("Install the Arbox skills from … and help me get started"); Claude installs the plugin, the owner types `/reload-plugins`, and the guide's interview begins. "Update my Arbox skills" updates it.
- `arbox-guide`: owner interview (2 rounds max), business profile, ideas catalog (API and no-API ideas), product knowledge, Hebrew/English glossary.
- `arbox-api`: safe setup (hidden key entry with `setup --prompt`), the `arbox` helper (`install`, read/write split, a write allowlist of 7 small internal changes, demo mode, activity log, `--out` confined to `~/Arbox`), 65 operations and 47 reports documented with official deep links, quirks, spec snapshot.
- `arbox-recipes`: 9 recipes plus the Monday page, an HTML report template (no JavaScript, escaped), CSV export.
- **Live-checked on a test account:** date caps (31 days on most reports and the schedule, 7 days on tasks), required report parameters, field types and the server's report names are now in the references and recipes. Results: `docs/plan/live-check-results.md`. Numbers on a busy studio are still to be confirmed; each recipe asks the owner to check one number on first run.
- Evals: triggering 20/20 (guide), 20/20 (recipes), 16/20 (api, misses are report questions that route to recipes when all three are installed); with vs without the skills 96% vs 67%. See `evals/results.md`.
- Launch kit: banner, social card, posts and copy in `docs/launch/`.
- Tooling: validator, fake-server tests, weekly spec-drift check, eval harness.
