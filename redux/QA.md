# Redux QA plan

Adopted by the maintainer on 2026-10-23 (D23, amends D18; D26). Track Q (Q0.1–Q0.7 in
[`milestones/ROADMAP.md`](milestones/ROADMAP.md)) builds it after M0.7 and before M0.8, in the order
Q0.1 → Q0.7 (CI) → Q0.2 → Q0.3 → Q0.4 → Q0.5 → Q0.6.

## Goal
Every milestone is checked automatically for function, UI/UX against the design, and the sandbox, by agents that
test, report, fix and re-test until green. The maintainer evaluates the complete prototype at the end, plus
occasional spot checks of what only a real desktop shows: audio, GPU and feel.

## Principles (same as the project's)
- **Adopt existing tools, write none if one fits:** KDE's `selenium-webdriver-at-spi`, Qt Quick Test,
  openQA-style screenshot needles, VLC's own tests and the FFmpeg FATE samples.
- **Tests come from the docs:** every [`design/brief.md`](design/brief.md) decision, [`SCOPE.md`](SCOPE.md) item and
  milestone acceptance criterion becomes a test case, so coverage is measurable.
- **Deterministic first:** headless, fixed fonts, fixed window size, fixed test media. Flaky tests are fixed, never
  skipped (G25 is the first one).

## The layers
| Layer | What it proves | Tool (adopted) | Built in |
|---|---|---|---|
| L1 Build and hygiene | builds; no QML warnings or errors; no crashes, including on quit; cut plugins absent | meson, log scanners | Q0.1 |
| L2 Codecs and formats | every format in scope opens and decodes | `play-matrix.sh` (79 files), also inside the Flatpak (`flatpak.sh matrix`) | M0.6, M0.7 |
| L3 Player core | playback rules (end of video, restart, resume, queue, A-B, frame step) | VLC's `test/src/player` plus new C tests for our changes (D21) | exists; grows per milestone |
| L4 Components | each QML widget in every state and theme (hover, pressed, focus, disabled; Night, Day, System) | Qt Quick Test (`qml_test.cpp` with `VLC.Style` and a stub `MainCtx`) | Q0.5 |
| L5 End-to-end flows | real user journeys in the real app: open, play, seek, tracks, subtitles, library, settings, Customize, onboarding | `selenium-webdriver-at-spi` driving the container build under a headless `kwin_wayland --virtual` session | Q0.2, Q0.3 |
| L6 Visual fidelity | screens match Figma per region; spacing, colours, radii and fonts follow tokens | `shoot.sh` + `compare.sh` (region RMSE with masks), KWin ScreenShot2 for chrome and shadows, token linter | Q0.1 (lint), Q0.4 |
| L7 UX heuristics | keyboard reachability, focus order, contrast (WCAG AA), hit-target sizes, no element touching another (principle 9), no dead entries for cut features | AT-SPI tree audit, contrast check on every `ColorContext` set × state × theme, layout-overlap check | Q0.3, Q0.4 |
| L8 Sandbox | Flatpak permissions, portal file dialog, MPRIS, VA-API inside the sandbox | `flatpak.sh matrix` (the codec matrix inside the installed bundle; in CI: `flatpak.yml`, D29), `flatpak.sh run` + log checks (the AT-SPI driver can't attach to a Flatpak) | Q0.7 (matrix in CI); checks grow per milestone |
| L9 Agent review | an "expert QA" agent reads the screenshots against the brief and Figma frames and files findings | review agents with a fixed rubric | Q0.6 |

L5 and L7 start non-blocking and become blocking once they have run green and stable.

## Test case sources (traceability)
- **Stable IDs in the source documents.** The brief's principles are P1–P9 and its decision entries carry their
  section letter (`- **C3** · …`); SCOPE.md's kept features are K1… (an ID column) and its cuts X1…. IDs are never
  renumbered: a new entry takes the next free number (`check-brief.py` enforces unique brief IDs).
- **Cases** live in `redux/qa/cases/*.yaml`, one file per area. One case per brief decision, scope item or acceptance
  criterion it proves; `redux/qa/report.py` validates them on every run.
- **Coverage:** the report lists every brief and scope ID with its cases and their status, and the milestone that
  plans the item, so gaps are visible per milestone.
- **One entry point:** `redux/dev.sh run redux/tools/qa.sh [L1 L2 L3]` runs every layer built so far and writes
  `build/qa/report.md` (exit 0 green, 1 a check failed, 2 an invalid case).

## Test case format
```yaml
- id: L3-restart-after-end            # unique; <layer>-<slug>, or the EVALUATION.md item ID for hand checks
  title: Play on a finished video starts it from the beginning
  layer: L3                           # L1–L9
  milestone: Q0.1                     # the milestone that added the case (an ID in ROADMAP.md)
  sources: [scope:K7, decision:D21]   # brief:<P1|C3…>, scope:<K…|X…>, decision:<D…>, accept:<milestone>,
                                      # dod:<build-and-tests|keyboard|qml-clean|tokens|spacing|status-log|crops|qa-green>
  steps: [ ... ]                      # optional, for anything not obvious from the check
  expected: resuming at the end plays from near 0; after a seek it resumes from the seek position.
  check: l3.test_src_player_eof       # a result ID from qa.sh (globs allowed: l3.test_src_player_*),
                                      # or manual:<EVALUATION.md item> for a hand check
  figma: 2151:9673                    # optional: the Figma node it comes from
  frame: 0323-control-bar-one-row.jpg # optional: the video frame (redux/design/frame-picks.tsv)
```
Check IDs: `l1.build`, `l1.cut-plugins`, `l1.startup.night|day`, `l1.quit`, `l1.token-lint`, `l1.kwin-session`, `l1.kwin-screenshot`, `l2.matrix`,
`l3.<meson test name>`, `l5.<module>.<Class>.<test>` (Q0.3), `l8.flatpak-matrix` (host, from Q0.7 in CI). Errors the headless X server causes (no GPU)
are allowed only through `redux/qa/log-allowlist.txt`, each with its reason.

**Headless KDE session (Q0.2, D30):** `redux/tools/kwin-session.sh <cmd>` runs a command as a Wayland client in
KWin's virtual backend (software rendering, OpenGL compositing on the GPU or `vgem`); `redux/tools/kwin-shot.py
<out.png>` takes a screenshot inside it. Checks `l1.kwin-session` (runs everywhere) and `l1.kwin-screenshot`
(skipped without a DRM render node, e.g. on GitHub's runners, G27). `REDUX_NO_GPU=1 redux/dev.sh …` reproduces a GPU-less CI runner.

**End-to-end flows (Q0.3, D31):** `redux/dev.sh run redux/tools/qa.sh L5` (opt-in, non-blocking) runs
`redux/qa/e2e/test_*.py` in that session: each test class launches the player through KDE's AT-SPI WebDriver with a
throw-away profile. Assert on behaviour with `mpris()` and on what the user sees and reaches with `element()`/`press()`
by accessible name; wait with `wait_for()`, never a fixed sleep. Hidden controls aren't reachable: call
`reveal_controls()` first. A failing test leaves a screenshot and the player's log in `$QA_OUT/l5/` (`build/qa/l5/`; in CI `build/qa-e2e/l5/`).

## The agent loop (per milestone)
1. **Generate:** a test-writer agent adds or updates cases from the milestone's scope and the brief.
2. **Run:** the full suite in the container, then the Flatpak subset.
3. **Triage:** expert agents for UI/visual, UX/accessibility, playback/formats and regressions read the results and
   screenshots and file findings (severity, evidence, suspected file).
4. **Fix:** a fix agent addresses the findings in the milestone branch.
5. **Re-run** until green, with a cap on rounds; anything unresolved goes to `milestones/GAPS.md` and is flagged to
   the maintainer.
6. **Report:** a QA report per PR (pass/fail per layer, screenshots, visual diffs, coverage).

## What stays with the maintainer
- **Final prototype evaluation**, with a short guided script.
- **Rare real-desktop spot checks**, e.g. "does it sound right on your headphones", "does the window look right under
  KWin". These come as an optional 2–3 item list in the hand-over, not a full checklist.

## Definition of Done (from M0.8)
The milestone's cases are written alongside its code, and the QA suite is green with its report attached to the PR.
Since D26, Claude runs the QC and merges; hand checks go into [`EVALUATION.md`](EVALUATION.md) for the maintainer's
final evaluation of the complete project.

## Risks
- **Headless Wayland plus KWin in a container is fiddly.** The fallback is Xvfb for most checks and the maintainer's
  desktop for chrome and shadows. Grim doesn't work on KWin; screenshots use KWin's ScreenShot2 interface.
- **AT-SPI needs good accessible names.** VLC 4 has many; adding missing ones is part of each UI milestone, and also
  improves accessibility.
- **Visual diffs against Figma are noisy.** Region crops, masked video areas and tolerance thresholds help; the agent
  review handles judgement calls. openQA itself is not adopted: region RMSE with masks covers the need.
- **`selenium-webdriver-at-spi` has no releases.** It is built from a pinned commit in the dev image.
