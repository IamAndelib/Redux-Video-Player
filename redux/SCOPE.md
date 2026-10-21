# Redux Video Player: product scope

**Redux Video Player** is a Linux-only Flatpak video player built on VLC 4. It plays offline video files with the
widest codec and format support we can ship, in Juxtopposed's redesigned interface. It keeps the best of VLC and
leaves out what most people never use.

This file is the source of truth for what ships (decision D14). Every milestone in
[`milestones/ROADMAP.md`](milestones/ROADMAP.md) builds only what is kept here. To bring a cut or future feature
back, add a `DECISIONS.md` entry first, then a milestone.

- **Platform:** Linux only, as a Flatpak (D13). No Windows, macOS or AppImage.
- **Codecs:** a current FFmpeg bundled in the Flatpak, plus dav1d, libplacebo and libass (D15). VA-API hardware
  decoding.
- **Name:** Redux Video Player (D16). "VLC" and the cone are VideoLAN trademarks. Repo `IamAndelib/Redux-Video-Player`,
  app ID `io.github.iamandelib.Redux-Video-Player`. UI strings that say "VLC" in the design become "Redux Video Player".
- **How cuts are made:** the module is switched off in the build (M0.6) and its entry points are removed from the UI
  (M0.8). Upstream code is never deleted, so upstream merges stay easy.

## Keep

### Playback
| Feature | Notes | Milestone |
|---|---|---|
| Play, pause, stop, previous, next, seek | One-row bar, thick seek bar | M2.1 |
| Volume, mute, boost above 100% | Cone control | M2.2 |
| Fullscreen with edge-hover bars, Hide UI | | M2.5 |
| Resume where you left off | Per file, reliable; a top VLC complaint | M2.5, M2.7 |
| Auto-next through the folder | Upstream #22382, one of the most-upvoted requests | M2.7 |
| Stay on the player when the last video ends (paused on its last frame, like mpv's keep-open); a queue still plays through | Maintainer feedback | M0.6 (done) |
| Play on a finished video starts it from the beginning | Maintainer feedback, D21 | M0.6 (done) |
| Mouse wheel: volume or seek (setting) | | M2.7 |
| Speed, repeat, shuffle | | M5.5, M4.1 |
| A-B loop, frame stepping forward and back | Learners, animators, analysts | M5.5 |
| Bookmarks and chapters (queue-panel tabs, Ctrl+B) | D12 | M5.5 |
| Snapshot | | M4.1 |
| Picture-in-picture | Floating mini video | M3.5, M4.1 |

### Tracks, subtitles and effects
| Feature | Notes | Milestone |
|---|---|---|
| Audio, subtitle and video track popup; audio output device | | M2.4 |
| External subtitle files, delay and sync sliders, styling, default language | ASS/SSA through libass | M5.4 |
| Add Subtitles to a file, folder or playlist (auto and manual matching) | Local files | M5.6 |
| Online subtitle search (OpenSubtitles) | Native Qt client; off until the user consents | M5.7 |
| Subtitle timeline on the seek bar | Research spike | M5.8 |
| Equalizer with presets, normalization, boost | | M5.2 |
| Compressor, spatializer, stereo widener, pitch | | M5.2 |
| Picture tools: adjust, crop, zoom, aspect ratio, rotate/flip, deinterlace, HDR option | | M5.3 |

### Library
| Feature | Notes | Milestone |
|---|---|---|
| Video library from folders you add | Video only; no music sections | M3.1–M3.3 |
| Home: Continue Watching, Recently Added, Frequently Visited Folders, Playlists | | M3.6 |
| Recent, pins, sort (incl. Unwatched/Watched first), search, watched marks | | M3.1–M3.3, M3.6 |
| User playlists and the queue | | M7.1, M2.4 |
| Compact library beside the video; floating miniplayer | | M7.2, M3.5 |
| Context menus (play, mark watched, favorite, add to queue/playlist, show in folder) | | M3.4 |

### Interface and desktop
| Feature | Notes | Milestone |
|---|---|---|
| The redesign: dark theme, VLC orange | | M1.x, M2.x |
| Accent colors, Light/Dark/System | | M1.3, M9.2 |
| Customize Player (drag-and-drop toolbar editor) and profiles | | M4.1, M4.2 |
| Sidebar presets | | M5.9 |
| Settings: General, Interface, Privacy, Controls, Playback, Video, Audio, Subtitles, Library, Performance | | M8.1–M8.3 |
| Keyboard shortcuts editor | | M8.4 |
| "Save a log" setting (replaces the log viewer) | For bug reports | M8.3 |
| Media information (codec, resolution, bitrate, streams) | | M0.8 keeps it reachable |
| 3-step onboarding | | M9.1 |
| MPRIS and media keys, screensaver inhibition | | built in |

### Input and formats
| Feature | Notes | Milestone |
|---|---|---|
| Local files and folders, drag and drop | | M7.1 |
| Files inside archives (zip, rar, 7z) | VLC's `archive` stream extractor | M0.6 |
| Every container and codec FFmpeg and VLC's own demuxers handle | Proven by the codec matrix | M0.6, M0.7 |
| Audio files still play | No music library or audio visuals | — |

## Cut
Each line says why. "Upstream" means the evidence comes from VideoLAN's own tracker or commits.

### Online and streaming
- **YouTube and other site scripts, `ytdl`.** They break whenever the sites change. Upstream removed `youtube.lua`
  in 2025 (commit `cd94dcaec9`) in favor of yt-dlp. Not offline.
- **IPTV and M3U stream lists, podcasts, internet radio and Icecast, Lua services (Jamendo, LibriVox …).**
  Online-only directories.
- **Paste a URL, network share browsing (SMB, NFS, SFTP, UPnP), SAP, RTSP.** Not offline. Files on a NAS still play
  from a mounted folder or the system file picker.

### Discs
- **DVD, Blu-ray, VCD, audio CD.** A shrinking group, and they need decryption libraries with legal risk.
  Consequence: DVD and Blu-ray ISO images and `VIDEO_TS` folders won't play either.

### Conversion and sharing
- **Convert/Save, stream wizard (sout), VLM, record.** Encoding tools; HandBrake, ffmpeg and OBS do this better.
- **Chromecast and renderers, UPnP media server.** Network features with long-standing buffering bugs.

### Capture and broadcast
- **Webcam, screen capture, DVB/ATSC/SAT>IP tuners, teletext, EPG, programs.** Not file playback.

### Music
- **Music library sections, music now-playing screen, waveform seek bar, visualizations, lyrics view.** The product
  is a video player.

### Everything else
- **Lua extensions and the add-ons store (including VLSub).** Fragile; VLSub breaks whenever OpenSubtitles changes.
  M5.7 replaces it with a native client.
- **Skins, web/telnet/CLI remote, global hotkeys, mouse gestures.** Redundant with the new UI or niche.
- **Last.fm, audio fingerprinting, metadata editing, ratings.** Music-library features.
- **Video wallpaper, 3D output, novelty filters (puzzle, wall, clone, psychedelic …).** No evidence of use.
- **Go to time, log viewer, system tray, dual subtitles, reverse playback, sleep timer, boss key.** Little use. The log
  becomes a "Save a log" setting.
- **Update checker.** Flatpak updates the app.

## Future
Parked; each needs a `DECISIONS.md` entry to become a milestone.
- Seek-bar thumbnails (M6.1): loved in IINA and PotPlayer, missing in VLC 4, a large spike.
- NVDEC hardware decoding: VA-API through nvidia-vaapi-driver covers NVIDIA for now.
- Live video-filter previews (G10).
- The pressed key in on-screen messages (G13).
- Two-tone menu icons (G16).

## What the build contains (M0.6, D20)
The plugins outside this scope are listed by name in [`cut-modules.txt`](cut-modules.txt): 190 plugins are not
built and 232 are. `redux/tools/build.sh` passes the list to meson; to bring one back, delete its line, add a
`DECISIONS.md` entry and run `build.sh reconfigure`.

- **Built:** local files and archives, every demuxer and decoder (FFmpeg's avcodec and avformat, dav1d, vpx, the
  Xiph codecs, mpg123, faad, the subtitle decoders including libass, teletext, ARIB and closed captions), packetizers,
  the audio filters we keep, PipeWire/PulseAudio/ALSA output, the OpenGL and libplacebo video outputs, VA-API,
  freetype, taglib, the media library, MPRIS, screensaver inhibition, hotkeys, the console and file loggers, and the
  Qt interface.
- **Not built:** network access and protocols, streaming formats (HLS/DASH), site scripts and Lua, services
  discovery, discs, capture and broadcast, stream output, muxers and encoders, remote interfaces, music visuals,
  novelty video filters and splitters, niche audio filters and outputs.
- **Proof:** `redux/tools/play-matrix.sh` plays 51 synthetic files (`make-matrix.sh`) and 28 real-world samples from
  FFmpeg's FATE suite (`fetch-samples.sh`, `samples.tsv`); every one must open and find a decoder for each stream.
