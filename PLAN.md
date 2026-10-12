# VLC Redux: scope assessment and implementation plan

> A handoff document for running Claude Code locally. Put it in your repo as `PLAN.md` and point Claude Code at it (see "Getting started locally" at the bottom).

## 1. Goal and decisions so far
- **Goal:** build the VLC redesign by **Juxtopposed** as a real, usable player, first for you and then as a **public open-source release**.
  - Video: "I Redesigned VLC After 25 Years", https://youtu.be/ERFeOgqk324
  - Figma: https://www.figma.com/design/CAuJVJyM5yY7PnyQQK9X24/VLC-Redesign--Community-?node-id=0-1 (file key `CAuJVJyM5yY7PnyQQK9X24`)
- **Platform:** Linux first. Windows and macOS later, if ever. On macOS, official VLC uses a separate native Cocoa UI, so it would be extra scope.
- **Who builds it:** Claude implements, you review and test.
- **Repo:** `IamAndelib/VLC-Redux`, currently empty.

## 2. What the Figma design contains (all ~100 frames reviewed)
All frames are on one page, `0:1`.

| Area | Figma frames (node IDs) |
|---|---|
| Player (video), controls, top bar | `Player` 187:328, 970:3308, 970:3792, 970:2703, 970:4028, 6261:15078, 247:445 |
| Music mode (blurred art backdrop + **waveform seek bar**) | `Player - Music` 4767:23726, 4778:25123 |
| Hide-UI mode / Light theme | 3328:11554 / 2425:13624 |
| Customize Player (drag-and-drop toolbar editor, about 35 items) | `Player - customize` 2107:5604, 2160:6137 … 2160:8732, 6587:19923 |
| Settings, 14 pages (General, Interface, Privacy, Playback, Video, Audio, Subtitles, Controls, Library, Network, Performance, Recording, Extensions; plus Advanced) | 999:5047, 3046:9282, 3046:10057, 3062:11379, 3062:11911, 3062:12552, 3072:13408, 3073:14187, 3073:15375, 3073:15879, 3180:17398, 3180:17989, 6536:13908, 6536:14482, 6542:15251, 6543:15649, 6571:15958, 6571:16429, 6575:17137 |
| Add subtitles to playlist/folder | 1911:7545, 3336:11929, 1919:8707, 1919:9278 |
| Keyboard shortcuts / Open network stream / New playlist / Profiles | 2437:14832 / 6216:13614 / 6259:14954 / 6648:20666 |
| Onboarding, 11 steps | 1899:3055, 1902:3670 … 1902:6465 |
| Audio panels: Equalizer, Compressor, Spatializer, Stereo Widener | 6114:13610, 536:1513, 536:1703, 612:1223 |
| Video panels: Essential, Crop, Colors | 536:1855, 543:990, 614:1430 |
| Miniplayer card | 970:3091 |
| Components: Icon set, Controls, Button, Toggle, volume, sidebar, Values, Dropdown, EQ presets, Setting Preset, Audio Visualizer, HDR Options, sub filename, context menus (file/folder/playlist/right-click), Sorting/View options, thumbnail, Current Time, Duration | 42:356 (icons), 491:1780, 500:3063, 536:1014, 244:184, 848:1996, 2372:*, 2404:13340, 2139:8935, 2459:9389, 6065:13616, 856:2215, 858:3290 |

**Visual language:**
- Near-black UI (#111–#1e1e1e) with an **orange accent** (VLC orange); the accent is user-selectable from 9 colors.
- Green volume meter.
- Thin line icons.
- Inter-like sans typography.
- Rounded 6–8px corners.
- Library layout: icon rail sidebar (Home, Videos, Music, Network, Playlists, Recent, Add item), breadcrumbs, and a floating miniplayer card in the bottom-right corner.

## 3. Scope answers

**Q1. Do we have to reverse-engineer it? No.**
- VLC is open source, so we read its code.
- The only translation is Figma to code, and the Figma MCP supplies exact tokens, layout and SVG icons.

**Q2. Can it be a skin for vanilla VLC? No.**
- VLC skins2 (`.vlt`) are bitmaps on a fixed canvas.
  - They have no library browser, settings pages, blur, real animation, toolbar editor or waveform.
  - Skins2 also borrows all its dialogs from the stock Qt interface.
- A skin would cover at most about 20–30% of this design.
- The main Qt interface isn't skinnable. Its only theming hook is a colors-only API: the "qt theme provider" module and the `qt-accent-color` option.

**Q3. Do we have to fork? Yes. Fork VLC `master` (VLC 4) and redesign its Qt/QML interface (`modules/gui/qt`).**
- VLC 4's QML interface already has the working pieces the design needs:
  - drag-and-drop toolbar editor (`dialogs/toolbar/qml/ToolbarEditor.qml`, `EditorDNDView.qml`, profiles in `controlbar_profile_model.cpp`)
  - mini player (`player/qml/MiniPlayer.qml`) and a floating, draggable PiP video player (`player/qml/PIPPlayer.qml`)
  - System/Day/Night themes (`color_scheme_model.cpp`) and accent color (`qt-accent-color`, honored by `style/systempalette.cpp`)
  - blur (`widgets/qml/FrostedGlassEffect.qml`, `DualKawaseBlur`, `qt-backdrop-blur`)
  - media library views (`medialibrary/qml/`) and side navigation (`maininterface/qml/SideNavigationPane.qml`)
  - about 45 toolbar controls (`player/qml/controlbarcontrols/*.qml`)
  - all the audio filters the design uses: `equalizer`, `compressor`, `spatializer`, `stereo_widen` (also expander, limiter, param_eq …); video uses `adjust`, `croppadd`/`formatcrop`, `transform`
  - icon font built from SVGs (`pixmaps/makeIconFont.py`, `VLCIcons.json`, `VLCIcons.ttf`)
- **Still QtWidgets, to be rewritten in QML:**
  - preferences (`dialogs/preferences/`)
  - first-run wizard (`dialogs/firstrun/`)
  - effects panels (`dialogs/extended/extended_panels.*`)
- **Not in VLC at all:** the waveform seek bar. We build it (Phase 4).
- **Rejected alternative:** a standalone libVLC app (Qt/QML, Tauri, Electron or Flutter). It would mean rebuilding the media library, hundreds of preferences, effects, playlists and video embedding. Electron and Tauri have no maintained libVLC video embedding. A fork is much less work and keeps all of VLC's power.

**Facts and caveats to accept:**
- **VLC 4.0 is unreleased.** Latest stable is 3.0.24 (Sep 2026) and master is `4.0.0-dev`. Pin a known-good master commit and merge upstream about monthly.
- **Qt version:** master needs Qt ≥ 6.2; some features need 6.5–6.7, and VLC's contribs use **Qt 6.8.3**. Ubuntu 24.04's Qt 6.4 is too old, so use VLC's Docker image or `aqtinstall` to get Qt 6.8.
- **QML is compiled into the Qt plugin (qrc).** Every UI change means rebuilding `libqt_plugin`. That's an incremental build, so it's fast.
- **License:** `modules/gui/qt` is GPL-2.0+ and libvlc/libvlccore are LGPL-2.1+. Our fork is GPL-2.0+ with public source, which is fine.
- **Trademark:** "VLC", "VideoLAN" and the cone are registered trademarks. Normal redistribution of the OSS code is allowed, but a public fork should use **its own product name**, e.g. "Redux Player, powered by VLC". Decide before release.
- **Design credit:** the Figma file is a Community file; check its license. Credit Juxtopposed in the README and About dialog, and contact her before the public launch.

## 4. Repo strategy
- `VLC-Redux` is a full fork: it imports VLC `master` with history and keeps an `upstream` remote (`https://code.videolan.org/videolan/vlc.git`).
- Our work goes on feature branches with one PR per phase.
- Our own files live in a top-level `redux/` directory:
  - `redux/design/`: `tokens.json`, `screen-map.md` (Figma frame → QML file), `transcript.md`, reference PNGs
  - `redux/tools/`: build script, screenshot harness, diff script, test-media generator
  - `redux/packaging/`: Flatpak manifest and AppImage recipe
  - `redux/README.md`: the project front page; set the GitHub repo README to point here
- Keep edits outside `modules/gui/qt` minimal so upstream merges stay easy.

## 5. Phases

### Phase 0: Foundations
1. **Fork setup.**
   - Clone upstream VLC, add the GitHub remote, and push `master` plus a `redux/main` branch.
   - Pin the commit in `redux/UPSTREAM_COMMIT`.
2. **Dev container.**
   - `redux/devcontainer/` (Dockerfile + `devcontainer.json`), based on VLC's CI image `registry.videolan.org/vlc-debian-unstable:<tag>`. Read the current tag from `extras/ci/gitlab-ci.yml`.
   - Or use Ubuntu 24.04 with Qt 6.8 via `aqtinstall`, meson, ninja, ffmpeg, Xvfb and ImageMagick.
   - It runs on your machine with Docker or Podman.
3. **Build script** `redux/tools/build.sh`.
   - Runs `meson setup build` with only the needed modules, then `ninja -C build`, then runs `./build/vlc`.
   - Document the fast loop: rebuild just the Qt plugin target.
4. **Test media** `redux/tools/make-media.sh`.
   - ffmpeg generates test video (testsrc/smptebars), music clips with embedded cover art and tags, a subtitle file and a folder tree like "Shows/The Wand/S01". This mirrors the Figma content, with no licensing issues.
5. **Visual harness** `redux/tools/shoot.sh`.
   - Launch the player under Xvfb at 1920×1080 on fixture media and capture each screen.
   - Run ImageMagick `compare` against the Figma reference PNGs (exported with Figma MCP `get_screenshot`) and output an HTML side-by-side report.
6. **Design inventory.**
   - Figma MCP `get_variable_defs` and `get_design_context` on the key frames give `redux/design/tokens.json`.
   - `download_assets` on the Icon frame `42:356` gives SVGs.
   - Write `screen-map.md`.
7. **Transcript.** Run AI-Video-Transcriber locally (`python3 transcribe.py "https://youtu.be/ERFeOgqk324" --no-llm`) and commit `redux/design/transcript.md`. Mine it for rationale and behaviors that aren't visible in Figma.

### Phase 1: Design system
- **Theme.** Rewrite the palette and tokens in `style/VLCStyle.qml`, `style/systempalette.cpp` and `style/colorcontext.cpp`:
  - dark and light palettes, typography, radii and spacing from `tokens.json`
  - the 9 accent presets mapped to `qt-accent-color`
- **Icons.** Regenerate the icon font from the Figma SVGs using `pixmaps/makeIconFont.py` and `VLCIcons.json`.
- **Base widgets.** Restyle in `widgets/qml/`: buttons, the ON/OFF toggle, orange-fill sliders, dropdowns, the segmented control (Dark/Light/System), the search field, context menus and tooltips.

### Phase 2: Player screen
- **Re-layout.** Rework `player/qml/ControlBar.qml`, `TopBar.qml` and `maininterface/qml/MainDisplay.qml` to match the Figma player:
  - top bar with cone, "…" menu, sidebar toggle, breadcrumb, centered title and window buttons
  - bottom bar with prev/play/next, current time, seek bar, duration, volume meter, then audio, subtitle, settings and playlist buttons
- **Default toolbar.** Set the default profile in `controlbar_profile_model.cpp`.
- **Hide UI.** Add the "Hide UI" mode.
- **Customize Player.**
  - Restyle `ToolbarEditor` as the Figma "Customize Player" modal (grid of items, Cancel/Save).
  - Add the missing controls in `controlbarcontrols/`: Forward/Back 10s and 15s, HDR, Zoom, Picture-in-Picture, Go Home, File, Artist, Folder and Playlist name labels, Properties, Favorite, Bookmark(s), Playlists, Chapters, Replay, Quit and VLC Settings. Reuse the existing ones where they already exist.

### Phase 3: Library (MVP milestone)
- **Navigation.**
  - Icon rail sidebar with labels when expanded (`SideNavigationPane.qml`).
  - Collapsible secondary panel (Playlists list etc.).
  - Back and forward buttons with a breadcrumb.
- **Browsing.**
  - Folder and file list view with thumbnails and watched-progress underline (`medialibrary/qml/`, `network/` browse).
  - Item count, sort and view options, and search.
- **Menus and dialogs.**
  - Context menus for files, folders and playlists.
  - New playlist and Open network stream dialogs.
- **Miniplayer card.** The floating corner card (video preview, progress, file name, folder and playlist chips), adapted from `PIPPlayer.qml` / `MiniPlayer.qml`.
- **End of Phase 3 = usable daily driver.** Cut the first prerelease.

### Phase 4: Music mode and waveform
- **Now-playing screen.** Blurred artwork backdrop, centered cover and "title – artist", with ±10s buttons in the bar.
- **Waveform seek bar:** a new C++ `WaveformProvider` (`modules/gui/qt/player/`) exposed to QML.
  - It decodes in the background with a second libVLC media player using `libvlc_audio_set_callbacks`, no audio output and a high rate.
  - It computes N peak buckets and caches them in `~/.cache/<app>/waveforms/<hash>`.
  - QML renders the bars, using the accent color for played progress.
  - It falls back to the normal seek bar while computing and for video.

### Phase 5: Effects and subtitle panels in QML
- **Audio panels.**
  - Equalizer with the presets dropdown, Compressor, Spatializer and Stereo Widener, each in an Expand/Collapse settings card.
  - Audio visualizer picker.
  - These bind to the same variables and filter chain as `extended_panels.cpp`; move its logic into a shared C++ model.
- **Video panels.** Essential (adjust), Crop, Colors and HDR options.
- **Subtitle panels.**
  - Track, delay and size controls.
  - The "Add Subtitles to Playlist/Folder" flow, including sub-filename matching.

### Phase 6: Settings
- **New dialog.** A QML settings dialog with a search box and the 14 categorized pages, matching the Figma frames.
  - It binds to VLC config through a C++ model over `config_Get*` / `config_Put*`, reusing `dialogs/preferences/` logic.
- **Advanced Options.** Opens the existing full advanced preference tree, so no capability is lost.
- **Other dialogs.** Keyboard Shortcuts (editable) and Profiles.

### Phase 7: Onboarding and polish
- **Onboarding.** An 11-step QML onboarding (welcome, media folder, theme, accent …) replaces `dialogs/firstrun/firstrunwizard`.
- **Light theme.** A pass across all screens.
- **Keyboard and accessibility.** Keyboard navigation and accessible names.
- **Display.** HiDPI and fractional scaling, motion/animation polish.

### Phase 8: Release
- **Branding.** Final product name, app ID, icons and About dialog credits (Juxtopposed, VideoLAN).
- **Packages.**
  - Flatpak: adapt Flathub's `org.videolan.VLC` manifest, KDE 6.8 runtime.
  - AppImage.
- **CI.** GitHub Actions builds both on every PR and attaches them to tagged releases.
- **Launch.** README with screenshots, a changelog, and a contribution guide.
- **Upstream (optional).** Propose generic features to VideoLAN, e.g. the waveform seek bar.

## 6. Tools, agents and plugins
- **Figma MCP** (remote: `claude mcp add --transport http figma https://mcp.figma.com/mcp`, then `/mcp` to log in):
  - `get_metadata`
  - `get_design_context`, after loading the `/figma-design-to-code` skill
  - `get_variable_defs`
  - `get_screenshot` for reference PNGs
  - `download_assets` for SVG icons
- **GitHub MCP or `gh`:** PRs per phase, CI status and issues.
- **Claude Code agents and skills:**
  - Explore agents for codebase sweeps across VLC's large tree.
  - A Plan agent at the start of each phase.
  - `/code-review` and `/simplify` before each PR.
  - Optionally, a multi-agent workflow per phase to do screens in parallel (ask for it explicitly).
- **Build and test:** Docker or Podman with the VLC CI image, meson, ninja, Qt 6.8 (aqtinstall), Xvfb, ffmpeg, ImageMagick, `qmltestrunner`, and the existing `modules/gui/qt/tests`.
- **Third-party:** AI-Video-Transcriber with faster-whisper for the transcript, flatpak-builder and appimagetool for packaging.

## 7. Verification (every phase)
1. **Build:** `meson setup` and `ninja` succeed inside the dev container.
2. **Smoke test:** `xvfb-run ./build/vlc --no-qt-privacy-ask <fixture>` starts, plays and quits cleanly.
3. **Visual diff:** the harness report compares each implemented screen with its Figma frame. Fix big deviations before the PR.
4. **Functional checks:**
   - toolbar edits persist across restarts
   - theme and accent changes apply live
   - effects audibly or visibly change output (confirm in the VLC log `-vv`)
   - the waveform matches the audio
   - settings write the correct keys to `vlcrc`
5. **Tests:** `modules/gui/qt/tests` and the qml tests pass, and CI is green.
6. **Real hardware:** you run the built player or CI Flatpak on your Linux machine and file feedback as issues.

## 8. Getting started locally
1. **Install tools.** Install Docker or Podman, git and Claude Code. Log in with `claude auth login`.
2. **Clone the repo.**
   ```bash
   git clone git@github.com:IamAndelib/VLC-Redux.git && cd VLC-Redux
   ```
3. **Add the plan.** Copy this file to `PLAN.md` in the repo root.
4. **Add the Figma MCP.**
   ```bash
   claude mcp add --transport http figma https://mcp.figma.com/mcp --scope user
   ```
   Then run `/mcp` inside Claude to authenticate.
5. **(Optional) Add the GitHub MCP**, or make sure `gh auth login` is done.
6. **Kick off.** Start `claude` in the repo and say:
   > Read PLAN.md. Execute Phase 0: fork VLC master into this repo per §4, create the dev container in redux/devcontainer, the build/test-media/screenshot scripts in redux/tools, and the design inventory from the Figma file. Run the build inside the container and show me the first screenshot report. Use plan mode first.
