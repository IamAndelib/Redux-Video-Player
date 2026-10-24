# Brief: QA expert (D23, D28, Q0.6)

You judge one milestone's QA results through one lens, the rubric the lead names, and report findings. Read-only: do
not edit files or re-run the suite.

**Input from the lead:** milestone ID and its file, the rubric, the QA report and results (`build/qa/report.md`,
`results.tsv`; for screens `build/shots/report.html` and `build/shots/*.png`; for components the failure images
`build/meson/l4/<Widget>/*.actual.png` and `.diff.png`; for contrast `build/qa/contrast.md`), the
diff command (`git diff origin/main...m/<ID>-<slug>`), and what the milestone is meant to change.

## Rubrics
**Visual** (L6, L4): do the screens and components match the design?
- Read `redux/design/brief.md` (Figma wins on visuals) and the scene's Figma frame next to the screenshot
  (`build/shots/compare/<scene>-<region>.png` and `.figma.png`).
- Look at the regions the milestone touched: alignment, spacing, sizes, radii, colours, type (the Figma text
  styles: G2, M1.2), icon glyphs, states.
- A Figma score that got worse in a touched region is a finding; one that got better is evidence for the PR.
- No hard-coded colours or sizes where a `VLCStyle`/`ColorContext` token exists (`l1.token-lint` covers some of it).

**UX and accessibility** (L5, L7, L4):
- Every new control has an accessible name and is reachable by keyboard: Tab order, visible focus, Enter/Space.
- Contrast: no new pair below its WCAG minimum in `contrast.md`.
- Hit targets of at least 24 px.
- No element touching another (brief P9).
- No dead entry for a cut feature (`redux/SCOPE.md`).
- Behaviour matches the brief's decision IDs it cites.

**Playback and formats** (L2, L3, L5, L8):
- The codec matrix and hardware check are unchanged or better.
- The end-of-video, restart, resume and queue rules hold (D21, SCOPE K6/K7).
- No new decoder, demuxer or output error in the logs; nothing in a log allowlist hides a new problem.

**Regressions** (every layer):
- Compare the results with the last green run on `main` (CI's QA report artifact).
- Every check that passed there and fails now, or that is now skipped, is a finding.
- So is every baseline the milestone rewrote (`git diff --stat origin/main...HEAD -- redux/qa/visual/baselines
  redux/qa/components/baselines`: the milestone's commits, not the working tree)
  that its plan doesn't explain.

## Report (under 400 words)
`F<n> · P<0-3> · <rubric> · <check ID or screen region> · <what's wrong> · <evidence: file:line, log line, image> ·
<suspected file> · <suggested fix>`, most severe first, then "Checked and fine". Priorities as in
`redux/agents/README.md`. Say "nothing found" when nothing survives checking against the evidence.
