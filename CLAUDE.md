# Redux Video Player: working agreement

Redux Video Player (repo `Redux-Video-Player`) is a fork of VLC master whose Qt/QML interface (`modules/gui/qt/`) is
redesigned to Juxtopposed's concept. It is a Linux-only Flatpak for offline video with maximum codec and format
support. **What ships is fixed in `redux/SCOPE.md` (D14): build only what it keeps.** The design is Figma `CAuJVJyM5yY7PnyQQK9X24`; the video's design intent is in `redux/design/brief.md` (build from this),
backed by `redux/design/transcript.md`.
Everything specific to this fork lives in `redux/`. Everything else is upstream VLC.

## Start of every session
1. Read `redux/milestones/STATUS.md`. Its "Next up" line and the `wip` rows tell you where we are.
2. Read the active milestone file `redux/milestones/M<ID>-*.md`, especially its status log. If none exists yet, look up
   the milestone in `redux/milestones/ROADMAP.md`.
3. `git status` and `git fetch upstream` (the `upstream` remote is VideoLAN's VLC; add it once with
   `git remote add upstream https://code.videolan.org/videolan/vlc.git`). Work only on the milestone's branch
   `m/M<ID>-<slug>` (D8).
4. Don't start a new milestone until the maintainer has said the previous one is good.

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

## Milestone ritual (D18)
Research → plan → implement in small commits → verify → **hand over**: rebuild, make sure "Redux Video Player (dev)"
opens from the app menu (`redux/dev.sh app`), open the PR and give the maintainer the test checklist (below) → the maintainer tests
the app and gives feedback → fix and hand over again → on "good": squash-merge, update `STATUS.md` and the
milestone's status log, then start the next milestone. Ask the maintainer during a milestone only when a gap needs
their decision. Ending mid-milestone always logs "stopped at / next step". Details: `redux/milestones/ROADMAP.md`.

**Every hand-over includes a test checklist** (copied into the milestone file's manual checklist):
1. Numbered items, each with **open** (where in the app), **do** (the action) and **expect** (what should happen).
2. Cover every user-visible change of the milestone, plus a quick regression check of what it touched.
3. Then "known not working yet" (out of scope or later milestones), so nothing is reported twice.
4. End with how to report: the item number and what you saw (a screenshot helps).

## Commands (all builds and tools run in the Podman dev container)
| What | Command |
|---|---|
| Build (first time configures) | `redux/dev.sh run redux/tools/build.sh` |
| Re-apply build options (after a `build.sh` option change) | `redux/dev.sh run redux/tools/build.sh reconfigure` |
| Rebuild only the Qt UI (~3 s) | `redux/dev.sh run redux/tools/build.sh qt` |
| Open the app on the host (persistent profile, your files read-only) | `redux/dev.sh app [file…]`, or "Redux Video Player (dev)" in the app menu |
| Add or remove the app-menu entry (host) | `redux/tools/launcher.sh install` / `uninstall` |
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
- Build only what `redux/SCOPE.md` keeps. Bringing back a cut or future feature needs a `DECISIONS.md` entry first.
- Edits outside `modules/gui/qt/` and `redux/` need a `redux/milestones/DECISIONS.md` entry.
- New QML or C++ files must be listed in both `modules/gui/qt/meson.build` and `modules/gui/qt/Makefile.am`.
- Control IDs in `player/control_list_model.hpp` are persisted: append into reserved slots only, never renumber.
- Hitting an unknown means adding it to `redux/milestones/GAPS.md`. If it blocks the milestone, stop and ask the maintainer.
- Never rewrite history (no rebase, amend or force-push on shared branches). Upstream syncs are merges.
- Keep `redux/design/source/` (Figma exports, `.fig`) out of git.
- Commit and PR titles: `M<ID>: <summary>`. Upstreamable fixes go on `up/<slug>` branches in VLC commit style.
- Don't put model identifiers in commits, PRs or code.
