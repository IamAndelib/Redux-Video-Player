# VLC Redux design brief

The streamlined guide to Juxtopposed's redesign: every design decision from the video, why it was made, and where
it lands in our code. Use this file while building. Go to the sources only to check a detail.

| Source | What it settles | Where |
|---|---|---|
| Figma `CAuJVJyM5yY7PnyQQK9X24` | **Visuals:** layout, sizes, colors, states | Node IDs below; code mapping in [`screen-map.md`](screen-map.md); exported frames in `source/frames/` |
| Video `ERFeOgqk324` | **Behavior and intent:** what things do and why | `t=` links below; full narration in [`transcript.md`](transcript.md) |
| Video frames | What the video shows that the Figma doesn't | `source/video-frames/` (git-ignored; regenerate from [`frame-picks.tsv`](frame-picks.tsv), see [Frames](#frames)) |

**When the sources disagree:** Figma wins on visuals, the video wins on behavior. Every conflict is listed in
[Video vs Figma](#video-vs-figma).

**Credit:** the designer says the redesign "will be open source and free to use". Credit Juxtopposed in the README
and About dialog (M10.1).

**How each entry reads:**
- **Decision** in bold, then why it was made (the old-VLC pain it fixes) and the details the frames show.
- **Build:** the milestone in `redux/milestones/ROADMAP.md` and the upstream code to reuse.
- **Refs:** video time, frame files (open them; they're the visual spec the Figma lacks), Figma nodes.
- **Open:** the matching row in `redux/milestones/GAPS.md`, if a question remains.

## Principles
These eight rules decide anything the entries below don't cover.

1. **Keep VLC's identity.** The cone and the orange stay; everything else is neutral gray and black.
2. **Rectangular, slightly softened.** No pills; small radii. The square shapes are part of VLC's personality. (The onboarding accent swatches are the one round exception, in both sources.)
3. **One quiet row.** Playback chrome is a thin bar that never covers the video.
4. **Put things where people look.** Tracks, settings and the queue go bottom-right; fullscreen sits with the window buttons top-right; the title goes top-center.
5. **Never make the user leave the video.** Library, tracks and settings open beside the video, not instead of it.
6. **Basic first, advanced below.** Every settings page shows common options first and advanced ones further down the same page. No separate expert mode.
7. **Use words, not numbers.** Options are named in plain language, and help text sits behind a visible info icon, never a hover-only tooltip.
8. **Customization is optional.** Good defaults; onboarding offers theme and shortcuts, and the layout editor is there for those who want it.

## B. Design system
- **Two icon sets.** Two-tone gray and orange icons for non-clickable places (menu item icons); monochrome icons for everything clickable.
  - Each two-tone icon is the monochrome glyph with one inner part filled orange, so a base layer plus an accent layer reproduces it.
  - Why: VLC's two-tone icons are recognizable but inconsistent.
  - Build: M1.4 (monochrome set), two-tone deferred.
  - Refs: [01:14](https://youtu.be/ERFeOgqk324?t=74) [`0114-icon-sets-two-tone-mono.jpg`](source/video-frames/0114-icon-sets-two-tone-mono.jpg) · Figma 42:356 (`two-tone=yes/no` variants)
  - Open: G16
- **Neutral palette plus one accent.** Neutral grays and black backgrounds; VLC orange as the default accent, user-changeable (General settings, 9 square swatches). Theme and accent apply live, to the whole window, while Settings is open.
  - Build: M1.1, M1.3, M9.2 (light theme)
  - Refs: [00:58](https://youtu.be/ERFeOgqk324?t=58) [`0058-palette-swatches.jpg`](source/video-frames/0058-palette-swatches.jpg) · [17:43](https://youtu.be/ERFeOgqk324?t=1063) [`1743-settings-light-theme.jpg`](source/video-frames/1743-settings-light-theme.jpg) · [17:46](https://youtu.be/ERFeOgqk324?t=1066) [`1746-accent-color-swatches.jpg`](source/video-frames/1746-accent-color-swatches.jpg) · Figma 999:5047, 2425:13624
- **Shapes.** Rectangles with a small radius.
  - Build: M1.2 (radius tokens)
  - Refs: [01:30](https://youtu.be/ERFeOgqk324?t=90) (the play button morphs from square to rounded; the radius shows in every frame) · Figma radii

## C. Player screen
- **The play button stays on the left**, slightly bigger, with previous and next on either side. No centered transport.
  - Why: a centered cluster makes the bar tall and covers the video, and most people play and pause from the keyboard.
  - Build: M2.1 · Refs: [01:54](https://youtu.be/ERFeOgqk324?t=114) [`0154-upstream-centered-controls.jpg`](source/video-frames/0154-upstream-centered-controls.jpg) (upstream VLC 4, rejected) · [02:14](https://youtu.be/ERFeOgqk324?t=134) · Figma 187:328
- **One thin row** holds all controls, and the **seek bar is thick** and sits in that row.
  - Order: previous, play, next, current time, seek bar, duration, volume icon and cone, audio, subtitles, settings, queue.
  - Seek bar: black thick track, dark-brown elapsed fill, accent rounded thumb.
  - Why: thin sliders are hard to hit, and a stacked bar hides the video.
  - Build: M2.1 · Refs: [03:12](https://youtu.be/ERFeOgqk324?t=192) · [03:23](https://youtu.be/ERFeOgqk324?t=203) [`0323-control-bar-one-row.jpg`](source/video-frames/0323-control-bar-one-row.jpg) · Figma 187:328, 491:1780
- **Fullscreen moves to the window buttons; settings move to the bottom-right.** Window buttons are minimize, maximize, fullscreen, close. The bottom bar has no fullscreen button.
  - The video tried picture-in-picture in the top bar too and left "up or down" open; Figma settles it (top, no PiP; PiP is a Customize item).
  - Build: M2.1, M2.3 · Refs: [02:18](https://youtu.be/ERFeOgqk324?t=138) · [04:04](https://youtu.be/ERFeOgqk324?t=244) [`0404-pip-fullscreen-up-or-down.jpg`](source/video-frames/0404-pip-fullscreen-up-or-down.jpg) · Figma 187:328
- **The volume control is a cone.** VLC's wedge slider becomes a full cone, filled up to the volume level (green in Figma, green to orange in the video) with the rest black. It's a level fill, not a live audio meter.
  - Why: keep VLC's spirit instead of a generic slider.
  - Build: M2.2 · Refs: [03:06](https://youtu.be/ERFeOgqk324?t=186) · [04:36](https://youtu.be/ERFeOgqk324?t=276) [`0436-tracks-popup-audio-output.jpg`](source/video-frames/0436-tracks-popup-audio-output.jpg) · Figma 244:184
- **Seek thumbnails.** Scrubbing the seek bar shows a rounded dark card with the frame and its timecode above the thumb.
  - Build: M6.1 · Refs: [03:30](https://youtu.be/ERFeOgqk324?t=210) [`0330-seek-thumbnail-card.jpg`](source/video-frames/0330-seek-thumbnail-card.jpg) · Figma 2151:9673
  - Open: G5
- **Audio and subtitle buttons, bottom-right**, in that order. Both open one **tracks popup** with tabs **Video | Audio | Subtitles**; the button's tab is active (accent underline).
  - Sections: Embedded Tracks (None, Track 1 - English, accent check); for subtitles, External Tracks with a + that opens Add Subtitles; for audio, **Output Device** (speakers, headphones) with a refresh icon. A full-width **Show Preferences** button opens the right sidebar.
  - Video tracks have no bar button; they're the popup's Video tab and the right-click menu.
  - **Active state:** a bar button whose popup or panel is open turns solid accent (subtitles, audio, settings, queue).
  - Why: today a subtitle change takes several nested right-click menus that keep closing, and upstream VLC 4 puts its tracks button bottom-left.
  - Build: M2.4 · Refs: [04:34](https://youtu.be/ERFeOgqk324?t=274) [`0434-tracks-popup-subtitles.jpg`](source/video-frames/0434-tracks-popup-subtitles.jpg) · [04:46](https://youtu.be/ERFeOgqk324?t=286) [`0446-tracks-popup-video-tab.jpg`](source/video-frames/0446-tracks-popup-video-tab.jpg) · Figma 1915:8397, 1919:9121
- **The playlist button becomes a Queue button.**
  - The **queue** auto-plays what's next. **Playlists** are saved collections. They're two separate concepts.
  - Queue panel: header "11 items - 4h 12m" with sort, repeat, shuffle, remove (−) and add (+); rows have a drag handle, file name and duration; the current item is accent with a ▷. It opens in the right-side slot the sidebar uses. Add by dragging files in or with +.
  - Build: M2.4 (button), M7.2 (panel) · Refs: [02:40](https://youtu.be/ERFeOgqk324?t=160) · [09:30](https://youtu.be/ERFeOgqk324?t=570) [`0930-queue-panel.jpg`](source/video-frames/0930-queue-panel.jpg)
- **Bookmarks and chapters are tabs of the queue panel**: Queue | Bookmarks | Chapters. **Ctrl+B adds a bookmark instantly.**
  - Bookmarks: "2 Bookmarks" with − and +; rows show a name and a time with milliseconds (00:00:42:023). Chapters: accent number, name, start time.
  - Why: Ctrl+B currently opens a dialog.
  - Build: M5.5 · Refs: [14:54](https://youtu.be/ERFeOgqk324?t=894) · [15:12](https://youtu.be/ERFeOgqk324?t=912) [`1512-bookmarks-tab.jpg`](source/video-frames/1512-bookmarks-tab.jpg)
- **Top bar.** Cone, one "…" menu, sidebar toggle, a divider, then a folder icon and the **name of the playing media's folder** ("S01", "My Songs"; at a section root, the section icon and "Videos"), the centered media title, and the window buttons. Clicking the folder name opens the compact library.
  - Build: M2.3 · Refs: [03:37](https://youtu.be/ERFeOgqk324?t=217) · [11:38](https://youtu.be/ERFeOgqk324?t=698) [`1138-top-bar-folder-name.jpg`](source/video-frames/1138-top-bar-folder-name.jpg) · Figma 187:328
- **Fullscreen keeps both bars.** Each bar appears when the pointer nears its edge and disappears the moment it moves away, so the title is always one move away.
  - Build: M2.5 · Refs: [03:48](https://youtu.be/ERFeOgqk324?t=228) [`0348-fullscreen-both-bars.jpg`](source/video-frames/0348-fullscreen-both-bars.jpg)
- **Hide UI.** A right-click entry, `Hide UI  Ctrl + \`, in its own group; the shortcut is **Ctrl+\\**.
  - Build: M2.5, M2.6 · Refs: [05:26](https://youtu.be/ERFeOgqk324?t=326) [`0526-context-menu-hide-ui.jpg`](source/video-frames/0526-context-menu-hide-ui.jpg) · Figma 3328:11554
- **One menu instead of two.** The old top menu bar and the right-click menu duplicate each other. They merge into one "…" menu, and the right-click menu is cleaned up and restyled. Menu items use the two-tone icons and show their shortcuts.
  - Final "…" menu: Open File(s) Ctrl+O, Open Folder(s) Ctrl+F, Open Disc Ctrl+D, Open Network Stream Ctrl+N, Open Capture Device Ctrl+C, Open from Clipboard Ctrl+V, Convert Ctrl+R, Stream Ctrl+S, Open Recent ›, divider, Customize Player, Plugins & Extensions ›, Settings Ctrl+P, About VLC Shift+F1. Later versions add Profile › and Keyboard Shortcuts (section E).
  - Right-click menu: Play Space, Stop S, Previous Item P, Next Item N, Record R | Playback ›, Video ›, Audio ›, Subtitle › | More Settings ›, Playlist ›, Open Media ›, Quit VLC Ctrl+Q | Hide UI Ctrl+\\.
  - Build: M2.6 · Refs: [05:04](https://youtu.be/ERFeOgqk324?t=304) [`0504-old-menubar-and-context-menu.jpg`](source/video-frames/0504-old-menubar-and-context-menu.jpg) · [13:09](https://youtu.be/ERFeOgqk324?t=789) [`1309-app-menu-cleaned.jpg`](source/video-frames/1309-app-menu-cleaned.jpg) · Figma 6065:13616, 6062:13354
- **Resume prompt near the controls.** A bottom-center card just above the control bar: "You already watched till 00:00:02", an accent **Continue Watching** button, and ✕. It replaces the banner at the top of the window.
  - Why: the prompt only lasts a few seconds.
  - Build: M2.5 · Refs: [13:58](https://youtu.be/ERFeOgqk324?t=838) [`1358-resume-prompt-old.jpg`](source/video-frames/1358-resume-prompt-old.jpg) · [14:08](https://youtu.be/ERFeOgqk324?t=848) [`1408-resume-prompt-new.jpg`](source/video-frames/1408-resume-prompt-new.jpg)

## D. Library
- **Sections:** Home, Videos, Music, Network, Playlists, Recent, pinned items, and "+ Add item". The label is "Network", not "Network streams".
  - Build: M3.1 · Refs: [10:22](https://youtu.be/ERFeOgqk324?t=622) · [13:47](https://youtu.be/ERFeOgqk324?t=827) [`1347-sidebar-rail-home-recent-pins.jpg`](source/video-frames/1347-sidebar-rail-home-recent-pins.jpg) · Figma 848:1996
- **Header:** back and forward buttons, a clickable breadcrumb **address bar** ("Videos › Shows › The Wand › S01"), then "15 items", sort, view toggle (grid, list, detail), search and a "…" menu.
  - Why: today sorting hides in the right-click menu, and the view icon doesn't show its state.
  - Build: M3.2 · Refs: [10:24](https://youtu.be/ERFeOgqk324?t=624) · [10:58](https://youtu.be/ERFeOgqk324?t=658) [`1058-library-full-grid.jpg`](source/video-frames/1058-library-full-grid.jpg) · Figma 970:3308, 856:2215, 858:3290
- **Sort menu:** Unwatched First, Watched First, Newest First, Oldest First, Title A-Z, Title Z-A. The active option has an accent check.
  - Build: M3.2 · Refs: [10:47](https://youtu.be/ERFeOgqk324?t=647) [`1048-library-sort-menu.jpg`](source/video-frames/1048-library-sort-menu.jpg) · Figma 856:2215
- **A "…" menu in the header:** Add File, Add Folder, Edit Subtitle Tracks, Edit Audio Tracks, Resync, Info.
  - Build: M3.2, M3.4 · Refs: [10:53](https://youtu.be/ERFeOgqk324?t=653) [`1055-library-header-more-menu.jpg`](source/video-frames/1055-library-header-more-menu.jpg)
- **Folders are first-class.** The library browses by folder, not one flat pile of files.
  - Why: today everything shows side by side regardless of folder, and adding media goes through a hidden "Browse" view.
  - Build: M3.2 · Refs: [09:36](https://youtu.be/ERFeOgqk324?t=576) (old flat library) · [`1058-library-full-grid.jpg`](source/video-frames/1058-library-full-grid.jpg) · Figma 970:3308
- **Watched progress.** Watched items get a dimmed title and a full-width accent underline; partly watched ones a partial underline.
  - Build: M3.3 · Refs: [10:58](https://youtu.be/ERFeOgqk324?t=658) [`1058-library-full-grid.jpg`](source/video-frames/1058-library-full-grid.jpg) · Figma 970:3308
- **Context menus** for files, folders and playlists, opened from a "…" that appears on row hover or by right-click.
  - File menu: Play, Mark as Watched, Favorite, Stream, Convert, Add to Queue, Add to Playlist, Show in File Explorer, Add Subtitle Tracks, Add Audio Tracks (continues below the frame; use Figma 2404:13340 for the rest).
  - Build: M3.4 · Refs: [13:32](https://youtu.be/ERFeOgqk324?t=812) [`1332-file-context-menu.jpg`](source/video-frames/1332-file-context-menu.jpg) · Figma 2404:13340, 2139:8935, 2459:9389
- **Full-window library with a floating miniplayer card** and the queue, both draggable.
  - The queue panel (titled "Queue") sits bottom-right above the miniplayer.
  - Miniplayer: on hover, close, pop-out, previous, play and next over the video; below it a thin seek bar, the title, the folder ("S01") and an accent queue toggle.
  - Build: M3.5 · Refs: [11:50](https://youtu.be/ERFeOgqk324?t=710) · [11:56](https://youtu.be/ERFeOgqk324?t=716) [`1156-full-library-miniplayer-queue.jpg`](source/video-frames/1156-full-library-miniplayer-queue.jpg) · Figma 970:3308, 970:3091
- **Home page:** Continue Watching, Listen Again and Frequently Visited Folders, each with a "›" to see more, so VLC never opens to a blank cone.
  - Build: M3.6 · Refs: [13:46](https://youtu.be/ERFeOgqk324?t=826) · [13:52](https://youtu.be/ERFeOgqk324?t=832) [`1352-home-page.jpg`](source/video-frames/1352-home-page.jpg)
- **Recent tab and pins.** Pin favorite playlists and folders to the sidebar rail.
  - Build: M3.1, M3.6 · Refs: [13:40](https://youtu.be/ERFeOgqk324?t=820) [`1347-sidebar-rail-home-recent-pins.jpg`](source/video-frames/1347-sidebar-rail-home-recent-pins.jpg) · Figma 848:1996

## E. Customize Player
- **Customization is a drag-and-drop canvas over the player.** One frame in the middle holds every available item; dashed outlines mark every movable slot on both bars, and the seek bar is a slot of its own.
  - Text: "Drag items around and out of the box below to re-order them. Drag items into the box to remove them from the player." Cancel, and Save, which stays disabled until something changes.
  - Why: the current editor is hard to use.
  - Build: M4.2 · Refs: [19:14](https://youtu.be/ERFeOgqk324?t=1154) · [19:22](https://youtu.be/ERFeOgqk324?t=1162) [`1922-customize-player-canvas.jpg`](source/video-frames/1922-customize-player-canvas.jpg) · Figma 2107:5604 … 2160:8732
- **Items (31):** Spacer, Divider, Playback Speed, Forward and Backward 10s and 15s, Stop, Repeat, Shuffle, Record, Snapshot, Picture in Picture, HDR, Zoom, Right Sidebar, Quit VLC, VLC Settings, Go Home, Thumbnail, File Name, Artist Name, Folder Name, Playlist Name, Properties, Replay, Chapters, Favorite, Bookmark, Bookmarks, Playlists.
  - Favorite matches the per-file Favorite action in the context menu.
  - Build: M4.1 · Refs: [19:16](https://youtu.be/ERFeOgqk324?t=1156) [`1922-customize-player-canvas.jpg`](source/video-frames/1922-customize-player-canvas.jpg) · Figma 2107:5604
  - Open: G3 (HDR, Replay, Properties, Go Home)
- **Profiles.** Layouts, and all other settings, are saved per VLC profile. The switcher lives in the "…" menu as "Profile (Movies) ›": Movies, Shows, Music, Work, + New, with a check on the active one.
  - Build: M4.2 · Refs: [19:34](https://youtu.be/ERFeOgqk324?t=1174) [`1934-menu-profile-submenu.jpg`](source/video-frames/1934-menu-profile-submenu.jpg) · Figma 6648:20666
- **The alternate layout shown in the video** is an example of what a user can build, not a second default: the top bar shrinks to the cone and window buttons; the seek bar gets its own row; "…", sidebar toggle, folder, title and a Favorite heart move bottom-left; transport is centered.
  - Refs: [19:28](https://youtu.be/ERFeOgqk324?t=1168) [`1928-alternate-layout.jpg`](source/video-frames/1928-alternate-layout.jpg)

## F. Right sidebar
A sidebar on the right replaces the "Adjustments and Effects" window that covers half the screen. It opens from the
settings button or the tracks popup's Show Preferences. Its **four tabs, left to right: Playback, Video, Audio,
Subtitles** (Subtitles is the default). Each tab ends with a preset selector and an "Open Advanced Settings" link.

- **Subtitles tab:**
  - Defaults: Subtitle Track and Subtitle Language, selected automatically for every episode.
  - Synchronization: Subtitle Track Delay (−10 s to +10 s), Subtitle Speed (fps), Subtitle Duration Factor; each a field plus a **slider** instead of typed spinboxes.
  - Appearance: Embedded Sub Format toggle, Subtitle Font, Text Color and Outline Color (hex plus swatch), Subtitle Offset (px), **Size Values: Relative | Pixels**, Font Size, Outline Thickness, Background Opacity. Relative shows sliders (Auto, Normal); Pixels shows px fields. (Exact sizes are today hidden deep in Advanced settings.)
  - Build: M5.4 · Refs: [06:42](https://youtu.be/ERFeOgqk324?t=402) [`0642-old-sync-spinboxes.jpg`](source/video-frames/0642-old-sync-spinboxes.jpg) (before) · [07:12](https://youtu.be/ERFeOgqk324?t=432) · [07:22](https://youtu.be/ERFeOgqk324?t=442) [`0722-sidebar-subtitles-sync-sliders.jpg`](source/video-frames/0722-sidebar-subtitles-sync-sliders.jpg) · [07:50](https://youtu.be/ERFeOgqk324?t=470) [`0750-sidebar-subtitles-appearance.jpg`](source/video-frames/0750-sidebar-subtitles-appearance.jpg) · [08:40](https://youtu.be/ERFeOgqk324?t=520) [`0840-sidebar-subtitles-defaults.jpg`](source/video-frames/0840-sidebar-subtitles-defaults.jpg) · Figma 3180:17989
- **Subtitle timeline.** With "Show Subtitle Timeline on Seekbar" on, the seek bar zooms to a window around the playhead (its times marked with `*`) and draws each cue as a block, accent when played and gray when upcoming. Accent ‹ − and + › buttons at the two ends nudge the timing. You pause on the audio and drag the subtitles into sync.
  - Why: syncing today means typing a delay, closing the window, rewinding, and repeating.
  - Build: backlog · Refs: [06:56](https://youtu.be/ERFeOgqk324?t=416) [`0656-subtitle-timeline-seekbar.jpg`](source/video-frames/0656-subtitle-timeline-seekbar.jpg)
  - Open: G7 (where the cue times come from)
- **Audio tab:**
  - Defaults: Audio Track, Audio Language, Stereo Mode (dropdown, e.g. Mono) with a Test button.
  - Synchronization: Audio Track Delay slider.
  - Filters: Equalizer with a **preset dropdown that has a curve icon per preset**, 2 Pass, then Compressor, Spatializer and Stereo Widener as **cards with an ON/OFF toggle and an "Expand Settings ›" row**, and Adjust Pitch (semitones).
  - Fix the design's typos: the delay slider's right label reads "-10 s" (should be "+10 s") and "Full base" should be "Full bass".
  - Build: M5.2 · Refs: [08:42](https://youtu.be/ERFeOgqk324?t=522) [`0842-sidebar-audio-tab.jpg`](source/video-frames/0842-sidebar-audio-tab.jpg) · [08:48](https://youtu.be/ERFeOgqk324?t=528) [`0848-audio-filter-cards.jpg`](source/video-frames/0848-audio-filter-cards.jpg) · [08:54](https://youtu.be/ERFeOgqk324?t=534) [`0854-eq-preset-menu.jpg`](source/video-frames/0854-eq-preset-menu.jpg) · Figma 6114:13610, 536:1513, 536:1703, 612:1223, 2372:8487
- **Video tab:** Flip (None | Horizontal | Vertical), Rotate (deg), Zoom, HDR, Resolution, Aspect Ratio, Crop and Render, then Filters › Essential, Crop, Colors.
  - The video never shows the filter previews; build them from the Figma panels.
  - Build: M5.3 · Refs: [08:58](https://youtu.be/ERFeOgqk324?t=538) [`0858-sidebar-video-tab.jpg`](source/video-frames/0858-sidebar-video-tab.jpg) · Figma 536:1855, 543:990, 614:1430, 2372:8733
  - Open: G10, G11
- **Playback tab:** toggles Show Subtitle Timeline on Seekbar, Show Waveform on Seekbar, Show Metadata and **Reverse**; **Sleep Timer** and **Audio Visualizer** dropdowns; Speed slider from 0.25 to 2 with ticks.
  - Build: M5.5 · Refs: [09:08](https://youtu.be/ERFeOgqk324?t=548) · [09:18](https://youtu.be/ERFeOgqk324?t=558) [`0918-sidebar-playback-tab.jpg`](source/video-frames/0918-sidebar-playback-tab.jpg)
  - Open: G12
- **Presets.** A preset is a user-named bundle of the sidebar's settings across all tabs ("Anime", "Loud and then Quiet Movies", "The Wand Subtitle Preset"), not something tied to a folder automatically. The menu has "+ New Custom Preset", a "…" menu per preset and an accent check on the active one.
  - Build: backlog · Refs: [07:56](https://youtu.be/ERFeOgqk324?t=476) · [08:00](https://youtu.be/ERFeOgqk324?t=480) [`0800-preset-menu.jpg`](source/video-frames/0800-preset-menu.jpg) · Figma 2372:8834
  - Open: G8
- **Add Subtitles dialog**, opened from External Tracks +.
  - Scope: To This File, To This Folder, To This Playlist. Source: From Computer, From OpenSubtitles, From Link …. Plus a search field and a language dropdown.
  - Rows pair each video with a subtitle file, **auto-matched** by name; hovering a row shows a ⇄ swap icon to **match manually**, and manual matches are remembered. Cancel, and an accent Save.
  - Why: a downloaded subtitle pack rarely matches the episode names, so today you drag each file in by hand.
  - Build: M5.6 (local files), backlog (OpenSubtitles, links) · Refs: [06:02](https://youtu.be/ERFeOgqk324?t=362) · [06:06](https://youtu.be/ERFeOgqk324?t=366) [`0606-add-subtitles-scope-menu.jpg`](source/video-frames/0606-add-subtitles-scope-menu.jpg) · [06:12](https://youtu.be/ERFeOgqk324?t=372) [`0612-add-subtitles-source-menu.jpg`](source/video-frames/0612-add-subtitles-source-menu.jpg) · [06:20](https://youtu.be/ERFeOgqk324?t=380) [`0620-add-subtitles-match-dialog.jpg`](source/video-frames/0620-add-subtitles-match-dialog.jpg) · Figma 1911:7545, 3336:11929, 1919:8707, 1919:9278, 6456:13892
  - Open: G9

## G. Media visuals
- **Music now-playing screen.** Large cover art over a blurred backdrop, "title - artist" below, and ±15 s skip buttons beside play.
  - Build: M6.2 · Refs: [12:16](https://youtu.be/ERFeOgqk324?t=736) [`1216-music-now-playing.jpg`](source/video-frames/1216-music-now-playing.jpg) · Figma 4767:23726
- **Waveform seek bar** for audio, optional (Playback tab toggle): the played part in the accent color with a thick accent playhead.
  - Build: M6.3, M6.4 · Refs: [12:20](https://youtu.be/ERFeOgqk324?t=740) [`1216-music-now-playing.jpg`](source/video-frames/1216-music-now-playing.jpg) · Figma 4767:23726
  - Open: G6
- **Music sections:** Songs, Albums, Artists and Genres; lists start with a "+ Add" row.
  - Build: M3.1 · Refs: [12:10](https://youtu.be/ERFeOgqk324?t=730) [`1210-music-sections.jpg`](source/video-frames/1210-music-sections.jpg)

## H. Library extended
- **Network streams.** A saved list with "+ Add Network Stream", Podcasts and Radio by default. Pasting an M3U link (the video uses `https://iptv-org.github.io/iptv/index.m3u`) turns it into an automatic playlist ("Index", 110 items).
  - Build: M7.1 · Refs: [12:22](https://youtu.be/ERFeOgqk324?t=742) · [12:24](https://youtu.be/ERFeOgqk324?t=744) [`1224-network-streams-list.jpg`](source/video-frames/1224-network-streams-list.jpg) · [13:14](https://youtu.be/ERFeOgqk324?t=794) · Figma 6216:13614
- **Split Open dialogs.** The all-in-one "Open Media" factory becomes separate "…" menu actions (list in section C), each with its own small dialog.
  - Open Network Stream: "Network URL" ("You can enter multiple links to load.") over a multi-line field, "Playlist Name (optional)" ("The playlist will be saved and displayed with this title."), Cancel and Save.
  - Build: M7.1, M2.6 · Refs: [12:58](https://youtu.be/ERFeOgqk324?t=778) · [13:10](https://youtu.be/ERFeOgqk324?t=790) [`1310-open-network-stream-dialog.jpg`](source/video-frames/1310-open-network-stream-dialog.jpg) · Figma 6216:13614
- **New playlist:** Playlist Details (name and thumbnail), Select Files (a dashed drop zone: "Drag files into the box or click here to select files.", with +), Cancel and Save. The Playlists view starts with a "+ Create playlist" row, and any file can be added from its context menu.
  - Build: M7.1, M3.4 · Refs: [13:24](https://youtu.be/ERFeOgqk324?t=804) · [13:28](https://youtu.be/ERFeOgqk324?t=808) [`1328-new-playlist-dialog.jpg`](source/video-frames/1328-new-playlist-dialog.jpg) · Figma 6259:14954
- **Compact library beside the video.** Clicking the folder name in the top bar, or the sidebar toggle, opens the library on the left of the video: an icon-only rail, a header with back and forward, a truncated breadcrumb, "…" and a pop-out button to the full window, then "15 items" with sort, view and search. The queue floats on the right; drag items from the library into it.
  - This is the panel in Figma 187:328 (its "Playlists" header is one of the library sections).
  - Build: M7.2 · Refs: [11:26](https://youtu.be/ERFeOgqk324?t=686) · [11:46](https://youtu.be/ERFeOgqk324?t=706) [`1146-compact-library-drag-to-queue.jpg`](source/video-frames/1146-compact-library-drag-to-queue.jpg) · Figma 187:328

## I. Settings and on-screen messages
- **Structure:**
  - 13 categories in three groups, with search at the top-left: **App** (General, Interface, Privacy, Controls), **Media** (Playback, Video, Audio, Subtitles, Library), **System** (Network, Performance, Recording, Extensions).
  - Page titles differ from the sidebar labels: Global Settings, Mouse, Keyboard & Remote Controls, Playback Preferences, Video Defaults, Audio Defaults, Subtitle Defaults, Playlists, Folders & Files, Network Connections & Security, Recording, Casting & Streaming Out, Extensions & Scripts.
  - Each page has its **basic settings first, then a full-width "Advanced Options ›" bar that expands in place**, replacing the Simple/All split. Toggles are square two-part ON/OFF switches; sliders have ticks.
  - Build: M8.1–M8.3 · Refs: [17:36](https://youtu.be/ERFeOgqk324?t=1056) · [17:40](https://youtu.be/ERFeOgqk324?t=1060) [`1740-settings-general-page.jpg`](source/video-frames/1740-settings-general-page.jpg) · [18:52](https://youtu.be/ERFeOgqk324?t=1132) [`1852-settings-advanced-expanded.jpg`](source/video-frames/1852-settings-advanced-expanded.jpg) · Figma 999:5047 … 6575:17137
- **Cleanup rules for every setting:**
  - Remove duplicates; one name per setting.
  - No subcategory with a single setting.
  - Help text sits behind a **visible info icon**, not a hover-only tooltip. (Some rows in the frames have no icon; give one to every setting that has help text.)
  - Numeric codes become **plain-language dropdowns**. Example: subtitle auto-detect fuzziness 0–4 becomes **File name matching** (Subtitles › Loading Subtitles): Off, Any title, Contains title, Title with extra characters, Exact title match.
  - Build: M8.1–M8.3 · Refs: [16:38](https://youtu.be/ERFeOgqk324?t=998) · [17:16](https://youtu.be/ERFeOgqk324?t=1036) [`1716-old-subtitle-fuzziness.jpg`](source/video-frames/1716-old-subtitle-fuzziness.jpg) · [17:30](https://youtu.be/ERFeOgqk324?t=1050) [`1730-file-name-matching-dropdown.jpg`](source/video-frames/1730-file-name-matching-dropdown.jpg) · [18:10](https://youtu.be/ERFeOgqk324?t=1090) [`1810-settings-subtitles-page.jpg`](source/video-frames/1810-settings-subtitles-page.jpg)
  - Open: G14
- **Extensions page** ("Extensions & Scripts"): a list with search, Find more extensions, Add and Remove, and "Load extensions on startup". VLC's internal plugins move to the Advanced part (the frames don't show where).
  - Build: M8.3 · Refs: [18:26](https://youtu.be/ERFeOgqk324?t=1106) [`1827-settings-extensions-page.jpg`](source/video-frames/1827-settings-extensions-page.jpg) · Figma 6575:17137
- **Keyboard Shortcuts dialog** of its own: search, an "All Fields" filter, columns Action / Hotkey / Global Hotkey, groups (Basic, Playback …), Cancel and Save. It opens from the "…" menu and from "Edit Keyboard Shortcuts" on the Controls page.
  - Build: M8.4 · Refs: [16:00](https://youtu.be/ERFeOgqk324?t=960) [`1600-keyboard-shortcuts-dialog.jpg`](source/video-frames/1600-keyboard-shortcuts-dialog.jpg) · [17:58](https://youtu.be/ERFeOgqk324?t=1078) [`1758-settings-controls-page.jpg`](source/video-frames/1758-settings-controls-page.jpg) · Figma 2437:14832
- **On-screen messages name the key.** Two lines: the action ("Crop: 2.35:1") and, smaller and gray, "Pressed C". Controlled by "Show feedback for shortcuts" and a duration slider on the Subtitles page.
  - Why: an accidental key press today leaves you guessing what happened.
  - Build: backlog · Refs: [15:18](https://youtu.be/ERFeOgqk324?t=918) · [15:26](https://youtu.be/ERFeOgqk324?t=926) [`1526-osd-pressed-key.jpg`](source/video-frames/1526-osd-pressed-key.jpg) · [18:14](https://youtu.be/ERFeOgqk324?t=1094)
  - Open: G13 (core change or QML overlay)

## J. Onboarding
- **Onboarding** on first run, **three steps**:
  1. "Welcome to VLC!": a short description and "Choose a Media Folder to get started with" (~/Videos, Browse). Next.
  2. "Select your preferred theme and color.": Light, Dark and System cards over a live preview, and 9 round accent swatches. Back, Next.
  3. "Learn the basic keyboard shortcuts.": 12 pairs (Play / Pause Space, Seek ← →, Previous / Next Item < >, Previous / Next Frame , ., Cycle Subtitle Track V, Cycle Audio Track B, Toggle Fullscreen F, Volume ↑ ↓, Show / Hide Queue Q, Show / Hide File Browser L, Take a Snapshot Shift+S, Record Shift+R) and "Find the full list in the menu." Back, Finish.
  - Why: about half of viewers want minimal customization, so the defaults must be good and the essentials introduced up front.
  - Build: M9.1 · Refs: [19:48](https://youtu.be/ERFeOgqk324?t=1188) [`1948-onboarding-welcome.jpg`](source/video-frames/1948-onboarding-welcome.jpg) · [19:50](https://youtu.be/ERFeOgqk324?t=1190) [`1950-onboarding-theme.jpg`](source/video-frames/1950-onboarding-theme.jpg) · [19:52](https://youtu.be/ERFeOgqk324?t=1192) [`1952-onboarding-shortcuts.jpg`](source/video-frames/1952-onboarding-shortcuts.jpg) · Figma 1899:3055 (step 1), 1902:3670 … 1902:6465 (step 2, one frame per accent), 1902:6770 (step 3)

## Video vs Figma
Figma wins on visuals and the video on behavior, unless a row says otherwise.

| Item | Video shows | Figma shows | Build from |
|---|---|---|---|
| Fullscreen button | An exit-fullscreen icon bottom-right once ([03:48](https://youtu.be/ERFeOgqk324?t=228)); "up or down?" ([04:04](https://youtu.be/ERFeOgqk324?t=244)) | With the window buttons, top-right; none in the bottom bar (187:328) | Figma |
| Window buttons | Minimize, PiP, maximize, fullscreen, close ([04:00](https://youtu.be/ERFeOgqk324?t=240)) | Minimize, maximize, fullscreen, close | Figma; PiP is a Customize item |
| Volume cone fill | Green to orange gradient ([04:36](https://youtu.be/ERFeOgqk324?t=276)) | Green fill (187:328, 244:184) | Figma |
| Video tracks | A tab of the bar's tracks popup ([04:46](https://youtu.be/ERFeOgqk324?t=286)) | Only subtitle popups (1915:8397, 1919:9121) | Video |
| Bookmarks and chapters | Tabs of the queue panel ([15:12](https://youtu.be/ERFeOgqk324?t=912)) | Not drawn | Video |
| Right sidebar tab order | Playback, Video, Audio, Subtitles ([09:18](https://youtu.be/ERFeOgqk324?t=558)) | Panels only, no tab bar | Video |
| Video filter previews | Never shown | Video panels (536:1855, 543:990, 614:1430) | Figma |
| Home page | Continue Watching, Listen Again, Frequently Visited Folders ([13:52](https://youtu.be/ERFeOgqk324?t=832)) | Not drawn | Video |
| Onboarding | 3 steps ([19:48](https://youtu.be/ERFeOgqk324?t=1188)–[19:52](https://youtu.be/ERFeOgqk324?t=1192)) | 12 frames: the same 3 steps, step 2 once per accent | Both agree: 3 steps |
| Accent swatches | Round in onboarding, square in Settings | Same | Keep as drawn |
| Info icons | Missing on some rows ([17:58](https://youtu.be/ERFeOgqk324?t=1078), [18:10](https://youtu.be/ERFeOgqk324?t=1090)) | Same | Narration: every setting with help text gets one |
| Design typos | Audio delay label "-10 s" on the right; "Full base" ([08:42](https://youtu.be/ERFeOgqk324?t=522), [08:54](https://youtu.be/ERFeOgqk324?t=534)) | — | Fix: "+10 s", "Full bass" |

## Frames
The 62 reference frames live in `redux/design/source/video-frames/` (git-ignored, about 3.5 MB). Regenerate them
with `redux/dev.sh run redux/tools/video-frames.sh` after putting the 1080p video at `redux/design/source/video.mp4`
(see `redux/milestones/M0.4-video-brief.md`, step 1). `index.tsv` in that folder lists them too.

| Frame | Time | Shows | Used in |
|---|---|---|---|
| [`0058-palette-swatches.jpg`](source/video-frames/0058-palette-swatches.jpg) | [00:58](https://youtu.be/ERFeOgqk324?t=58) | Palette: orange shades, neutral grays and near-blacks | B |
| [`0114-icon-sets-two-tone-mono.jpg`](source/video-frames/0114-icon-sets-two-tone-mono.jpg) | [01:14](https://youtu.be/ERFeOgqk324?t=74) | Same glyphs as two-tone decorative and monochrome clickable sets | B |
| [`0154-upstream-centered-controls.jpg`](source/video-frames/0154-upstream-centered-controls.jpg) | [01:54](https://youtu.be/ERFeOgqk324?t=114) | Upstream VLC 4 centered transport, the layout she rejects | C |
| [`0323-control-bar-one-row.jpg`](source/video-frames/0323-control-bar-one-row.jpg) | [03:23](https://youtu.be/ERFeOgqk324?t=203) | Final one-row bar: play left, thick seek, cone volume | C |
| [`0330-seek-thumbnail-card.jpg`](source/video-frames/0330-seek-thumbnail-card.jpg) | [03:30](https://youtu.be/ERFeOgqk324?t=210) | Seek preview card with frame and timecode above the bar | C |
| [`0348-fullscreen-both-bars.jpg`](source/video-frames/0348-fullscreen-both-bars.jpg) | [03:48](https://youtu.be/ERFeOgqk324?t=228) | Fullscreen keeps both bars with centered title | C |
| [`0404-pip-fullscreen-up-or-down.jpg`](source/video-frames/0404-pip-fullscreen-up-or-down.jpg) | [04:04](https://youtu.be/ERFeOgqk324?t=244) | PiP and fullscreen shown in both bars, placement left open | C |
| [`0434-tracks-popup-subtitles.jpg`](source/video-frames/0434-tracks-popup-subtitles.jpg) | [04:34](https://youtu.be/ERFeOgqk324?t=274) | Subtitles popup: embedded and external tracks, Show Preferences | C |
| [`0436-tracks-popup-audio-output.jpg`](source/video-frames/0436-tracks-popup-audio-output.jpg) | [04:36](https://youtu.be/ERFeOgqk324?t=276) | Audio popup: tracks plus output device with refresh | C |
| [`0446-tracks-popup-video-tab.jpg`](source/video-frames/0446-tracks-popup-video-tab.jpg) | [04:46](https://youtu.be/ERFeOgqk324?t=286) | Tracks popup with Video, Audio and Subtitles tabs | C |
| [`0504-old-menubar-and-context-menu.jpg`](source/video-frames/0504-old-menubar-and-context-menu.jpg) | [05:04](https://youtu.be/ERFeOgqk324?t=304) | Before: old menu bar and right-click menu duplicate each other | C |
| [`0526-context-menu-hide-ui.jpg`](source/video-frames/0526-context-menu-hide-ui.jpg) | [05:26](https://youtu.be/ERFeOgqk324?t=326) | New right-click menu with Hide UI (Ctrl+\) | C |
| [`0606-add-subtitles-scope-menu.jpg`](source/video-frames/0606-add-subtitles-scope-menu.jpg) | [06:06](https://youtu.be/ERFeOgqk324?t=366) | Add subtitles to this file, folder or playlist | F |
| [`0612-add-subtitles-source-menu.jpg`](source/video-frames/0612-add-subtitles-source-menu.jpg) | [06:12](https://youtu.be/ERFeOgqk324?t=372) | Subtitle source: computer, OpenSubtitles or link | F |
| [`0620-add-subtitles-match-dialog.jpg`](source/video-frames/0620-add-subtitles-match-dialog.jpg) | [06:20](https://youtu.be/ERFeOgqk324?t=380) | Add Subtitles dialog matching videos to subtitle files | F |
| [`0642-old-sync-spinboxes.jpg`](source/video-frames/0642-old-sync-spinboxes.jpg) | [06:42](https://youtu.be/ERFeOgqk324?t=402) | Before: old Adjustments and Effects synchronization spinboxes | F |
| [`0656-subtitle-timeline-seekbar.jpg`](source/video-frames/0656-subtitle-timeline-seekbar.jpg) | [06:56](https://youtu.be/ERFeOgqk324?t=416) | Subtitle cue blocks on a zoomed seek bar | F |
| [`0722-sidebar-subtitles-sync-sliders.jpg`](source/video-frames/0722-sidebar-subtitles-sync-sliders.jpg) | [07:22](https://youtu.be/ERFeOgqk324?t=442) | Sidebar Subtitles tab: delay, speed and duration sliders | F |
| [`0750-sidebar-subtitles-appearance.jpg`](source/video-frames/0750-sidebar-subtitles-appearance.jpg) | [07:50](https://youtu.be/ERFeOgqk324?t=470) | Subtitle appearance with Relative/Pixels size values | F |
| [`0800-preset-menu.jpg`](source/video-frames/0800-preset-menu.jpg) | [08:00](https://youtu.be/ERFeOgqk324?t=480) | Preset menu with New Custom Preset | F |
| [`0840-sidebar-subtitles-defaults.jpg`](source/video-frames/0840-sidebar-subtitles-defaults.jpg) | [08:40](https://youtu.be/ERFeOgqk324?t=520) | Default subtitle track and language above synchronization | F |
| [`0842-sidebar-audio-tab.jpg`](source/video-frames/0842-sidebar-audio-tab.jpg) | [08:42](https://youtu.be/ERFeOgqk324?t=522) | Audio tab: track, language, stereo mode, delay | F |
| [`0848-audio-filter-cards.jpg`](source/video-frames/0848-audio-filter-cards.jpg) | [08:48](https://youtu.be/ERFeOgqk324?t=528) | Audio filter cards with toggle and Expand Settings | F |
| [`0854-eq-preset-menu.jpg`](source/video-frames/0854-eq-preset-menu.jpg) | [08:54](https://youtu.be/ERFeOgqk324?t=534) | Equalizer preset dropdown with curve preview icons | F |
| [`0858-sidebar-video-tab.jpg`](source/video-frames/0858-sidebar-video-tab.jpg) | [08:58](https://youtu.be/ERFeOgqk324?t=538) | Video tab: flip, rotate, zoom, HDR, resolution, aspect | F |
| [`0918-sidebar-playback-tab.jpg`](source/video-frames/0918-sidebar-playback-tab.jpg) | [09:18](https://youtu.be/ERFeOgqk324?t=558) | Playback tab: timeline, waveform, reverse, sleep timer, speed | F |
| [`0930-queue-panel.jpg`](source/video-frames/0930-queue-panel.jpg) | [09:30](https://youtu.be/ERFeOgqk324?t=570) | Queue panel: item count, duration, sort, repeat, shuffle | C |
| [`1048-library-sort-menu.jpg`](source/video-frames/1048-library-sort-menu.jpg) | [10:48](https://youtu.be/ERFeOgqk324?t=648) | Sort menu with Unwatched First and Watched First | D |
| [`1055-library-header-more-menu.jpg`](source/video-frames/1055-library-header-more-menu.jpg) | [10:55](https://youtu.be/ERFeOgqk324?t=655) | Library header menu: add file or folder, tracks, info | D |
| [`1058-library-full-grid.jpg`](source/video-frames/1058-library-full-grid.jpg) | [10:58](https://youtu.be/ERFeOgqk324?t=658) | Library grid with breadcrumb and watched underlines | D |
| [`1138-top-bar-folder-name.jpg`](source/video-frames/1138-top-bar-folder-name.jpg) | [11:38](https://youtu.be/ERFeOgqk324?t=698) | Top bar shows the playing folder name | C |
| [`1146-compact-library-drag-to-queue.jpg`](source/video-frames/1146-compact-library-drag-to-queue.jpg) | [11:46](https://youtu.be/ERFeOgqk324?t=706) | Compact library beside video, dragging into the queue | H |
| [`1156-full-library-miniplayer-queue.jpg`](source/video-frames/1156-full-library-miniplayer-queue.jpg) | [11:56](https://youtu.be/ERFeOgqk324?t=716) | Full library with miniplayer card and queue | D |
| [`1210-music-sections.jpg`](source/video-frames/1210-music-sections.jpg) | [12:10](https://youtu.be/ERFeOgqk324?t=730) | Music section: Add, Songs, Albums, Artists and Genres | G |
| [`1216-music-now-playing.jpg`](source/video-frames/1216-music-now-playing.jpg) | [12:16](https://youtu.be/ERFeOgqk324?t=736) | Music: big cover, blurred backdrop, waveform seek bar | G |
| [`1224-network-streams-list.jpg`](source/video-frames/1224-network-streams-list.jpg) | [12:24](https://youtu.be/ERFeOgqk324?t=744) | Network section: Add Network Stream, Podcasts and Radio | H |
| [`1309-app-menu-cleaned.jpg`](source/video-frames/1309-app-menu-cleaned.jpg) | [13:09](https://youtu.be/ERFeOgqk324?t=789) | Cleaned app menu with split Open actions | C |
| [`1310-open-network-stream-dialog.jpg`](source/video-frames/1310-open-network-stream-dialog.jpg) | [13:10](https://youtu.be/ERFeOgqk324?t=790) | Open Network Stream dialog with optional playlist name | H |
| [`1328-new-playlist-dialog.jpg`](source/video-frames/1328-new-playlist-dialog.jpg) | [13:28](https://youtu.be/ERFeOgqk324?t=808) | New Playlist: name, thumbnail, file drop zone | H |
| [`1332-file-context-menu.jpg`](source/video-frames/1332-file-context-menu.jpg) | [13:32](https://youtu.be/ERFeOgqk324?t=812) | File menu: play, mark watched, favorite, add to playlist | D |
| [`1347-sidebar-rail-home-recent-pins.jpg`](source/video-frames/1347-sidebar-rail-home-recent-pins.jpg) | [13:47](https://youtu.be/ERFeOgqk324?t=827) | Sidebar with Home, Recent and pinned items | D |
| [`1352-home-page.jpg`](source/video-frames/1352-home-page.jpg) | [13:52](https://youtu.be/ERFeOgqk324?t=832) | Home: Continue Watching, Listen Again, frequent folders | D |
| [`1358-resume-prompt-old.jpg`](source/video-frames/1358-resume-prompt-old.jpg) | [13:58](https://youtu.be/ERFeOgqk324?t=838) | Before: resume banner far from the controls | C |
| [`1408-resume-prompt-new.jpg`](source/video-frames/1408-resume-prompt-new.jpg) | [14:08](https://youtu.be/ERFeOgqk324?t=848) | Resume card centered above the control bar | C |
| [`1512-bookmarks-tab.jpg`](source/video-frames/1512-bookmarks-tab.jpg) | [15:12](https://youtu.be/ERFeOgqk324?t=912) | Queue panel tabs: Queue, Bookmarks, Chapters | C |
| [`1526-osd-pressed-key.jpg`](source/video-frames/1526-osd-pressed-key.jpg) | [15:26](https://youtu.be/ERFeOgqk324?t=926) | On-screen message shows the action and the pressed key | I |
| [`1600-keyboard-shortcuts-dialog.jpg`](source/video-frames/1600-keyboard-shortcuts-dialog.jpg) | [16:00](https://youtu.be/ERFeOgqk324?t=960) | Keyboard Shortcuts dialog with search and hotkey columns | I |
| [`1716-old-subtitle-fuzziness.jpg`](source/video-frames/1716-old-subtitle-fuzziness.jpg) | [17:16](https://youtu.be/ERFeOgqk324?t=1036) | Before: numeric subtitle matching explained only in a tooltip | I |
| [`1730-file-name-matching-dropdown.jpg`](source/video-frames/1730-file-name-matching-dropdown.jpg) | [17:30](https://youtu.be/ERFeOgqk324?t=1050) | File name matching as a plain-language dropdown | I |
| [`1740-settings-general-page.jpg`](source/video-frames/1740-settings-general-page.jpg) | [17:40](https://youtu.be/ERFeOgqk324?t=1060) | Settings General page with grouped categories and info icons | I |
| [`1743-settings-light-theme.jpg`](source/video-frames/1743-settings-light-theme.jpg) | [17:43](https://youtu.be/ERFeOgqk324?t=1063) | Player and Settings in the Light theme | B |
| [`1746-accent-color-swatches.jpg`](source/video-frames/1746-accent-color-swatches.jpg) | [17:46](https://youtu.be/ERFeOgqk324?t=1066) | Nine accent swatches recolor the UI live | B |
| [`1758-settings-controls-page.jpg`](source/video-frames/1758-settings-controls-page.jpg) | [17:58](https://youtu.be/ERFeOgqk324?t=1078) | Controls page with Edit Keyboard Shortcuts | I |
| [`1810-settings-subtitles-page.jpg`](source/video-frames/1810-settings-subtitles-page.jpg) | [18:10](https://youtu.be/ERFeOgqk324?t=1090) | Subtitle Defaults page with file name matching | I |
| [`1827-settings-extensions-page.jpg`](source/video-frames/1827-settings-extensions-page.jpg) | [18:27](https://youtu.be/ERFeOgqk324?t=1107) | Extensions and Scripts page | I |
| [`1852-settings-advanced-expanded.jpg`](source/video-frames/1852-settings-advanced-expanded.jpg) | [18:52](https://youtu.be/ERFeOgqk324?t=1132) | Advanced Options expanded inline below basic settings | I |
| [`1922-customize-player-canvas.jpg`](source/video-frames/1922-customize-player-canvas.jpg) | [19:22](https://youtu.be/ERFeOgqk324?t=1162) | Customize Player canvas with dashed slots on both bars | E |
| [`1928-alternate-layout.jpg`](source/video-frames/1928-alternate-layout.jpg) | [19:28](https://youtu.be/ERFeOgqk324?t=1168) | Alternate two-row layout built in Customize Player | E |
| [`1934-menu-profile-submenu.jpg`](source/video-frames/1934-menu-profile-submenu.jpg) | [19:34](https://youtu.be/ERFeOgqk324?t=1174) | Profile submenu in the app menu | E |
| [`1948-onboarding-welcome.jpg`](source/video-frames/1948-onboarding-welcome.jpg) | [19:48](https://youtu.be/ERFeOgqk324?t=1188) | Onboarding 1: welcome and media folder | J |
| [`1950-onboarding-theme.jpg`](source/video-frames/1950-onboarding-theme.jpg) | [19:50](https://youtu.be/ERFeOgqk324?t=1190) | Onboarding 2: theme and accent color | J |
| [`1952-onboarding-shortcuts.jpg`](source/video-frames/1952-onboarding-shortcuts.jpg) | [19:52](https://youtu.be/ERFeOgqk324?t=1192) | Onboarding 3: basic keyboard shortcuts | J |
