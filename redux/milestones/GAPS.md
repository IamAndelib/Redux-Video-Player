# Gaps: what we must explore or invent

These are the unknowns that block or shape milestones. External resources are welcome; the "What would help" column
says what to look for. When a gap is resolved, record the answer and the source here, and add a `DECISIONS.md`
entry if it changes a plan. New gaps found during milestone research go here too, with the next free G-number.

| ID | Gap | Known | Missing | What would help | Blocks |
|---|---|---|---|---|---|
| G1 | Figma source access | **Resolved 2026-10-20** (see log). Export script ready; MCP limit hit; 1 frame exported | Full frames, icons, tokens | **Figma read-only token** in `~/.config/vlc-redux/figma-token`, **and/or** `.fig` local copy, **or** manual exports (frames PNG 1×, icon frame SVG with outlined strokes) | M0.2, M1.2–M1.4 |
| G2 | Typography | Looks like Inter; the data is now in `file.json` | Exact text styles and line heights | Read them off `file.json` (G1 resolved) | M1.2 |
| G3 | Meaning of some Customize items | ~45 controls exist; 22 free IDs | What "HDR", "Replay", "Properties", "Go Home" do; whether the seek bar is placeable | Your notes; the designer's intent | M2.1, M4.1 |
| G4 | Volume "green meter" | **Resolved 2026-10-20** (see log). Cone shape | Live level meter or just a fill color? | Close-up of the component | M2.2 |
| G5 | Seek-thumbnail approach | Core thumbnailer API, IINA pattern | Why upstream !7822 was closed; acceptable CPU cost | Any VLC developer discussion or links | M6.1 |
| G6 | Waveform decoding | amem or libav options; `.dat` format | Real performance numbers | Long real audio files (FLAC/MP3) | M6.3 |
| G7 | Subtitle timeline | Design intent only | Core doesn't expose parsed subtitle cues | Is external-subtitles-only acceptable? Frames showing it | backlog |
| G8 | Per-show presets | Intent only | What a "show" is (folder?), what's included | Your definition | backlog |
| G9 | OpenSubtitles | Old VLSub API deprecated; REST v1 client is GPL-3 (can't copy) | API key, terms of service | An OpenSubtitles.com account and consumer API key | backlog |
| G10 | Live video-filter previews | adjust/transform filters | No API to preview a filter on a thumbnail | Design close-up | backlog |
| G11 | HDR options | 4K HDR10 test clip | Which Linux output/tone-mapping options apply | Your GPU and display details | backlog |
| G12 | Reverse playback | `Player.reverse()` | Which formats support it | Research only | M5.5 |
| G13 | Show pressed key in on-screen messages | Core sends text-only messages | Core change vs QML overlay | Your view on touching core files | backlog |
| G14 | Settings content mapping | 13 page frames; expert model | Figma setting → config key mapping | The settings you actually use | M8.2–M8.3 |
| G15 | Product identity | VLC is a trademark | Name, icon, Figma licence | Your decisions; designer contact | M10.1 |
| G16 | Two-tone icons | Colored-SVG provider exists | Rendering approach | Research only | backlog |
| G17 | Window-behind blur on Linux | In-window blur works | Compositor support | Your desktop environment/compositor | M9.2 |
| G18 | Window-button style | Custom title-bar button set exists | Figma buttons look like Windows | Your desktop environment | M2.3 |
| G19 | Side panel in frame 187:328 | **Resolved 2026-10-20** (see log). It shows "Playlists" | Is it the queue or the library? | Your reading of the video | M7.2 |
| G20 | Real-world test media | Synthetic set | HDR, multi-track MKV, ASS subtitles, long FLAC, IPTV M3U | A few sample files or URLs | M5–M7 |

## Resolution log
| Date | Gap | Resolution | Source |
|---|---|---|---|
| 2026-10-13 | G1 (partial) | `.fig` local copy received and stored at `redux/design/source/VLC-Redesign.fig` (git-ignored; ZIP holding `canvas.fig`, `meta.json` and the embedded images). This covers exact values offline. Rendered frame PNGs and icon SVGs still need the Figma token (or manual exports); the maintainer's PNG exports in `VLC Redesign (Community)/` serve as interim references. | Maintainer |
| 2026-10-20 | G1 | Resolved. `figma-export.py` ran with a REST token (6 API calls) and wrote `file.json` (full document: 51 fill/effect styles, every text node's type style, so G2 can now be read off it), `frames/` (all 103 top-level frames as 1× PNG) and `icons/` (206 SVGs). The 2 icons without a render, `check` (494:2400) and `0` (2107:6596), are empty placeholder components in the file itself. All in `redux/design/source/` (git-ignored). | Figma REST API |
| 2026-10-20 | G4 | Resolved. A level fill, not a live meter: the cone fills up to the volume (green in Figma, green to orange in the video), the rest black, and it doesn't move with the audio. | M0.4 frames: `0436-tracks-popup-audio-output.jpg`, 03:06, 04:36 |
| 2026-10-20 | G19 | Resolved. The panel in 187:328 is the **compact library** (sidebar toggle or folder name opens it; "Playlists" is one of its sections). The queue is a separate panel on the right. | M0.4 frames: `1146-compact-library-drag-to-queue.jpg`, 11:40–11:46 |
| 2026-10-20 | G3 (partial) | The 31 item labels are confirmed (list in brief §E). Edit mode outlines the seek bar as its own slot, and the alternate layout moves it, so it's placeable. Favorite matches the per-file Favorite action. Still unexplained: HDR, Replay, Properties, Go Home. | M0.4 frames: `1922-customize-player-canvas.jpg`, `1928-alternate-layout.jpg`, `1332-file-context-menu.jpg` |
| 2026-10-20 | G7 (partial) | UI settled: the seek bar zooms to a window (times marked `*`), cues drawn as blocks (accent played, gray upcoming), ‹ − / + › nudge buttons at the ends. Still open: where the cue times come from. | M0.4 frames: `0656-subtitle-timeline-seekbar.jpg`, 06:56 |
| 2026-10-20 | G8 (partial) | A preset is a user-named bundle of the sidebar settings across all tabs ("Anime", "Loud and then Quiet Movies", "The Wand Subtitle Preset"), with "+ New Custom Preset"; not tied to a folder automatically. | M0.4 frames: `0800-preset-menu.jpg`, 07:56–08:00 |
| 2026-10-20 | G10 | No change: the video never shows filter previews, so the Figma video panels are the only source. | M0.4 frames: 08:58–09:06 |
| 2026-10-20 | G12 (partial) | Reverse is a plain toggle on the Playback tab; format support is still research. | M0.4 frames: `0918-sidebar-playback-tab.jpg` |
| 2026-10-20 | G13 (partial) | Design settled: two lines, the action and a smaller gray "Pressed C"; controlled by "Show feedback for shortcuts" plus a duration slider on the Subtitles page. Core-vs-QML still open. | M0.4 frames: `1526-osd-pressed-key.jpg`, 15:26, 18:14 |
| 2026-10-20 | G14 (partial) | Readable basic-setting labels for every page are at 17:40–18:28 (e.g. File name matching → `sub-autodetect-fuzzy`, Skip amounts 3/10/60/300 s → the `*-jump-size` options). | M0.4 frames: `1740-settings-general-page.jpg`, `1758-settings-controls-page.jpg`, `1810-settings-subtitles-page.jpg` |
| 2026-10-20 | G16 (partial) | Each two-tone icon is the monochrome glyph with one inner part filled orange, so a base layer plus an accent layer reproduces it. | M0.4 frames: `0114-icon-sets-two-tone-mono.jpg` |
| 2026-10-20 | G18 (no change) | The video's window buttons are flat gray Windows-order glyphs (minimize, maximize, fullscreen, close); the desktop-environment question stays. | M0.4 frames: 17:40 |
| 2026-10-20 | G20 (partial) | IPTV source used in the video: `https://iptv-org.github.io/iptv/index.m3u` (loads as a 110-item playlist). | M0.4 frames: 13:16–13:20 |
