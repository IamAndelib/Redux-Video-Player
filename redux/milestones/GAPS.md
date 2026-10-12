# Gaps: what we must explore or invent

These are the unknowns that block or shape milestones. External resources are welcome; the "What would help" column
says what to look for. When a gap is resolved, record the answer and the source here, and add a `DECISIONS.md`
entry if it changes a plan. New gaps found during milestone research go here too, with the next free G-number.

| ID | Gap | Known | Missing | What would help | Blocks |
|---|---|---|---|---|---|
| G1 | Figma source access | Export script ready; MCP limit hit; 1 frame exported | Full frames, icons, tokens | **Figma read-only token** in `~/.config/vlc-redux/figma-token`, **and/or** `.fig` local copy, **or** manual exports (frames PNG 1×, icon frame SVG with outlined strokes) | M0.2, M1.2–M1.4 |
| G2 | Typography | Looks like Inter | Exact text styles and line heights | Comes with G1 | M1.2 |
| G3 | Meaning of some Customize items | ~45 controls exist; 22 free IDs | What "HDR", "Replay", "Properties", "Go Home" do; whether the seek bar is placeable | Your notes; the designer's intent | M2.1, M4.1 |
| G4 | Volume "green meter" | Cone shape | Live level meter or just a fill color? | Close-up of the component | M2.2 |
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
| G19 | Side panel in frame 187:328 | It shows "Playlists" | Is it the queue or the library? | Your reading of the video | M7.2 |
| G20 | Real-world test media | Synthetic set | HDR, multi-track MKV, ASS subtitles, long FLAC, IPTV M3U | A few sample files or URLs | M5–M7 |

## Resolution log
| Date | Gap | Resolution | Source |
|---|---|---|---|
| 2026-10-13 | G1 (partial) | `.fig` local copy received and stored at `redux/design/source/VLC-Redesign.fig` (git-ignored; ZIP holding `canvas.fig`, `meta.json` and the embedded images). This covers exact values offline. Rendered frame PNGs and icon SVGs still need the Figma token (or manual exports); the maintainer's PNG exports in `VLC Redesign (Community)/` serve as interim references. | Maintainer |
