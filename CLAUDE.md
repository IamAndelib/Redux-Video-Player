# Redux Video Player: working agreement

Redux Video Player (repo `Redux-Video-Player`) is a fork of VLC master whose Qt/QML interface (`modules/gui/qt/`) is
redesigned to Juxtopposed's concept. It is a Linux-only Flatpak for offline video with maximum codec and format
support. **What ships is fixed in `redux/SCOPE.md` (D14): build only what it keeps.** The design is Figma `CAuJVJyM5yY7PnyQQK9X24`; the video's design intent is in `redux/design/brief.md` (build from this),
backed by `redux/design/transcript.md`.
Everything specific to this fork lives in `redux/`. Everything else is upstream VLC.

## Start of every session
1. Read `redux/milestones/STATUS.md`. Its "Next up" line and the `wip` rows tell you where we are.
2. Find your milestone: the open issue assigned to you (`gh issue list --assignee @me`); otherwise the "Next up" one.
   Never work on a milestone assigned to someone else (D25; a collaborator works alongside the maintainer).
3. Read its file `redux/milestones/<ID>-*.md` (`M…` or `Q…`), especially the status log. If none exists yet, look
   up the milestone in `redux/milestones/ROADMAP.md`.
4. `git status` and `git fetch upstream` (the `upstream` remote is VideoLAN's VLC; add it once with
   `git remote add upstream https://code.videolan.org/videolan/vlc.git`; if it stalls, G23, use the GitHub mirror
   `https://github.com/videolan/vlc.git`). Work only on the milestone's branch `m/<ID>-<slug>` (D8).
5. Milestones run back to back (D26): when one is merged, claim the next by assigning yourself its issue and start.

## Philosophy
- **Slow and steady:** one milestone at a time, reviewed and merged before the next.
- **KISS:** the simplest thing that meets the acceptance criteria.
- **Don't reinvent the wheel; steal like an artist:** before building or experimenting with anything, search for
  the best existing open-source implementation (upstream VLC and its MRs, other players such as mpv, IINA, Haruna,
  Celluloid and MPC-HC, KDE/Qt components, established libraries and test suites) and adopt it, with credit in
  `redux/CREDITS.md`. Write new code only when nothing fits.
- **Research first:** a time-boxed research step opens every milestone and is written into its file, including
  what prior art was found and what was adopted.
- **Clean, maintainable code:** follow `modules/gui/qt/HACKING` and Qt QML practices.
  - Small focused files.
  - No duplication.
  - No magic values: use `VLCStyle`/`ColorContext` tokens.
  - Prefer new files to deep edits of upstream files.
  - Tokenize hard-coded values only in files you already touch.
- **Verify, don't assume:** nothing is "done" without the milestone's verification output.

## Discipline (D28)
- **IDs everywhere:** Track → Milestone (`Q0.1`) → Task (`Q0.1-T3`, the milestone file's task table) → commit
  (`Q0.1: T3 <summary>`). Findings are `F1`…, gaps `G…`, decisions `D…`, brief items `C3`/`P9`, scope items `K7`/`X2`;
  code comments cite the decision or gap they implement (`/* D21: … */`).
- **Priorities:** P0 crash/data loss/broken build, P1 wrong in-scope behaviour or regression (both block a merge),
  P2 robustness/maintainability, P3 polish (`redux/agents/README.md`; GitHub labels `priority:P0`–`P3`).
- **Agents:** you are the lead: plan, decide, merge. Give each specialist agent one bounded job with its brief from
  `redux/agents/` (researcher, reviewer, QA triager), run independent jobs in parallel, and answer every finding.

## Working together (D25)
- GitHub issues are the work queue; the assignee is who works on it. One milestone per person at a time, and never
  two open milestones that edit the same files. Human contributors start at `.github/CONTRIBUTING.md`.
- Open a draft PR early (`Closes #<issue>`); feedback and bugs live in issues and PRs, not only in chat.
- Questions for the maintainer: comment on the issue with the `needs-user` label.

## Milestone ritual (D18, amended by D23 and D26)
Research → plan → implement in small commits → **QC** → PR → squash-merge → update `STATUS.md` and the milestone's
status log → start the next milestone (D26: the maintainer evaluates the complete project at the end, not each
milestone). **QC before every merge:** CI green on the PR (D29: `ci.yml` runs the QA suite; `flatpak.yml` builds the
Flatpak and plays the matrix in it when code or packaging changed); locally: the build; VLC's test suite (`meson test -C build/meson`); the codec matrix;
the Flatpak build and `flatpak.sh matrix` when packaging or `src/`/`modules/` outside the Qt UI changed; the QA suite
(`redux/tools/qa.sh`) as Track Q builds it; an independent review agent on the diff; fix and re-run until green, and
record the results in the PR and the milestone file. Keep "Redux Video Player (dev)" working (`redux/dev.sh app`).
A gap that needs the maintainer's decision is filed with `needs-user`; move on to a milestone it doesn't block. Ending
mid-milestone always logs "stopped at / next step" and is pushed, so anyone can resume. Details:
`redux/milestones/ROADMAP.md`; QA: `redux/QA.md` (D23).

**Every milestone adds its hand checks to `redux/EVALUATION.md`** (the maintainer's final evaluation script), in
this format:
1. One section per milestone; items with an ID (`M2.1-3`), **open** (where in the app), **do** (the action) and
   **expect** (what should happen).
2. Only what a person must judge at a real desktop (sound, GPU, feel, looks); the QA suite covers the rest.
3. Hand checks use media at least 30 s long (e.g. `build/media/`), never the 2 s matrix clips.

## Commands (all builds and tools run in the Podman dev container)
| What | Command |
|---|---|
| Build (first time configures) | `redux/dev.sh run redux/tools/build.sh` |
| Re-apply build options (after a `build.sh` option change) | `redux/dev.sh run redux/tools/build.sh reconfigure` |
| Rebuild only the Qt UI (~3 s) | `redux/dev.sh run redux/tools/build.sh qt` |
| Open the app on the host (persistent profile, your files read-only) | `redux/dev.sh app [file…]`, or "Redux Video Player (dev)" in the app menu |
| Add or remove the app-menu entry (host) | `redux/tools/launcher.sh install` / `uninstall` |
| Flatpak: build and install, run, lint, codec matrix in the sandbox (host) | `redux/tools/flatpak.sh build` / `run` / `lint` / `matrix` |
| Run the player with a throwaway profile | `redux/dev.sh run redux/tools/build.sh run` |
| Tests (Qt suite) | `redux/dev.sh run meson test -C build/meson --suite qt` |
| Test media | `redux/dev.sh run redux/tools/make-media.sh` |
| Codec/format matrix (generate, fetch real samples, play all) | `redux/dev.sh run redux/tools/make-matrix.sh`, `redux/tools/fetch-samples.sh`, `redux/dev.sh run redux/tools/play-matrix.sh` |
| Screenshots (1920×1080, Night) | `redux/dev.sh run redux/tools/shoot.sh [scene…]` (`THEME=day` for light) |
| Diff vs Figma | `redux/dev.sh run redux/tools/compare.sh`, then open `build/shots/report.html` |
| Shell in the container | `redux/dev.sh shell` |
| Rebuild the dev image | `redux/dev.sh image` |
| Figma export (host) | `python3 -I redux/tools/figma-export.py` (token in `~/.config/vlc-redux/figma-token`) |
| Video contact sheets / picked frames | `redux/dev.sh run redux/tools/video-sheets.sh` / `video-frames.sh` (video at `redux/design/source/video.mp4`) |
| Check the design brief | `python3 -I redux/tools/check-brief.py` |
| GitHub | `gh` CLI (repo `IamAndelib/Redux-Video-Player`) |

## Rules
- Never install anything on the host; add it to `.devcontainer/Containerfile` and record why in `DECISIONS.md`.
- Testing on the maintainer's desktop is allowed (maintainer, 2026-10-24): `redux/dev.sh app` and the Flatpak
  (`redux/tools/flatpak.sh run`) for what headless runs can't judge (GPU decoding, sound, looks). Say so before a
  window opens; automated checks stay headless. The build can't run natively on the host (Debian sid libraries).
- Build only what `redux/SCOPE.md` keeps. Bringing back a cut or future feature needs a `DECISIONS.md` entry first.
- Edits outside `modules/gui/qt/` and `redux/` need a `redux/milestones/DECISIONS.md` entry.
- New QML or C++ files must be listed in both `modules/gui/qt/meson.build` and `modules/gui/qt/Makefile.am`.
- Control IDs in `player/control_list_model.hpp` are persisted: append into reserved slots only, never renumber.
- Hitting an unknown means adding it to `redux/milestones/GAPS.md`. If it blocks the milestone, stop and ask the maintainer.
- Never rewrite history (no rebase, amend or force-push on shared branches). Upstream syncs are merges.
- Keep `redux/design/source/` (Figma exports, `.fig`) out of git.
- Commit and PR titles: `<ID>: <summary>` (`M2.1: …`, `Q0.1: T3 …`). Upstreamable fixes go on `up/<slug>` branches in VLC commit style.
- Don't put model identifiers in commits, PRs or code.
