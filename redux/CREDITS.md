# Credits

Redux Video Player stands on other people's work. We adopt the best existing open-source implementation of an idea
instead of writing our own ("steal like an artist", `CLAUDE.md`), and every adopted piece is credited here: what we
took, where from, its licence, and where it lives in this repo.

## Product
| What | From | Licence | Used for |
|---|---|---|---|
| The player engine and its Qt/QML interface | [VLC](https://www.videolan.org/vlc/) by VideoLAN and contributors | GPL-2.0-or-later / LGPL-2.1-or-later | The whole tree outside `redux/` |
| The redesign | [Juxtopposed](https://www.youtube.com/@juxtopposed), "I Redesigned VLC After 25 Years" ([video](https://youtu.be/ERFeOgqk324), [Figma](https://www.figma.com/design/CAuJVJyM5yY7PnyQQK9X24/VLC-Redesign--Community-)) | Released as open source and free to use | `redux/design/`, every UI milestone |

## Development and testing
| What | From | Licence | Used for |
|---|---|---|---|
| End-of-playback behaviour (stay on the last frame) | [mpv](https://mpv.io)'s `keep-open` option, as the model; built with VLC's own `play-and-pause` | GPL-2.0-or-later (idea only, no code) | `modules/gui/qt/playlist/playlist_controller.cpp` (M0.6) |
| Flatpak module set and plugin-cache step | Flathub [org.videolan.VLC](https://github.com/flathub/org.videolan.VLC) (branch `mv/test-alpha`, Mathieu Velten et al.) and VLC [MR !10454](https://code.videolan.org/videolan/vlc/-/merge_requests/10454) | See each repo | `redux/packaging/` (M0.7) |
| Flatpak FFmpeg, libplacebo and libass modules | Flathub [io.mpv.Mpv](https://github.com/flathub/io.mpv.Mpv) | See the repo | `redux/packaging/` (M0.7) |
| Flatpak permissions | Flathub [org.kde.haruna](https://github.com/flathub/org.kde.haruna) | See the repo | `redux/packaging/` (M0.7) |
| Real-world media samples | [FFmpeg FATE suite](https://fate-suite.ffmpeg.org) | Samples as published by FFmpeg for testing | `redux/tools/samples.tsv`, `fetch-samples.sh`, the codec/format matrix (M0.6) |
| Synthetic test media | [FFmpeg](https://ffmpeg.org) (`lavfi` sources and encoders) | LGPL/GPL | `make-media.sh`, `make-matrix.sh` |
| Flatpak CI build | [flatpak/flatpak-github-actions](https://github.com/flatpak/flatpak-github-actions) and Flathub's [actions images](https://github.com/flathub-infra/actions-images) | MIT | `.github/workflows/flatpak.yml` (Q0.7) |
| Flatpak linting | [flathub/flatpak-builder-lint](https://github.com/flathub/flatpak-builder-lint) | MIT | `.github/workflows/flatpak.yml` (Q0.7) |
| CI caching pattern (prebuilt CI image, ccache restored by prefix, saved from the main branch) | [mpv](https://github.com/mpv-player/mpv/blob/master/.github/workflows/build.yml)'s workflow | idea only, no code | `.github/workflows/ci.yml` (Q0.7) |
| Installing the built bundle and running it in CI | [Bottles](https://github.com/bottlesdevs/Bottles/blob/main/.github/workflows/build_flatpak.yml) | idea only, no code (GPL-3) | `.github/workflows/flatpak.yml` (Q0.7) |
| Headless KDE session recipe (KWin virtual backend, private session bus, AT-SPI bus, screenshot permission override) and the ScreenShot2 client pattern | KDE [selenium-webdriver-at-spi](https://github.com/KDE/selenium-webdriver-at-spi) (`run.rb`, `screenshotter`; Harald Sitter and KDE) | idea only, no code (AGPL-3 / GPL) | `redux/tools/kwin-session.sh`, `kwin-shot.py` (Q0.2) |
| Headless compositor and its virtual backend | [KWin](https://invent.kde.org/plasma/kwin) (KDE) | GPL-2.0-or-later (used as a program) | the dev image, `kwin-session.sh` (Q0.2) |
| Running a Wayland client under a headless KWin | [xwayland-run / wlheadless-run](https://gitlab.freedesktop.org/ofourdan/xwayland-run) (Olivier Fourdan) | idea only, no code (GPL-2) | `redux/tools/kwin-session.sh` (Q0.2) |
| GitHub Actions building blocks | [actions/checkout, cache, upload-artifact, download-artifact](https://github.com/actions) | MIT | `.github/workflows/` (Q0.7) |
| Build environment package list | VideoLAN's [docker-images](https://code.videolan.org/videolan/docker-images) `vlc-debian-unstable` | GPL-2.0-or-later | `.devcontainer/Containerfile` (D3) |
| Video transcription | [AI-Video-Transcriber](https://github.com/wendy7756/AI-Video-Transcriber) with yt-dlp and faster-whisper | See each project | `redux/tools/transcriber/` (M0.4) |
| Media library | VideoLAN [medialibrary](https://code.videolan.org/videolan/medialibrary) 0.13.2 | LGPL-2.1-or-later | Dev image (D5) |
