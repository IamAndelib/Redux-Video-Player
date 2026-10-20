# VLC Redux roadmap

**North Star:** ship Juxtopposed's VLC redesign (Figma `CAuJVJyM5yY7PnyQQK9X24`, plus the video's rationale in
`redux/design/transcript.md` and `PLAN.md` §2a) as a new player built entirely on VLC. It is a fork of VLC master
whose Qt/QML interface is redesigned.

Related files:
- Progress for each milestone: [`STATUS.md`](STATUS.md)
- Open unknowns: [`GAPS.md`](GAPS.md)
- Why we chose what we chose: [`DECISIONS.md`](DECISIONS.md)
- Per-milestone working files: `M<ID>-<slug>.md`, created from [`TEMPLATE.md`](TEMPLATE.md) when the milestone starts


## Working philosophy (applies to every milestone)
1. **Slow and steady.** One milestone at a time. Each one is reviewed, merged and logged before the next starts.
2. **KISS.** Do the simplest thing that meets the acceptance criteria, with no speculative abstractions.
3. **Don't reinvent the wheel.** Reuse upstream VLC components first, then established libraries, and only then write new code.
4. **Research first.** Every milestone begins with a time-boxed research step:
   - check upstream code and merge requests (MRs)
   - check prior art
   - write the findings into the milestone file
5. **Clean, maintainable code; no spaghetti:**
   - Follow VLC's own conventions (`modules/gui/qt/HACKING`) and Qt's QML best practices.
   - Small, focused files and components. Prefer new files to deep edits of upstream files, because that also keeps merge conflicts low.
   - No magic values: colors, sizes, radii and durations come from `VLCStyle` / `ColorContext` tokens.
   - **Touch-to-tokenize:** hard-coded values are replaced only in files a milestone already edits. No global sweeps.
   - No duplication; shared logic lives in one place, such as one menu builder and one settings row delegate.
   - Every non-obvious choice gets a comment or a `DECISIONS.md` entry.
6. **Developer-friendly repo:**
   - Fork-specific material lives under `redux/` and is documented.
   - Root `CLAUDE.md` holds the session ritual and commands.
   - Clear commit and PR titles (`M2.1: …`).
   - `Makefile.am` is kept in step with `meson.build`.
7. **Verify, don't assume.** Every milestone is checked with the same tools before it counts as done:
   - build
   - tests
   - screenshot diff
   - your manual check
   - code review (`/code-review`, `qt-qml-review` / `qt-cpp-review`, `/simplify`)

## Process decisions (details in DECISIONS.md)
- **Tracking:** repo docs are the source of truth (`redux/milestones/`), mirrored as GitHub Issues grouped under GitHub Milestones R0–R3.
- **Branching:** a long-lived `main` (default branch). One branch and PR per milestone (`m/M2.1-bottom-bar`), squash-merged after your review. History is never rewritten.
- **Upstream:** small, generally useful pieces are sent to VideoLAN as we go.
  - They are prepared on `up/<slug>` branches based on `upstream/master` in VLC commit style.
  - You submit them as MRs on code.videolan.org, and they're cherry-picked into `main`.
- **Order:** player first. The redesigned player becomes usable, then the library, then settings and onboarding.

## Milestone ritual
1. **Kickoff.** Read `CLAUDE.md`, `STATUS.md` and the milestone file. Run `git fetch upstream`. Create `redux/milestones/M<ID>-<slug>.md` from the template.
2. **Research, time-boxed (S: 15 min, M: 30–45 min, L: one spike session):**
   - Check upstream changes: `git log <pin>..upstream/master -- <paths>`.
   - Search upstream MRs.
   - Grep for reusable code.
   - Look at prior art if new C++ is needed.
   - Unknowns go to `GAPS.md`. If something blocks, stop and ask you.
3. **Plan.** Scope, out-of-scope and acceptance are confirmed in the milestone file, and you approve them.
4. **Implement** on the milestone branch in small commits, looping on the build.
5. **Verify** with the milestone's commands. Paste the outputs and diff scores into the file, then run the review skills.
6. **Your review.** Run the manual checklist and comment on the PR.
7. **Merge.** Squash-merge, update the `STATUS.md` row, close the issue.
8. **Log.** Write a dated status-log entry. Ending mid-milestone always records "stopped at / next step".

**Definition of Done, for every milestone:**
- The build and tests pass.
- Touched screens are keyboard-reachable.
- Night and Day themes start with no QML errors in the log.
- No new hard-coded hex colors or `radius:` numbers.
- `STATUS.md` and the log are updated.
- The PR includes before/after crops.

**Verification shorthands:**
- **B** = `redux/dev.sh run redux/tools/build.sh qt`
- **T** = `redux/dev.sh run meson test -C build/meson --suite qt`
- **S** = `shoot.sh <scene>` (`THEME=day` for light)
- **C** = `compare.sh`, producing `build/shots/report.html`
- **PX** = exact pixel color check
- **U** = your manual check via `build.sh run`
- **LOG** = `-vv` log grep

The RMSE (difference score) is a regression signal per screen region, calibrated in M0.3. Your eyes on the side-by-side are the final judge.

## Roadmap: 43 milestones, 11 tracks, 4 release gates
Sizes: S ≈ 1 focused session, M ≈ 2–3, L ≈ 4 or more (each L starts with a spike session).

### Track A: Foundations
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M0.1** | Tracking scaffolding: `redux/milestones/{ROADMAP,STATUS,TEMPLATE,GAPS,DECISIONS}.md`, root `CLAUDE.md` (ritual, commands, rules), `main` as default branch, labels (`track:*`, `size:*`, `gap`, `upstreamable`, `needs-user`), GitHub milestones R0–R3, one issue per milestone | S | `gh` CLI (the GitHub MCP is down) | A fresh session can name the next milestone from `CLAUDE.md` + `STATUS.md` alone; `gh issue list` shows every ID |
| **M0.2** | Complete the design source: run `figma-export.py` (≤5 calls), add offline `tokens-from-figma.py` (light palette, text styles, radii, spacing), commit `frames.tsv` and `icons.tsv` | S | Needs gap G1 (your token, or `.fig`/manual exports) | Light and dark token sets have the same keys; ≥95 frame PNGs; typography tokens present |
| **M0.3** | Harness v2: per-region crops in `shots.tsv`/`compare.sh` (bottom bar, top bar, sidebar, grid); `player-controls` scene; isolated run profile for `build.sh run` (never touches system VLC config); test clip with chapters and 2 audio/2 subtitle tracks; baseline score per region | S–M | ffmpeg, existing harness | Report shows region rows; baselines in `STATUS.md`; `vlcrc` exists only in the redux profile |
| **M0.4** | Video design brief: cleaned `transcript.md`; `brief.md` with every decision's reason, milestone, video time, frame and Figma node; 40–60 reference frames from `frame-picks.tsv` (frames stay out of git); gaps updated | S–M | `video-sheets.sh`, `video-frames.sh`, `check-brief.py`; 4 parallel review agents | `check-brief.py` passes; every sheet reviewed; GAPS updated |

### Track B: Design system
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M1.1** | Night palette from the Figma tokens (accent `#D37918`); fix the upstream alpha bug at `systempalette.cpp:635` (upstreamable) | S | `style/systempalette.{cpp,hpp}` `makeDarkPalette()`; ColorContext API unchanged | PX matches tokens; sidebar/bottom-bar scores below baseline; Day theme unchanged |
| **M1.2** | Typography and shape tokens: bundle Inter (OFL font), one app-wide `setFont`, font/radius/margin tokens in `VLCStyle.qml` | M | Icon-font qrc loading pattern; `mainui.cpp` | Inter renders even without the system font; no region regresses |
| **M1.3** | Live accent presets (9 colors): runtime NOTIFY property, persisted `qt-accent-color`, pressed/dim colors derived from the accent; temporary View→Accent menu | M | Upstream !7074 option; `systempalette.cpp` L305-336; `menus.cpp` | Recolors without restart; survives restart |
| **M1.4** | Monochrome icon set under the existing `VLCIcons` keys (no QML changes), plus new keys (queue, sidebar, PiP, hide-UI, ±10/15) | M | `pixmaps/VLCIcons.json` + `makeIconFont.py`; add `python3-fontforge` to the image | Glyph contact sheet matches Figma; no missing-glyph boxes |
| **M1.5** | Base widgets: Button, IconToolButton, Switch, Slider, new SegmentedControl, ComboBox, SearchBox, TextField, ToolTip, dark QMenu styling | M | VLC's own style layer `widgets/qml/*Ext.qml` over `QtQuick.Templates` | All states (hover, pressed, focus, disabled) match Figma components; visible focus ring |

### Track C: Player screen (first priority)
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M2.1** | One-row bottom bar (prev, **play**, next, time, thick seek bar, duration, right group) as a new "Redux" default profile; pinned controls by default | M | `controlbar_profile_model.cpp`, `ControlBar`/`SliderBar`/`PlayerControlLayout.qml`; existing `qt-pin-controls` | Figma order; video never covered; bottom-bar score ≤ 0.5× baseline |
| **M2.2** | Cone-shaped volume control | S | `VolumeWidget.qml` (Shape) | Drag, wheel, keys and mute work; >100% visually distinct |
| **M2.3** | Top bar: cone, "…", sidebar toggle, folder/show name, centered title, window buttons | M | `TopBar.qml`, `CSD*.qml`, `MenuTopbar.qml` | Works with custom title bar on and off; folder name navigates |
| **M2.4** | Separate Subtitle and Audio buttons (audio includes output device); Playlist button becomes Queue | M | Reserved control-ID slots; `TracksListPage`, `AudioDeviceModel`; old `LANG_BUTTON` profiles still load | Track/device switching verified on the multi-track clip |
| **M2.5** | Fullscreen edge-hover reveal, Hide UI, resume prompt near the controls | M | `PlayerToolbarVisibilityFSM` (+ unit test like `tst_FSM.qml`), `MinimalView`, `ResumeDialog` | New QML test passes; chrome hides instantly away from the edges |
| **M2.6** | One shared "…" menu and right-click menu builder; Hide UI and split Open entries | M | `menus/menus.cpp` | Same entries from both menus; per-entry checklist passes |

**Gate R0 "Looks like Redux"** (internal screenshot review).

### Track D: Library core
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M3.1** | Icon rail: Home, Videos, Music, Network, Playlists, Recent, Add | M | `navigationmodel.cpp` (+ update `tests/test_navigation_model.cpp`), `SideNavigationPane.qml` | All entries navigate; tests pass; sidebar score ≤ 0.5× baseline |
| **M3.2** | Library header: back/forward, breadcrumb address bar, count, view toggle, sort (incl. Unwatched/Watched first via existing `playcount` sort), search | M | `ViewHeader`, `SortControl`, `NetworkAddressbar`, `MLVideoModel` | Sorts and search work; breadcrumbs navigate |
| **M3.3** | Grid and list items with watched-progress underline | M | `VideoGridItem`, `GridItem`, `VideoProgressBar`, `EnhancedImageExt` | Partially watched item shows underline; grid score ≤ 0.5× baseline |
| **M3.4** | File, folder and playlist context menus (incl. mark watched/unwatched, favorite) | M | `MLContextMenu.qml`, medialibrary favorites | Every entry works |
| **M3.5** | Floating miniplayer card in the corner, draggable | M | `PIPPlayer.qml` / `MiniPlayer.qml` | Library shows the card while video keeps playing; expand returns to the player |
| **M3.6** | Home (Continue, Latest, Playlists, Streams) and Recent | M | `HomePage`/`HomeDisplay`, `MLRecentVideoModel` | A partly played episode resumes from Continue |

**Gate R1 "Daily driver":** prerelease `r1`. You use it for a week; the old Preferences dialog stays reachable on purpose until M8.

### Track E: Customize Player
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M4.1** | Missing controls (±10/15s, PiP, Go Home, Settings, Replay, Bookmarks, Chapters, Playlists, Zoom, name labels, Favorite); fix the swapped FRAME_PREV/NEXT files (upstreamable) | M | `control_list_model.hpp` (append only into the 22 free slots), `PlayerControlbarControls.qml`, `jumpTime()` | Each item placeable, working and persisted; old profiles unaffected |
| **M4.2** | Customize modal over the player plus profile management | M | `dialogs/toolbar/qml/*`, `ControlbarProfileModel`, `Dialogs.qml` host | Live preview; Cancel reverts; Save persists |

### Track F: Right sidebar and panels
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M5.1** | Right sidebar with Subtitles, Audio, Video and Playback tabs, hosting the existing tracks pages | M | `TracksPage*.qml`, the queue pane's docking mechanism | Opens and closes; keyboard navigable |
| **M5.2** | Audio effect cards (EQ, compressor, spatializer, stereo widener) with presets | M (spike) | New `AudioEffectsModel` lifted from `extended_panels.cpp` tables (that file stays untouched); `equalizer_presets.h` | Audible change; filter appears in the log |
| **M5.3** | Video tab: aspect, zoom, crop, deinterlace, flip/rotate, adjust | M | `PlayerController`'s existing VLCVarChoiceModels; `adjust`/`transform` filters | Visible changes; reset works |
| **M5.4** | Subtitle styling (relative/precise size, font, outline, position) and default language | M | `vlc_player_SetSubtitleTextScale`, `sub-language`, `TrackDelayButton` | Live updates; setting saved to `vlcrc` |
| **M5.5** | Playback tab: speed, reverse, sleep timer, metadata; bookmarks and chapters list; Ctrl+B | M | `MLBookmarkModel` (make add/remove invokable; upstreamable), `Player.reverse()` | Bookmarks persist and show as ticks; timer fires |
| **M5.6** | Add Subtitles dialog (file/folder/playlist, auto and manual matching), local files only | M | VLC's own autodetect heuristics (`src/input/subtitles.c`); matcher written test-first | Mismatched test `.srt` files auto-match; manual matches survive restart |

### Track G: Media visuals
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M6.1** | Seek-bar thumbnails | L (spike) | Core `vlc_preparser_req_NewThumbnail` (fast seek), IINA's pre-generate approach, closed upstream MR !7822 as reference, `EnhancedImageExt` | Preview frames on hover; idle CPU afterwards; no crash on media change |
| **M6.2** | Music now-playing screen (blurred artwork, centered cover, title–artist) | M | Existing `DualKawaseBlur` in `Player.qml`'s audio branch | Music score ≤ 0.5× baseline |
| **M6.3** | Waveform provider (background thread, cached) | L (spike) | Choose between a second VLC player (`amem`) and libav decode; BBC `.dat` cache format; no GPL-3 code | Unit test passes; a 4-min track takes under 2 s; cache hits are instant |
| **M6.4** | Waveform seek bar (played part in the accent color) | M | `SliderBar.qml` | Loud and quiet sections visible; seeking unchanged |

### Track H: Library extended
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M7.1** | Network stream list, M3U import, split Open dialogs, New playlist dialog | M | `MLUrlModel`, `UrlListDisplay`, M3U demux, `dialogs/playlists` | Streams persist; M3U imports N entries |
| **M7.2** | Compact library panel beside the video, opened from the folder name in the top bar | M | Queue-pane docking | Matches frame 187:328 (after G19 is resolved) |

**Gate R2 "Feature preview":** `r2` goes to a wider group of testers.

### Track I: Settings
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M8.1** | Settings framework and General page: declarative JSON page specs, generic rows, info icons, search, basic-then-advanced; legacy advanced tree still reachable | L (spike) | `dialogs/preferences/expert_model.*`, `vlc_config_Get*Choices`, `Dialogs.qml` host | Theme and accent change live and persist; search crosses pages; unknown config keys fail a check |
| **M8.2** | Pages: Interface, Playback, Video, Audio, Subtitles (human-worded dropdowns, no duplicates) | M | `settings-map.tsv` | Sampled settings write the right `vlcrc` keys |
| **M8.3** | Pages: Privacy, Controls, Library, Network, Performance, Recording, Extensions | M | `dialogs/extensions`, `dialogs/plugins` | Same as M8.2 |
| **M8.4** | Keyboard shortcuts dialog (search, rebind, conflicts, reset) | M | Existing hotkeys panel logic, `vlc_actions` | Rebinding survives restart; conflicts flagged |

### Track J: Onboarding and polish
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M9.1** | 11-step QML onboarding replacing the first-run wizard (also update `shoot.sh`) | M–L | Settings row delegates, `MLFoldersModel` | Clean profile indexes the library through the new flow |
| **M9.2** | Light theme, HiDPI and accessibility polish | M–L | `makeLightPalette()`, complete tokens | Day scenes readable; keyboard-only walkthrough passes |

### Track K: Release
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M10.1** | Identity: name, app ID, icon, About credits, licences, designer contact | S | Your decisions (G15) | Decisions recorded; credits shown |
| **M10.2** | CI: GitHub Actions builds the image and VLC, runs tests and the screenshot diff, uploads the report | M | Existing tools | PRs show green checks plus a report artifact |
| **M10.3** | Flatpak and AppImage, tagged release, CONTRIBUTING | L | Flathub `org.videolan.VLC` manifest, medialibrary 0.13.2 module | Installs and plays on your machine and on a second distro |

**Gate R3 "1.0 public".**

**Backlog** (each item becomes a milestone once its gap is resolved):
- sidebar pins
- subtitle timeline
- OpenSubtitles
- per-show presets
- live filter previews
- HDR options
- key shown in on-screen messages
- two-tone menu icons
- visualizer picker
- fullscreen library with the queue
- Windows/macOS

**Execution order:**
1. M0.1 → M1.1 → M0.2 → M0.3
2. M1.2 → M1.5
3. M2.1 → M2.3 → **R0**
4. M2.4 → M3.6 → **R1**
5. M4 → M5 → M6 → M7 → **R2**
6. M8 → M9 → M10 → **R3**

## Risks and mitigations
| Risk | Mitigation |
|---|---|
| Upstream changes cause merge conflicts | Monthly syncs on `sync/<date>` branches; new files over deep edits; weekly `git log` watch |
| VLC 4 master bugs unrelated to our work | Pin green commits; reproduce on stock VLC at the pin first |
| Qt version skew (6.11 here, 6.8 in contribs and Flatpak) | Use no QML API newer than 6.8; CI builds against the Flatpak runtime |
| Misleading diff scores | Region crops, video area masked; your eyes are final |
| Scope creep (~100 frames) | Strict out-of-scope per milestone; backlog; gates |
| Context loss between sessions | `CLAUDE.md` + `STATUS.md` + "next step" log entries |
| Clash with an installed system VLC config | Isolated profile (M0.3); Flatpak at release |
| Wayland limits (always-on-top, title bars differ) | In-window floating card; test title bar both ways |
| Thumbnails or waveform cause UI stalls | Worker threads, cancellation, memory caps, QML profiler |
| Licensing (GPL-3 code, fonts, design, trademark) | No GPL-3 copying; Inter under OFL; M10.1 checks; credit the designer |

## Upstream sync
- **Cadence:** monthly or at each gate, only between milestones.
- **Steps:**
  1. Merge a green upstream commit.
  2. Run the full build, tests, all scenes and the diff report.
  3. Update `redux/UPSTREAM_COMMIT`.
  4. Log conflicts in `DECISIONS.md`.
