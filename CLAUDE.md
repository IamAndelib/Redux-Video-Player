# Redux Video Player: working agreement

Redux Video Player (repo `VLC-Redux`) is a fork of VLC master whose Qt/QML interface (`modules/gui/qt/`) is
redesigned to Juxtopposed's concept. It is a Linux-only Flatpak for offline video with maximum codec and format
support. **What ships is fixed in `redux/SCOPE.md` (D14): build only what it keeps.** The design is Figma `CAuJVJyM5yY7PnyQQK9X24`; the video's design intent is in `redux/design/brief.md` (build from this),
backed by `redux/design/transcript.md`.
Everything specific to this fork lives in `redux/`. Everything else is upstream VLC.

## Start of every session
1. Read `redux/milestones/STATUS.md`. Its "Next up" line and the `wip` rows tell you where we are.
2. Read the active milestone file `redux/milestones/M<ID>-*.md`, especially its status log. If none exists yet, look up
   the milestone in `redux/milestones/ROADMAP.md`.
3. `git status` and `git fetch upstream`. Work only on the milestone's branch `m/M<ID>-<slug>`.
4. Don't start a new milestone until the maintainer says go.

## Philosophy
- **Slow and steady:** one milestone at a time, reviewed and merged before the next.
- **KISS:** the simplest thing that meets the acceptance criteria.
- **Don't reinvent the wheel:** reuse upstream VLC code, then established libraries, then write new code.
- **Research first:** a time-boxed research step opens every milestone and is written into its file.
- **Clean, maintainable code:** follow `modules/gui/qt/HACKING` and Qt QML practices.
  - Small focused files.
  - No duplication.
  - No magic values: use `VLCStyle`/`ColorContext` tokens.
  - Prefer new files to deep edits of upstream files.
  - Tokenize hard-coded values only in files you already touch.
- **Verify, don't assume:** nothing is "done" without the milestone's verification output.

## Milestone ritual
Research → plan (maintainer approves) → implement in small commits → verify → maintainer review on the PR →
squash-merge → update `STATUS.md` and the milestone's status log. Ending mid-milestone always logs
"stopped at / next step". Details: `redux/milestones/ROADMAP.md` ("Milestone ritual", "Definition of Done").

## Commands (all builds and tools run in the Podman dev container)
| What | Command |
|---|---|
| Build (first time configures) | `redux/dev.sh run redux/tools/build.sh` |
| Rebuild only the Qt UI (~3 s) | `redux/dev.sh run redux/tools/build.sh qt` |
| Run the player on the desktop | `redux/dev.sh run redux/tools/build.sh run` |
| Tests (Qt suite) | `redux/dev.sh run meson test -C build/meson --suite qt` |
| Test media | `redux/dev.sh run redux/tools/make-media.sh` |
| Screenshots (1920×1080, Night) | `redux/dev.sh run redux/tools/shoot.sh [scene…]` (`THEME=day` for light) |
| Diff vs Figma | `redux/dev.sh run redux/tools/compare.sh`, then open `build/shots/report.html` |
| Shell in the container | `redux/dev.sh shell` |
| Rebuild the dev image | `redux/dev.sh image` |
| Figma export (host) | `python3 -I redux/tools/figma-export.py` (token in `~/.config/vlc-redux/figma-token`) |
| Video contact sheets / picked frames | `redux/dev.sh run redux/tools/video-sheets.sh` / `video-frames.sh` (video at `redux/design/source/video.mp4`) |
| Check the design brief | `python3 -I redux/tools/check-brief.py` |
| GitHub | `gh` CLI (repo `IamAndelib/VLC-Redux`) |

## Rules
- Never install anything on the host; add it to `.devcontainer/Containerfile` and record why in `DECISIONS.md`.
- Edits outside `modules/gui/qt/` and `redux/` need a `redux/milestones/DECISIONS.md` entry.
- New QML or C++ files must be listed in both `modules/gui/qt/meson.build` and `modules/gui/qt/Makefile.am`.
- Control IDs in `player/control_list_model.hpp` are persisted: append into reserved slots only, never renumber.
- Hitting an unknown means adding it to `redux/milestones/GAPS.md`. If it blocks the milestone, stop and ask the maintainer.
- Never rewrite history (no rebase, amend or force-push on shared branches). Upstream syncs are merges.
- Keep `redux/design/source/` (Figma exports, `.fig`) out of git.
- Commit and PR titles: `M<ID>: <summary>`. Upstreamable fixes go on `up/<slug>` branches in VLC commit style.
- Don't put model identifiers in commits, PRs or code.
