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

### 2a. Design intent from the video (full text in `redux/design/transcript.md`)
The designer's stated reasoning. It settles behavior that the Figma frames only show statically.

- **Identity:**
  - Keep the cone and VLC orange, on neutral grays and black.
  - Two icon sets: two-tone gray and orange icons where the icon is not clickable (e.g. menu item icons), monochrome for every clickable icon.
  - Shapes stay rectangular but slightly less sharp. That is deliberate: no pill or circle styling.
- **Control bar:**
  - One thin row that never covers the video.
  - The play button stays on the left, not centered, slightly bigger, with prev and next around it.
  - Fullscreen and settings move to the right.
  - The playlist toggle becomes a **queue** icon. Queue (auto-plays) and playlists (saved collections) are separate concepts.
  - The volume slider is a **cone-shaped** wedge, keeping VLC's colors.
  - The **seek bar is thick** and sits in the bottom row. Add **seek thumbnails** (preview frames while scrubbing).
  - On the right: a **subtitle** button (track list) and an **audio** button (tracks plus output device such as headphones or speakers). Video tracks get a tab in the sidebar but no bar button.
- **Top bar:**
  - Menu, media title and window decorations.
  - In fullscreen, both bars stay available and **show on hover near the edge** and hide immediately after. The title must always be reachable.
  - Fullscreen and Picture-in-Picture may live in the top bar; the designer left this open as "up or down".
  - The **folder or show name in the top bar** acts as the entry point that opens the library sidebar in compact mode next to the video.
- **Menus:**
  - Merge the duplicated top menu and right-click menu into one "…" menu holding the media and extra options.
  - Clean up the right-click menu and add **Hide UI** (also as a shortcut).
  - Split the old all-in-one "Open Media" dialog into separate actions: Open file, Open folder, Network stream, Capture device, Clipboard, Recent, Convert, Stream to device.
- **Right sidebar** with 4 tabs: Subtitles, Audio, Video, Playback.
  - **Subtitles:**
    - Timing as sliders, plus a **subtitle timeline** for syncing visually against the audio.
    - Font, size (relative or precise), outline and position.
    - A default track or language.
  - **Audio:** default track or language, delay, and expandable filters (EQ etc.) with friendly presets that have preview icons.
  - **Video:** filters with **live previews**, plus flip, rotate, zoom, HDR, resolution and aspect ratio.
  - **Playback:** speed, reverse, sleep timer, show subtitle timeline, show **waveform on seek bar**, show metadata.
  - **Bookmarks and chapters** timeline (Ctrl+B adds a bookmark quickly).
  - All of this can be saved as **per-show presets**.
- **Subtitles "Add" dialog:** apply to this file, this folder or this playlist. The source is local files or a site like OpenSubtitles. Files are auto-matched by name, with manual matching per episode remembered for later.
- **Library:**
  - Sections: Videos, Music (Songs, Albums, Artists, Genres), Network streams and Playlists.
  - Back/forward buttons and a clickable **address bar** of breadcrumbs.
  - A view-mode toggle (grid, list, detail), visible **sorting** (including Unwatched first and Watched first) and search.
  - A "…" menu to add a file or folder.
  - **Drag from the library to the queue.**
  - The library can also go fullscreen, with a draggable miniplayer and the queue.
- **Sidebar extras:** **pinned** items (playlists, folders), **Recent**, and a **Home** page with the latest files, playlists and streams, plus "continue where you left off".
  - The resume prompt sits near the center playback controls, not in a far corner.
- **Network:**
  - A saved stream list with an add button.
  - Pasting an M3U URL (such as the public IPTV lists on GitHub) produces an automatic playlist.
- **On-screen messages:** when a shortcut fires, show the **key pressed** as well as the action.
- **Settings:**
  - 13 categories: General (theme and accent), Interface, Privacy, Controls, Playback, Video, Audio, Subtitles, Library, Network, Performance, Recording, Extensions.
  - Each page shows **basic settings first, then advanced settings further down the same page**, replacing the separate "simple" and "all" modes.
  - Every setting has a visible **info icon**.
  - Numeric codes become **human-worded dropdowns**. For example, subtitle auto-detect fuzziness gets descriptive choices instead of the numbers 0–4.
  - Duplicated settings are deduplicated.
  - **Keyboard shortcuts** get their own dialog, reachable from the menu.
  - Extensions shows add-ons (extensions, skins); internal plugins move to Advanced.
- **Customization:**
  - A drag-and-drop canvas over the player.
  - Layouts are saved per **profile**.
  - **Onboarding** offers theme options and introduces the basic shortcuts, because about half of users want minimal customization.
- **License note:** the designer says the redesign "will be open source and free to use", which is compatible with this project. Still credit her.

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
2. **Dev container. Done:** `.devcontainer/Containerfile` and `devcontainer.json`, driven by `redux/dev.sh`.
   - It's built locally from Debian sid with the same package list as VideoLAN's `vlc-debian-unstable` CI image, because `registry.videolan.org` serves its images too slowly.
   - Usage:
     - `redux/dev.sh image` builds the image.
     - `redux/dev.sh shell` opens a shell.
     - `redux/dev.sh run <cmd>` runs one command.
   - Details: the repo is mounted at `/workspace`, commands run as your own user, ccache lives in a volume, and the host Wayland/X11 display, PipeWire audio and GPU are passed through.
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
7. **Transcript. Done:** `redux/design/transcript.md`, produced by `redux/tools/transcriber/transcribe.sh <url>`.
   - That script runs AI-Video-Transcriber in its own container: yt-dlp with deno, then faster-whisper.
   - Its design rationale is summarized in §2a.

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
1. **Install tools.** The host needs only Podman, git and Claude Code; everything else runs in containers. Log in with `claude auth login`.
2. **Clone the repo and build the dev image.**
   ```bash
   git clone https://github.com/IamAndelib/VLC-Redux.git && cd VLC-Redux
   redux/dev.sh image
   ```
3. **Add the Figma MCP.**
   ```bash
   claude mcp add --transport http figma https://mcp.figma.com/mcp --scope user
   ```
   Then run `/mcp` inside Claude to authenticate.
4. **(Optional) Add the GitHub MCP**, or make sure `gh auth login` is done.
5. **Kick off.** Start `claude` in the repo and say:
   > Read PLAN.md. Execute the rest of Phase 0: import VLC master into this repo per §4, then write the build, test-media and screenshot scripts in redux/tools, all run through redux/dev.sh. Then build the design inventory from the Figma file. Build VLC inside the container and show me the first screenshot report. Use plan mode first.
