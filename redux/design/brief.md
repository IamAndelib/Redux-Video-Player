# VLC Redux design brief

The streamlined guide to Juxtopposed's redesign: every design decision from the video, why it was made, and where
it lands in our code. Use this file while building. Go to the sources only to check a detail.

| Source | What it settles | Where |
|---|---|---|
| Figma `CAuJVJyM5yY7PnyQQK9X24` | **Visuals:** layout, sizes, colors, states | Node IDs below; code mapping in [`screen-map.md`](screen-map.md) |
| Video `ERFeOgqk324` | **Behavior and intent:** what things do and why | `t=` links below; full narration in [`transcript.md`](transcript.md) |
| Video frames | What the video shows that the Figma doesn't | `redux/design/source/video-frames/` (git-ignored; regenerate from [`frame-picks.tsv`](frame-picks.tsv), see "Frames") |

**When the sources disagree:** Figma wins on visuals, the video wins on behavior. Every conflict is listed in
[Video vs Figma](#video-vs-figma).

**Credit:** the designer says the redesign "will be open source and free to use". Credit Juxtopposed in the README
and About dialog (M10.1).

**How each entry reads:**
- **Decision** in bold, then why it was made (the old-VLC pain it fixes).
- **Build:** the milestone in `redux/milestones/ROADMAP.md` and the upstream code to reuse.
- **Refs:** video time, frame files, Figma nodes.
- **Open:** the matching row in `redux/milestones/GAPS.md`, if a question remains.

## Principles
These eight rules decide anything the entries below don't cover.

1. **Keep VLC's identity.** The cone and the orange stay; everything else is neutral gray and black.
2. **Rectangular, slightly softened.** No pills or circles; small radii. The square shapes are part of VLC's personality.
3. **One quiet row.** Playback chrome is a thin bar that never covers the video.
4. **Put things where people look.** Settings, tracks, fullscreen and the queue go bottom-right; the title goes top-center.
5. **Never make the user leave the video.** Library, tracks and settings open beside the video, not instead of it.
6. **Basic first, advanced below.** Every settings page shows common options first and advanced ones further down the same page. No separate expert mode.
7. **Use words, not numbers.** Options are named in plain language, and every setting has a visible info icon.
8. **Customization is optional.** Good defaults; onboarding offers theme and shortcuts, and the layout editor is there for those who want it.

## B. Design system
- **Two icon sets.** Two-tone gray and orange icons for non-clickable places (menu item icons); monochrome icons for everything clickable.
  - Why: VLC's two-tone icons are recognizable but inconsistent.
  - Build: M1.4 (monochrome set), two-tone deferred.
  - Refs: [00:54](https://youtu.be/ERFeOgqk324?t=54) · Figma 42:356 (`two-tone=yes/no` variants)
  - Open: G16
- **Neutral palette plus one accent.** Neutral grays and black backgrounds; VLC orange as the default accent, user-changeable (General settings).
  - Build: M1.1, M1.3
  - Refs: [00:30](https://youtu.be/ERFeOgqk324?t=30), [17:30](https://youtu.be/ERFeOgqk324?t=1050) · Figma 999:5047 (9 swatches)
- **Shapes.** Rectangles with a small radius.
  - Build: M1.2 (radius tokens)
  - Refs: [01:10](https://youtu.be/ERFeOgqk324?t=70)

## C. Player screen
- **The play button stays on the left**, slightly bigger, with previous and next on either side. No centered transport.
  - Why: a centered cluster makes the bar tall and covers the video, and most people play and pause from the keyboard.
  - Build: M2.1 · Refs: [01:35](https://youtu.be/ERFeOgqk324?t=95) · Figma 187:328
- **One thin row** holds all controls, and the **seek bar is thick** and sits in that row.
  - Why: thin sliders are hard to hit, and a stacked bar hides the video.
  - Build: M2.1 · Refs: [03:05](https://youtu.be/ERFeOgqk324?t=185) · Figma 187:328, 491:1780
- **Fullscreen and settings move to the right side.**
  - Build: M2.1 · Refs: [02:10](https://youtu.be/ERFeOgqk324?t=130)
- **The volume control is a cone.** VLC's wedge slider becomes a full cone shape in the cone's colors.
  - Why: keep VLC's spirit instead of a generic slider.
  - Build: M2.2 · Refs: [02:55](https://youtu.be/ERFeOgqk324?t=175) · Figma 244:184
  - Open: G4
- **Seek thumbnails.** Scrubbing the seek bar shows a preview frame.
  - Build: M6.1 · Refs: [03:28](https://youtu.be/ERFeOgqk324?t=208) · Figma 2151:9673
  - Open: G5
- **Subtitle button and audio button, bottom-right.**
  - The subtitle button opens the list of subtitle tracks.
  - The audio button opens audio tracks **and the output device** (speakers, headphones).
  - Video tracks get no bar button: they live in a sidebar tab and the right-click menu.
  - Why: today a subtitle change takes several nested right-click menus that keep closing.
  - Build: M2.4 · Refs: [04:03](https://youtu.be/ERFeOgqk324?t=243) · Figma 1915:8397, 1919:9121
- **The playlist button becomes a Queue button.**
  - The **queue** auto-plays what's next. **Playlists** are saved collections. They're two separate concepts.
  - You add to the queue by dragging files in, or with add buttons in the queue panel.
  - Build: M2.4 (button), M7.2 (panel) · Refs: [02:20](https://youtu.be/ERFeOgqk324?t=140)
- **Top bar.** Cone, one "…" menu, sidebar toggle, the **folder or show name**, the centered media title, and window buttons.
  - Build: M2.3 · Refs: [03:37](https://youtu.be/ERFeOgqk324?t=217) · Figma 187:328
- **Fullscreen keeps both bars.** Both bars appear when the pointer nears the top or bottom edge and disappear the moment it moves away, so the title is always one move away.
  - Fullscreen and picture-in-picture may also sit in the top bar; the designer left "up or down" open.
  - Build: M2.5 · Refs: [03:45](https://youtu.be/ERFeOgqk324?t=225)
- **Hide UI.** A right-click entry and a shortcut hide all chrome.
  - Build: M2.5, M2.6 · Refs: [05:15](https://youtu.be/ERFeOgqk324?t=315) · Figma 3328:11554
- **One menu instead of two.** The old top menu bar and the right-click menu duplicate each other. They merge into one "…" menu with media options and extra settings, and the right-click menu is cleaned up and restyled.
  - Build: M2.6 · Refs: [04:50](https://youtu.be/ERFeOgqk324?t=290) · Figma 6065:13616, 6062:13354
- **Resume prompt near the controls.** "Continue where you left off" appears next to the playback controls, not in a far corner.
  - Why: the prompt only lasts a few seconds.
  - Build: M2.5 · Refs: [13:50](https://youtu.be/ERFeOgqk324?t=830)

## D. Library
- **Sections:** Videos, Music, Network streams and Playlists, plus Home, Recent and pinned items.
  - Build: M3.1 · Refs: [10:01](https://youtu.be/ERFeOgqk324?t=601) · Figma 848:1996
- **Header:** back and forward buttons, a clickable breadcrumb **address bar**, a view-mode toggle (grid, list, detail), visible **sorting** and search.
  - Why: today sorting hides in the right-click menu, and the view icon doesn't show its state.
  - Build: M3.2 · Refs: [10:10](https://youtu.be/ERFeOgqk324?t=610) · Figma 970:3308, 856:2215, 858:3290
- **Sort by Unwatched first and Watched first.**
  - Build: M3.2 · Refs: [10:40](https://youtu.be/ERFeOgqk324?t=640) · Figma 856:2215
- **A "…" menu in the header** with Add file and Add folder to this view.
  - Build: M3.2, M3.4 · Refs: [10:50](https://youtu.be/ERFeOgqk324?t=650)
- **Folders are first-class.** The library browses by folder ("Shows › The Wand › S01"), not one flat pile of files.
  - Why: today everything shows side by side regardless of folder, and adding media goes through a hidden "Browse" view.
  - Build: M3.2 · Refs: [09:30](https://youtu.be/ERFeOgqk324?t=570) · Figma 970:3308
- **Watched progress** shows as an accent underline on items.
  - Build: M3.3 · Refs: Figma 970:3308
- **Context menus** for files, folders and playlists.
  - Build: M3.4 · Refs: Figma 2404:13340, 2139:8935, 2459:9389
- **Full-window library with a floating miniplayer card** and the queue, both draggable.
  - Build: M3.5 · Refs: [11:45](https://youtu.be/ERFeOgqk324?t=705) · Figma 970:3308, 970:3091
- **Home page.** Latest files, playlists and streams, plus continue watching, so VLC never opens to a blank cone.
  - Build: M3.6 · Refs: [13:35](https://youtu.be/ERFeOgqk324?t=815)
- **Recent tab and pins.** Pin favorite playlists and folders to the sidebar.
  - Build: M3.1, M3.6 · Refs: [13:25](https://youtu.be/ERFeOgqk324?t=805) · Figma 848:1996

## E. Customize Player
- **Customization is a drag-and-drop canvas over the player.** One frame in the middle holds every available item, with outlines that show what can move. Drag items into the bars to add them and back into the box to remove them. Cancel and Save.
  - Why: the current editor is hard to use.
  - Build: M4.2 · Refs: [18:55](https://youtu.be/ERFeOgqk324?t=1135) · Figma 2107:5604 … 2160:8732
- **Missing items** (±10 s and 15 s, HDR, Zoom, PiP, name labels, Favorite, Bookmarks, Chapters …).
  - Build: M4.1 · Refs: Figma 2107:5604
  - Open: G3
- **Profiles.** Layouts, and all other settings, are saved per VLC profile.
  - Build: M4.2 · Refs: [19:25](https://youtu.be/ERFeOgqk324?t=1165) · Figma 6648:20666
- **The alternate layout shown in the video** is an example of what a user can build, not a second default.
  - Refs: [19:20](https://youtu.be/ERFeOgqk324?t=1160)

## F. Right sidebar
A sidebar on the right replaces the "extended settings" window that covers half the screen. It has **four tabs:
Subtitles, Audio, Video and Playback**, and its state can be saved as a per-show preset.

- **Subtitles tab:**
  - **Timing as sliders** instead of typed numbers (three timing options).
  - Font, size, outline and position, editable while watching.
  - Size is either **Relative or Precise** (exact values, today hidden deep in Advanced settings).
  - A **default subtitle track or language** that is selected automatically for every episode.
  - Build: M5.4 · Refs: [07:05](https://youtu.be/ERFeOgqk324?t=425), [08:00](https://youtu.be/ERFeOgqk324?t=480) · Figma 3180:17989
- **Subtitle timeline.** Shows when each subtitle line appears, so you can pause on the audio and drag the subtitles into sync.
  - Why: syncing today means typing a delay, closing the window, rewinding, and repeating.
  - Build: backlog · Refs: [06:50](https://youtu.be/ERFeOgqk324?t=410)
  - Open: G7
- **Audio tab:**
  - Default audio track or language, and audio delay.
  - **Expandable effect cards** (equalizer, compressor, spatializer, stereo widener).
  - **Friendly presets with preview icons** for casual users; full controls for experts.
  - Build: M5.2 · Refs: [08:40](https://youtu.be/ERFeOgqk324?t=520) · Figma 6114:13610, 536:1513, 536:1703, 612:1223, 2372:8487
- **Video tab:**
  - Filters with **live previews**.
  - Flip, rotate, zoom, HDR, resolution and aspect ratio.
  - Build: M5.3 · Refs: [08:55](https://youtu.be/ERFeOgqk324?t=535) · Figma 536:1855, 543:990, 614:1430, 2372:8733
  - Open: G10, G11
- **Playback tab:** speed, **reverse**, **sleep timer**, and toggles for **show subtitle timeline**, **show waveform on the seek bar** and **show metadata**.
  - Build: M5.5 · Refs: [09:05](https://youtu.be/ERFeOgqk324?t=545)
  - Open: G12
- **Bookmarks and chapters** live in the sidebar as a timeline list. **Ctrl+B adds a bookmark instantly.**
  - Why: Ctrl+B currently opens a dialog.
  - Build: M5.5 · Refs: [14:50](https://youtu.be/ERFeOgqk324?t=890)
- **Per-show presets.** Save the subtitle, audio and video settings for a show and re-apply them in one click.
  - Build: backlog · Refs: [07:40](https://youtu.be/ERFeOgqk324?t=460) · Figma 2372:8834
  - Open: G8
- **Add Subtitles dialog.**
  - Apply to **this file, this folder or this playlist**.
  - Source: this computer, or a site like **OpenSubtitles**.
  - Subtitles are **auto-matched** to episodes by name; you can match them **manually**, and manual matches are remembered.
  - Why: a downloaded subtitle pack rarely matches the episode names, so today you drag each file in by hand.
  - Build: M5.6 (local files), backlog (OpenSubtitles) · Refs: [05:50](https://youtu.be/ERFeOgqk324?t=350) · Figma 1911:7545, 3336:11929, 1919:8707, 1919:9278, 6456:13892
  - Open: G9

## G. Media visuals
- **Music now-playing screen.** Large cover art over a blurred backdrop, and "title – artist" below.
  - Build: M6.2 · Refs: [12:10](https://youtu.be/ERFeOgqk324?t=730) · Figma 4767:23726
- **Waveform seek bar** for audio, optional (Playback tab toggle).
  - Build: M6.3, M6.4 · Refs: [12:15](https://youtu.be/ERFeOgqk324?t=735) · Figma 4767:23726
  - Open: G6
- **Music sections:** Songs, Albums, Artists and Genres.
  - Build: M3.1 · Refs: [12:05](https://youtu.be/ERFeOgqk324?t=725)

## H. Library extended
- **Network streams.** A saved list of streams with an add button. Pasting an M3U link (such as GitHub's public IPTV lists) turns it into an automatic playlist.
  - Build: M7.1 · Refs: [12:22](https://youtu.be/ERFeOgqk324?t=742), [13:00](https://youtu.be/ERFeOgqk324?t=780) · Figma 6216:13614
- **Split Open dialogs.** The all-in-one "Open Media" factory becomes separate menu actions, each with its own small dialog: Open file, Open folder, Network stream, Capture device, Clipboard, Recent media, Convert, Stream to device.
  - Build: M7.1, M2.6 · Refs: [12:35](https://youtu.be/ERFeOgqk324?t=755)
- **New playlist:** name it, pick files, done. Any file can also be added to a playlist from its context menu.
  - Build: M7.1, M3.4 · Refs: [13:10](https://youtu.be/ERFeOgqk324?t=790) · Figma 6259:14954
- **Compact library beside the video.** Clicking the folder name in the top bar, or the sidebar icon, opens the library in compact mode next to the video. Drag items from it into the queue.
  - Build: M7.2 · Refs: [11:05](https://youtu.be/ERFeOgqk324?t=665) · Figma 187:328
  - Open: G19

## I. Settings and on-screen messages
- **Structure:**
  - 13 categories: General (theme, **accent color**), Interface, Privacy, Controls, Playback, Video, Audio, Subtitles (including on-screen messages), Library, Network, Performance, Recording (streaming and casting), Extensions.
  - Each page has its **basic settings first and its advanced settings below**, replacing the Simple/All split.
  - Build: M8.1–M8.3 · Refs: [16:01](https://youtu.be/ERFeOgqk324?t=961), [17:25](https://youtu.be/ERFeOgqk324?t=1045) · Figma 999:5047 … 6575:17137
- **Cleanup rules for every setting:**
  - Remove duplicates; one name per setting.
  - No subcategory with a single setting.
  - Every setting gets a **visible info icon** (no hover-only tooltips).
  - Numeric codes become **plain-language dropdowns**. Example: subtitle auto-detect fuzziness 0–4 becomes "No match, Any subtitle file, Contains the video name, Video name plus extra characters, Exact video name".
  - Build: M8.1–M8.3 · Refs: [16:30](https://youtu.be/ERFeOgqk324?t=990), [17:00](https://youtu.be/ERFeOgqk324?t=1020)
  - Open: G14
- **Extensions page** lists installable add-ons (extensions, skins). VLC's internal plugins move to the Advanced part.
  - Build: M8.3 · Refs: [18:25](https://youtu.be/ERFeOgqk324?t=1105) · Figma 6575:17137
- **Keyboard Shortcuts dialog** of its own, opened from the "…" menu.
  - Build: M8.4 · Refs: [15:40](https://youtu.be/ERFeOgqk324?t=940) · Figma 2437:14832
- **On-screen messages name the key.** When a shortcut fires, the message shows the key pressed as well as the action.
  - Why: an accidental key press today leaves you guessing what happened.
  - Build: backlog · Refs: [15:10](https://youtu.be/ERFeOgqk324?t=910)
  - Open: G13

## J. Onboarding
- **Onboarding** on first run: theme options and a screen introducing the basic shortcuts.
  - Why: about half of viewers want minimal customization, so the defaults must be good and the essentials introduced up front.
  - Build: M9.1 · Refs: [19:38](https://youtu.be/ERFeOgqk324?t=1178) · Figma 1899:3055 … 1902:6465

## Video vs Figma
_Filled in from the frame analysis._

## Frames
_Filled in from the frame analysis._
