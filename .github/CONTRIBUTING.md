# Contributing to Redux Video Player

Thanks for helping. This is a fork of VLC 4 whose Qt/QML interface is being redesigned, shipped as a Linux Flatpak.
Everything specific to the fork lives in `redux/`; everything else is upstream VLC. The maintainer is
[@IamAndelib](https://github.com/IamAndelib), who reviews and merges every PR.

## 1. Read first (15 minutes)
1. [`redux/SCOPE.md`](../redux/SCOPE.md): what ships and what is cut. Build only what it keeps.
2. [`redux/milestones/ROADMAP.md`](../redux/milestones/ROADMAP.md) § Working philosophy: KISS, reuse existing
   open-source work before writing new code, research first, verify before calling anything done.
3. [`CLAUDE.md`](../CLAUDE.md): the working agreement, commands and rules. It applies to people too, not only to
   Claude Code sessions (if you use Claude Code, it loads this file automatically).
4. [`redux/design/brief.md`](../redux/design/brief.md) when you touch the UI: the design's reasoning, decision by decision.

## 2. Set up
The host needs only `podman` and `git`; everything builds in a container
([`redux/README.md`](../redux/README.md) has the details).

```bash
git clone https://github.com/IamAndelib/Redux-Video-Player.git && cd Redux-Video-Player
redux/dev.sh image                          # the dev container (Debian sid, Qt 6.11)
redux/dev.sh run redux/tools/build.sh       # first build (configures, then builds; ccache makes rebuilds fast)
redux/dev.sh app                            # open the built player on your desktop
redux/dev.sh run redux/tools/make-media.sh  # test media in build/media/
```

## 3. Find work
- **Where things stand:** [`redux/milestones/STATUS.md`](../redux/milestones/STATUS.md) (its "Next up" line) and the
  [open issues](https://github.com/IamAndelib/Redux-Video-Player/issues). Each milestone has one issue with its
  goal, key files and acceptance criteria; GitHub milestones R0–R3 are the release gates.
- **Good places to start:** issues labelled `good first issue`, `help wanted` or `gap` (open questions with a
  "what would help" note), and `qa` (tests and harness).
- **A milestone is ready** when the milestones it depends on are done (the roadmap gives the order).
- **Not up for grabs:** issues assigned to someone else, and anything labelled `cut` or `future`.

## 4. Claim it
1. Assign yourself on the issue (`gh issue edit <n> --add-assignee @me`) and leave a short comment. The assignee is
   who is working on it; there are no other locks.
2. One milestone per person at a time. Don't take a milestone that edits the same files as someone else's open one;
   ask on the issue if unsure.
3. Questions only the maintainer can answer: comment on the issue, mention @IamAndelib and add the `needs-user` label.

## 5. Do it
1. Branch from `main`: `m/<ID>-<slug>` (e.g. `m/Q0.1-qa-foundations`, `m/M1.1-night-palette`).
2. Create `redux/milestones/<ID>-<slug>.md` from [`TEMPLATE.md`](../redux/milestones/TEMPLATE.md) and set the
   milestone's row in `STATUS.md` to `research`, then `wip`.
3. Research first and write it into the milestone file: upstream VLC and its MRs, other players, existing libraries.
   Credit what you adopt in [`redux/CREDITS.md`](../redux/CREDITS.md).
4. List the milestone's tasks in its file's task table (`<ID>-T1`, `-T2` …, each with a priority P0–P3, see
   [`redux/agents/README.md`](../redux/agents/README.md)). Small commits titled `<ID>: T<n> <summary>`. Open a
   **draft PR** early with `Closes #<issue>` so progress is visible.
5. Unknowns go into [`GAPS.md`](../redux/milestones/GAPS.md); lasting choices into
   [`DECISIONS.md`](../redux/milestones/DECISIONS.md) (needed for any edit outside `modules/gui/qt/` and `redux/`).
6. Never rewrite shared history: no rebase, amend or force-push on pushed branches. Bring in `main` with a merge.

## 6. Hand over
1. Fill in the milestone file's Verification table with real command output, and add the checks only a person can
   judge (sound, GPU, feel, looks) to [`redux/EVALUATION.md`](../redux/EVALUATION.md).
2. Mark the PR ready for review. From M0.8 on, attach the QA report (`redux/tools/qa.sh`, see
   [`redux/QA.md`](../redux/QA.md)).
3. The maintainer, or the maintainer's Claude session after its QC pass (D26), reviews and squash-merges. Don't
   merge your own PR.
4. If you stop mid-milestone, add a dated "stopped at / next step" line to the milestone file's status log and push,
   so anyone can pick it up.

## Reporting bugs and feedback
Open an issue with the **Bug or feedback** template: where in the app, what you did, what you expected, what you saw
(a screenshot helps), and whether it was the dev build or the Flatpak. Feedback on a milestone under review goes on
its PR instead.
