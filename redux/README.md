# Redux Video Player: development environment

Redux Video Player is a lean, Linux-only Flatpak video player built on VLC 4. Design by
[Juxtopposed](https://www.youtube.com/@juxtopposed); built on [VLC](https://www.videolan.org/vlc/) by VideoLAN.
Not affiliated with or endorsed by VideoLAN.

Everything builds and runs inside Podman containers. The host needs only `podman` and `git`.
Product scope (what ships): [`SCOPE.md`](SCOPE.md). Planning and progress: [`milestones/ROADMAP.md`](milestones/ROADMAP.md) (what and in which order), [`milestones/STATUS.md`](milestones/STATUS.md)
(where we are), [`milestones/GAPS.md`](milestones/GAPS.md) and [`milestones/DECISIONS.md`](milestones/DECISIONS.md). Session rules are in [`../CLAUDE.md`](../CLAUDE.md);
the original scope assessment is in [`../PLAN.md`](../PLAN.md).

## Dev container

| Command | What it does |
|---|---|
| `redux/dev.sh image` | Builds `localhost/vlc-redux-dev`: Debian sid with VideoLAN's own CI build dependencies (Qt 6.11, meson, GCC, Clang) plus ccache, Xvfb, ImageMagick, ffmpeg and the QML tools. It benchmarks Debian mirrors first and uses the fastest. |
| `redux/dev.sh shell` | Interactive shell in the container. |
| `redux/dev.sh run <cmd...>` | Runs one command in the container. |

- The repo is mounted at `/workspace`, and commands run as your own user, so files you create stay owned by you.
- ccache persists in the `vlc-redux-ccache` volume.
- Your Wayland/X11 display, PipeWire/PulseAudio and GPU (`/dev/dri`) are passed through, so the built player shows up on your desktop and plays sound.
- **Forcing a mirror:** run `DEBIAN_MIRROR=https://… redux/dev.sh image`. Otherwise `redux/tools/fastest-debian-mirror.sh` picks one on the first build and saves it in `build/debian-mirror`, so later builds reuse the cached layers (delete the file to re-pick).
- **VS Code / devcontainer CLI:** `.devcontainer/devcontainer.json` uses the same Containerfile.

Smoke test, which should print `platform=wayland graphicsApi=OpenGL`:

```bash
redux/dev.sh run qml6 redux/tools/smoke.qml                                        # on your display
redux/dev.sh run env QT_QPA_PLATFORM=xcb xvfb-run -a qml6 redux/tools/smoke.qml    # headless
```

## Build, run, screenshot

```bash
redux/dev.sh run redux/tools/build.sh             # configure (first time) and build VLC
redux/dev.sh run redux/tools/build.sh reconfigure # re-apply build options after changing build.sh
redux/dev.sh run redux/tools/build.sh qt          # rebuild only the Qt interface plugin
redux/dev.sh app [file...]                        # open the built player on your desktop (persistent profile in build/app-home)
redux/tools/launcher.sh install                   # on the host: add "Redux Video Player (dev)" to the app menu
redux/dev.sh run redux/tools/build.sh run         # start the player with a throwaway profile
redux/dev.sh run redux/tools/make-media.sh        # synthetic test media in build/media
redux/dev.sh run redux/tools/make-matrix.sh       # codec/format matrix in build/matrix
redux/tools/fetch-samples.sh                      # real samples from FFmpeg's FATE suite into build/matrix/real
redux/dev.sh run redux/tools/play-matrix.sh       # play the whole matrix headless; report in build/matrix/report.tsv
redux/dev.sh run redux/tools/shoot.sh             # 1920x1080 screenshots in build/shots (THEME=day for light)
redux/dev.sh run redux/tools/compare.sh           # diff against Figma; open build/shots/report.html
python3 -I redux/tools/figma-export.py            # on the host: Figma frames/icons into redux/design/source
python3 -I redux/tools/check-brief.py             # check the design brief's links, frames and coverage
```

## Video transcripts

`redux/tools/transcriber/transcribe.sh <youtube-url> [--whisper-model medium]` runs
[AI-Video-Transcriber](https://github.com/wendy7756/AI-Video-Transcriber) in its own container. That container has yt-dlp with Deno for YouTube's player challenges, and faster-whisper running locally.

- Output goes to `redux/design/transcript/`, which git ignores.
- The curated transcript of the designer's video is committed as `redux/design/transcript.md`. The design guide built
  from it is `redux/design/brief.md`.
- Reference frames: put the video at `redux/design/source/video.mp4`, then run `redux/dev.sh run redux/tools/video-sheets.sh`
  (contact sheets for review) and `redux/dev.sh run redux/tools/video-frames.sh` (the frames listed in
  `redux/design/frame-picks.tsv`). Both write under the git-ignored `redux/design/source/`.
