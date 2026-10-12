# M<ID>: <title>

<!-- Copy to redux/milestones/M<ID>-<slug>.md when the milestone starts. Keep it short and factual.
     Every section is filled before the PR is opened. -->

- **Track / size:** <track letter> / <S|M|L>
- **Branch:** `m/M<ID>-<slug>`
- **Issue / PR:** #<issue> / #<pr>
- **Depends on:** <milestones or gaps>

## Goal
<one sentence: what the user can see or do afterwards>

## Research
<!-- Time-boxed: S 15 min, M 30–45 min, L one spike session. At most ~15 lines. -->
- Upstream since the pin: `git log --oneline $(cat redux/UPSTREAM_COMMIT)..upstream/master -- <paths>`
- Upstream MRs searched: <terms → relevant MRs, or "none">
- Reusable code found: <file:line → what we reuse>
- Prior art / libraries: <only if new C++ is needed>
- New gaps: <G-numbers added to GAPS.md, or "none">

## Scope
-

## Out of scope
-

## Files
<!-- Expected touch list; prefer new files over deep edits to upstream files. -->
-

## Acceptance criteria
<!-- Observable outcomes; each one is checked in Verification. -->
- [ ]

## Verification
<!-- Commands and their actual results (paste short output, region scores before → after). -->
| Check | Command | Result |
|---|---|---|
| Build | `redux/dev.sh run redux/tools/build.sh qt` | |
| Tests | `redux/dev.sh run meson test -C build/meson --suite qt` | |
| Screens | `redux/dev.sh run redux/tools/shoot.sh <scenes>` + `compare.sh` | |
| Review | `/code-review`, `qt-qml-review` / `qt-cpp-review`, `/simplify` | |

## Manual checklist (for the maintainer)
<!-- What to click or try with `redux/dev.sh run redux/tools/build.sh run`. -->
- [ ]

## Definition of Done
- [ ] Build and tests pass
- [ ] Touched screens are keyboard-reachable
- [ ] Night and Day start without QML errors (`grep -i "qml.*error" build/shots/vlc.log` is empty)
- [ ] No new hard-coded hex colors or `radius:` numbers in touched QML
- [ ] `STATUS.md` row and this file's status log are updated
- [ ] PR has before/after crops; upstreamable pieces are noted

## Decisions
<!-- Non-obvious choices made during this milestone; copy lasting ones into DECISIONS.md. -->
-

## Status log
<!-- Dated entries. Ending a session mid-milestone always records "stopped at / next step". -->
- YYYY-MM-DD:
