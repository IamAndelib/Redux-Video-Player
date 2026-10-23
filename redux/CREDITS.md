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
| Build environment package list | VideoLAN's [docker-images](https://code.videolan.org/videolan/docker-images) `vlc-debian-unstable` | GPL-2.0-or-later | `.devcontainer/Containerfile` (D3) |
| Video transcription | [AI-Video-Transcriber](https://github.com/wendy7756/AI-Video-Transcriber) with yt-dlp and faster-whisper | See each project | `redux/tools/transcriber/` (M0.4) |
| Media library | VideoLAN [medialibrary](https://code.videolan.org/videolan/medialibrary) 0.13.2 | LGPL-2.1-or-later | Dev image (D5) |
