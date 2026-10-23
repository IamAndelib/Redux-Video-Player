# <ID>: <title>

<!-- Copy to redux/milestones/<ID>-<slug>.md (M… or Q…) when the milestone starts. Keep it short and factual.
     Every section is filled before the PR is opened. -->

- **Track / size:** <track letter> / <S|M|L>
- **Branch:** `m/<ID>-<slug>`
- **Owner:** @<github user> (the issue assignee, D25)
- **Issue / PR:** #<issue> / #<pr>
- **Depends on:** <milestones or gaps>

## Goal
<one sentence: what the user can see or do afterwards>

## Research
<!-- Time-boxed: S 15 min, M 30–45 min, L one spike session. At most ~15 lines. -->
- Upstream since the pin: `git log --oneline $(cat redux/UPSTREAM_COMMIT)..upstream/master -- <paths>`
- Upstream MRs searched: <terms → relevant MRs, or "none">
- Reusable code found: <file:line → what we reuse>
- Prior art (always): <who already solved this: upstream VLC, mpv/IINA/Haruna/Celluloid/MPC-HC, KDE/Qt, libraries, test suites → what we adopt, credited in redux/CREDITS.md; or "none fits, because …">
- New gaps: <G-numbers added to GAPS.md, or "none">

## Scope
<!-- Only what redux/SCOPE.md keeps; cite D14 for anything left out. -->
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
| Codec matrix (from M0.6 on) | `redux/dev.sh run redux/tools/play-matrix.sh` | |
| Tests | `redux/dev.sh run meson test -C build/meson --suite qt` | |
| Screens | `redux/dev.sh run redux/tools/shoot.sh <scenes>` + `compare.sh` | |
| QA suite (from M0.8, D23) | `redux/tools/qa.sh` → `build/qa/report.md` | |
| Review | `/code-review`, `qt-qml-review` / `qt-cpp-review`, `/simplify` | |

## Manual checklist (for the maintainer)
<!-- The hand-over test checklist (D18): open "Redux Video Player (dev)" from the app menu (or `redux/dev.sh app`).
     One numbered item per user-visible change, plus a quick regression check. Once Q0.6 is done (D23): only an
     optional 2–3 item real-desktop spot check (audio, GPU, feel); the QA report covers the rest. -->
1. [ ] **Open:** <where in the app> · **Do:** <action> · **Expect:** <what should happen>

**Known not working yet:** <out of scope or later milestones>

**Report:** the item number and what you saw (a screenshot helps).

## Definition of Done
- [ ] Build and tests pass
- [ ] Touched screens are keyboard-reachable
- [ ] Night and Day start without QML errors (`grep -i "qml.*error" build/shots/vlc.log` is empty)
- [ ] No new hard-coded hex colors or `radius:` numbers in touched QML
- [ ] Touched screens keep the spacing-token gaps; nothing sits flush against its neighbour (principle 9)
- [ ] `STATUS.md` row and this file's status log are updated
- [ ] PR has before/after crops; upstreamable pieces are noted
- [ ] From M0.8: QA suite green, report attached to the PR (D23)

## Decisions
<!-- Non-obvious choices made during this milestone; copy lasting ones into DECISIONS.md. -->
-

## Status log
<!-- Dated entries. Ending a session mid-milestone always records "stopped at / next step". -->
- YYYY-MM-DD:
