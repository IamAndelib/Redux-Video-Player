# Redux Video Player roadmap

**North Star:** ship **Redux Video Player**, a lean, Linux-only Flatpak video player built on VLC: offline video
playback with maximum codec and format support, wearing Juxtopposed's redesign (Figma `CAuJVJyM5yY7PnyQQK9X24`;
the reasoning is in [`redux/design/brief.md`](../design/brief.md)). It is a fork of VLC master whose Qt/QML interface
is redesigned. **What ships and what doesn't is fixed in [`redux/SCOPE.md`](../SCOPE.md) (D14);** milestones only
build what it keeps.

Related files:
- Progress for each milestone: [`STATUS.md`](STATUS.md)
- Product scope (keep / cut / future): [`../SCOPE.md`](../SCOPE.md)
- Open unknowns: [`GAPS.md`](GAPS.md)
- Why we chose what we chose: [`DECISIONS.md`](DECISIONS.md)
- Per-milestone working files: `M<ID>-<slug>.md`, created from [`TEMPLATE.md`](TEMPLATE.md) when the milestone starts
- How milestones are tested: [`../QA.md`](../QA.md) (D23)
- How collaborators pick up work: [`.github/CONTRIBUTING.md`](../../.github/CONTRIBUTING.md) (D25)


## Working philosophy (applies to every milestone)
1. **Slow and steady.** One milestone at a time per person. Each one is reviewed, merged and logged before that person starts the next.
2. **KISS.** Do the simplest thing that meets the acceptance criteria, with no speculative abstractions.
3. **Don't reinvent the wheel; steal like an artist.** Before building or experimenting with anything, look for the best existing open-source implementation (upstream VLC and its MRs, other players, KDE/Qt components, established libraries and test suites) and adopt it with credit in `redux/CREDITS.md`. Write new code only when nothing fits.
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
   - the QA suite and agent loop (`redux/tools/qa.sh`, from M0.8, D23)
   - your manual check (a short spot check once QA is in place)
   - code review (`/code-review`, `qt-qml-review` / `qt-cpp-review`, `/simplify`)

## Process decisions (details in DECISIONS.md)
- **Tracking:** repo docs are the source of truth (`redux/milestones/`), mirrored as GitHub Issues grouped under GitHub Milestones R0–R3.
- **Branching:** a long-lived `main` (default branch). One branch and PR per milestone (`m/M2.1-bottom-bar`), squash-merged after your review. History is never rewritten.
- **Upstream:** small, generally useful pieces are sent to VideoLAN as we go.
  - They are prepared on `up/<slug>` branches based on `upstream/master` in VLC commit style.
  - You submit them as MRs on code.videolan.org, and they're cherry-picked into `main`.
- **Collaborators (D25):** GitHub issues are the work queue. Assigning yourself to a milestone issue claims it; one
  milestone per person; the maintainer reviews and merges. See `CONTRIBUTING.md`.
- **QA (D23):** milestones are verified by the QA suite and an agent loop (`redux/QA.md`); you evaluate the complete
  prototype and do short spot checks.
- **Order:** scope foundations first (M0.5–M0.7: scope, lean build, Flatpak), then the QA track (Q0.1–Q0.7), then
  the UI trim (M0.8), then player first: the redesigned player becomes usable, then the library, then settings and onboarding.

## Milestone ritual
1. **Kickoff.** Read `CLAUDE.md`, `STATUS.md` and the milestone file. Run `git fetch upstream`. Create `redux/milestones/M<ID>-<slug>.md` from the template.
2. **Research, time-boxed (S: 15 min, M: 30–45 min, L: one spike session):**
   - Check upstream changes: `git log <pin>..upstream/master -- <paths>`.
   - Search upstream MRs.
   - Grep for reusable code.
   - Look at prior art if new C++ is needed.
   - Unknowns go to `GAPS.md`. If something blocks, stop and ask you.
3. **Plan.** Scope, out-of-scope and acceptance go into the milestone file. Ask you only when a gap needs your
   decision (D18).
4. **Implement** on the milestone branch in small commits, looping on the build.
5. **Verify** with the milestone's commands. Paste the outputs and diff scores into the file, then run the review skills.
   From M0.8 on, run `redux/tools/qa.sh` and the agent loop until green (D23) and attach the QA report to the PR.
6. **QC.** The build, VLC's test suite, the codec matrix (and the Flatpak when packaging or the core changed), the QA
   suite as Track Q builds it, and an independent review agent on the diff; fix and re-run until green. The PR and
   the milestone file record the results.
7. **QC and merge (D26).** Claude runs the QC (CLAUDE.md § Milestone ritual), fixes and re-runs until green, adds the
   hand checks to `redux/EVALUATION.md` for your final evaluation, and squash-merges; you evaluate the complete
   project at the end.
8. **Merge.** After the QC is green: squash-merge, update the `STATUS.md` row, close the issue, write a dated
   status-log entry. Ending mid-milestone always records "stopped at / next step".

**Definition of Done, for every milestone:**
- The build and tests pass.
- Touched screens are keyboard-reachable.
- Night and Day themes start with no QML errors in the log.
- No new hard-coded hex colors or `radius:` numbers.
- Touched screens keep the spacing-token gaps: nothing sits flush against its neighbour (principle 9).
- `STATUS.md` and the log are updated.
- The PR includes before/after crops.
- From M0.8: the QA suite is green and its report is attached to the PR (D23).

**Verification shorthands:**
- **B** = `redux/dev.sh run redux/tools/build.sh qt`
- **T** = `redux/dev.sh run meson test -C build/meson --suite qt`
- **S** = `shoot.sh <scene>` (`THEME=day` for light)
- **C** = `compare.sh`, producing `build/shots/report.html`
- **PX** = exact pixel color check
- **U** = your check in the app (app-menu launcher or `redux/dev.sh app`)
- **LOG** = `-vv` log grep

The RMSE (difference score) is a regression signal per screen region, calibrated in M0.3. Your eyes on the side-by-side are the final judge.

## Roadmap: 59 milestones (53 active, 2 merged into Track Q, 3 cut, 1 future), 12 tracks, 4 release gates
Sizes: S ≈ 1 focused session, M ≈ 2–3, L ≈ 4 or more (each L starts with a spike session). Ranges such as S–M round up for the GitHub `size:` label.

### Track A: Foundations
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M0.1** | Tracking scaffolding: `redux/milestones/{ROADMAP,STATUS,TEMPLATE,GAPS,DECISIONS}.md`, root `CLAUDE.md` (ritual, commands, rules), `main` as default branch, labels (`track:*`, `size:*`, `gap`, `upstreamable`, `needs-user`; later `future` and `cut`, D14), GitHub milestones R0–R3, one issue per milestone | S | `gh` CLI (the GitHub MCP is down) | A fresh session can name the next milestone from `CLAUDE.md` + `STATUS.md` alone; `gh issue list` shows every ID |
| **M0.2** | Complete the design source: the Figma export is done (G1 resolved: `file.json`, 103 frames, 206 icons); add offline `tokens-from-figma.py` (light palette, text styles, radii, spacing), commit `frames.tsv` and `icons.tsv` | S | `redux/design/source/file.json` (G1 resolved) | Light and dark token sets have the same keys; ≥95 frame PNGs; typography tokens present |
| **M0.3** | **Merged into Q0.4 (D23).** Harness v2: per-region crops in `redux/qa/visual/regions/`/`compare.py` (bottom bar, top bar, sidebar, grid); `player-controls` scene; isolated run profile for `build.sh run` (never touches system VLC config); test clip with chapters and 2 audio/2 subtitle tracks; baseline score per region (the `music` scene and music fixtures were already dropped, D14) | S–M | ffmpeg, existing harness | Report shows region rows; baselines in `STATUS.md`; `vlcrc` exists only in the redux profile |
| **M0.4** | Video design brief: cleaned `transcript.md`; `brief.md` with every decision's reason, milestone, video time, frame and Figma node; 40–60 reference frames from `frame-picks.tsv` (frames stay out of git); gaps updated | S–M | `video-sheets.sh`, `video-frames.sh`, `check-brief.py`; 4 parallel review agents | `check-brief.py` passes; every sheet reviewed; GAPS updated |
| **M0.5** | Scope foundation: `redux/SCOPE.md` (keep / cut / future), D13–D16, roadmap, brief and GitHub issues follow it | S | Feature inventory of `modules/gui/qt`, module inventory, community research | Every cut item maps to an M0.6 module switch or an M0.8 UI removal; issues match `STATUS.md` |
| **M0.6** | Lean build and codec/format matrix: `redux/cut-modules.txt` (190 plugins not built, D20) through the `redux_cut_modules` meson option; `make-matrix.sh` synthesizes containers × codecs × subtitle formats and archives; `fetch-samples.sh` adds real FFmpeg FATE samples for what can't be synthesized (VC-1, PGS, VobSub, DVB/ARIB subtitles, TrueHD Atmos, DTS-HD MA, Dolby Vision, HDR10+, MXF, RealMedia, WTV); `play-matrix.sh` plays them all headless | M | VLC's module `enabled` flag, ffmpeg, FFmpeg FATE suite, `-I dummy --play-and-exit`, `-vv` log | Every matrix file opens and finds a decoder per stream; no cut plugin is built; the app still plays your own files |
| **M0.7** | Flatpak skeleton: `redux/packaging/` manifest on KDE 6.11 (Qt 6.11.2) bundling FFmpeg n9.0.1 (decoders only), libplacebo v7.360.1, libass 0.17.5, libdvbpsi, aribb24, libebml/libmatroska (+ utfcpp), medialibrary 0.13.2 and a build-only meson 1.12.1; `build-vlc.sh` applies `cut-modules.txt`; `--socket=wayland` + `fallback-x11`, `pulseaudio`, `--device=dri`, `host:ro`; `redux/tools/flatpak.sh` (build, run, lint, matrix) | M | Flathub `org.videolan.VLC` (mv/test-alpha), VLC MR !10454, `io.mpv.Mpv`, `org.kde.haruna`; D22 | `flatpak.sh build` installs; matrix 79/79 in the sandbox; VA-API and libplacebo HDR in use; lint findings explained |
| **M0.8** | Feature trim in the UI: remove the entry points of every cut feature (navigation Music/Browse/Discover; menus for disc, network, capture, convert, stream, renderer, VLM, EPG, visualizations, wallpaper, 3D, extensions, skins; toolbar controls record, renderer, teletext, DVD, program, reverse) at one model or menu place each; the full list is in `redux/design/screen-map.md` § Feature trim; Media information stays reachable | M | `navigationmodel.cpp`, `menus/menus.cpp`, `control_list_model.hpp`, `PlayerControlbarControls.qml`, `dialogs_provider.cpp` | No cut feature is reachable from any menu, toolbar or shortcut; Qt tests pass |

### Track Q: Quality assurance (D23, [`redux/QA.md`](../QA.md))
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **Q0.1** | QA foundations: `redux/qa/cases/*.yaml` case format (ID, layer, steps, expected, source: brief entry / scope item / acceptance, Figma node, frame, milestone); coverage report; L1 hygiene (build, QML warning/error scan, crash detection including quit, cut-plugin check); grep token lint (hex colours, `radius:` numbers outside `style/`); `redux/tools/qa.sh` runs the layers that exist and writes `build/qa/report.md`; fix G24 and G25 | M | VLC tests, `play-matrix.sh`, `check-brief.py` | `qa.sh` runs L1–L3 green with a report; coverage lists every brief entry |
| **Q0.2** | Headless desktop: the image gains `kwin-wayland`, `at-spi2-core`, `dbus`, `kde-spectacle`; `redux/tools/kwin-session.sh` starts `dbus-run-session kwin_wayland --virtual --no-lockscreen --width=1920 --height=1080` (`LIBGL_ALWAYS_SOFTWARE=1`); screenshots through KWin ScreenShot2; fixed fonts, theme and window size; Xvfb fallback kept | M | KWin's virtual backend, KDE's own CI setup | The app opens, plays and quits cleanly in the session; a screenshot shows the video under llvmpipe |
| **Q0.3** | End-to-end driver: `selenium-webdriver-at-spi` built from a pinned commit (plus `python3-pyatspi`, Appium-Python-Client, selenium); meson `test()` entries like KDE's plasma-pa; `Accessible.name` on the core controls; first flows: open file, play, end of video stays, restart from 0, subtitles on/off, queue advance; non-blocking until stable | M | KDE `selenium-webdriver-at-spi`, plasma-pa tests | The flows pass three runs in a row |
| **Q0.4** | Visual fidelity v2 (absorbs M0.3): per-region crops with exclude masks (clock, video) and thresholds in `redux/qa/visual/regions/`/`compare.py`; isolated run profile; test clip with chapters and 2 audio/2 subtitle tracks; region baselines; KWin shots for chrome and shadow scenes; WCAG contrast on every `ColorContext` set × state × Day/Night | M | Existing harness, openQA's needle idea | Report shows region rows with baselines in `STATUS.md`; contrast report lists every pair |
| **Q0.5** | Component tests: `qml_test.cpp` registers `VLC.Style` and a stub `MainCtx`; Day/Night theme-matrix TestCases with grabs compared against baselines; ready for M1.5's widgets | M | Qt Quick Test, VLC's `test/modules/gui/qt` | A sample widget passes in both themes and all states |
| **Q0.6** | Agent QA loop: agent roles and rubrics (UI/visual vs Figma and brief, UX/accessibility, playback/formats, regressions); findings format (severity, evidence, suspected file); generate → run → triage → fix → re-run with a round cap; unresolved items to `GAPS.md`; per-PR QA report | M | Review agents, `qa.sh` | A dry run on a seeded bug finds, fixes and re-tests it |
| **Q0.7** | CI (pulls M10.2 forward): GitHub Actions container job (build, `meson test`, `qa.sh` L1–L7, artifacts) and Flatpak job (`flatpak-github-actions` on `ghcr.io/flathub-infra/flatpak-github-actions:kde-6.11`, then the matrix via `VLC_CMD`) | M | `flatpak-github-actions`, M0.6 matrix, M0.7 manifest | PRs show green checks plus the QA report artifact |
| **Q0.8** | Hardware playback check: on a machine with a GPU, the headless KDE session renders with the real GPU; one clip per codec plays through VA-API where `vainfo` says the GPU decodes it (GPU frames handed to OpenGL), and falls back cleanly to software elsewhere (e.g. AV1 on RDNA1); no dropped frames or errors; CPU use with and without the GPU; skipped without a render node (GitHub runners, G27) | S–M | `kwin-session.sh`, `vainfo`, the M0.7 hand check, `play-matrix.sh` | On the maintainer's GPU every supported codec decodes on the GPU and the rest fall back; a forced software run is reported as a failure |

### Track B: Design system
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M1.1** | Night palette from the Figma tokens (accent `#D37918`); fix the upstream alpha bug at `systempalette.cpp:635` (upstreamable) | S | `style/systempalette.{cpp,hpp}` `makeDarkPalette()`; ColorContext API unchanged | PX matches tokens; sidebar/bottom-bar scores below baseline; Day theme unchanged |
| **M1.2** | Typography and shape tokens: bundle Inter (OFL font), one app-wide `setFont`, font/radius/margin tokens in `VLCStyle.qml`, including one spacing scale used for every gap (principle 9) | M | Icon-font qrc loading pattern; `mainui.cpp` | Inter renders even without the system font; no region regresses |
| **M1.3** | Live accent presets (9 colors): runtime NOTIFY property, persisted `qt-accent-color`, pressed/dim colors derived from the accent; temporary View→Accent menu | M | Upstream !7074 option; `systempalette.cpp` L305-336; `menus.cpp` | Recolors without restart; survives restart |
| **M1.4** | Monochrome icon set under the existing `VLCIcons` keys (no QML changes), plus new keys (queue, sidebar, PiP, hide-UI, ±10/15) | M | `pixmaps/VLCIcons.json` + `makeIconFont.py`; add `python3-fontforge` to the image | Glyph contact sheet matches Figma; no missing-glyph boxes |
| **M1.5** | Base widgets: Button, IconToolButton, Switch, Slider, new SegmentedControl, ComboBox, SearchBox, TextField, ToolTip, dark QMenu styling | M | VLC's own style layer `widgets/qml/*Ext.qml` over `QtQuick.Templates` | All states (hover, pressed, focus, disabled) match Figma components; visible focus ring |; every widget keeps the spacing-token gap from its neighbours (principle 9); icon-only buttons (view toggle, search, sidebar toggle, back) look the same in Night, Day and System: no border or frame in any theme (maintainer feedback 2026-10-21; seen on KDE in Night mode)

### Track C: Player screen (first priority)
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M2.1** | One-row bottom bar (prev, **play**, next, time, thick seek bar, duration, right group) as a new "Redux" default profile; pinned controls by default | M | `controlbar_profile_model.cpp`, `ControlBar`/`SliderBar`/`PlayerControlLayout.qml`; existing `qt-pin-controls` | Figma order; video never covered; bottom-bar score ≤ 0.5× baseline |
| **M2.2** | Cone-shaped volume control | S | `VolumeWidget.qml` (Shape) | Drag, wheel, keys and mute work; >100% visually distinct |
| **M2.3** | Top bar: cone, "…", sidebar toggle, folder/show name, centered title, window buttons; window chrome (D19): VLC's custom chrome as the Redux default, a Fullscreen window button, window radius and 1 px border from tokens, an opaque content background, backdrop blur off by default | M | `TopBar.qml`, `CSD*.qml`, `MenuTopbar.qml`; existing custom chrome: `CSDWindowButtonSet.qml`, `util/csdbuttonmodel.hpp`, `CSDTitlebarTapNDrapHandler.qml`, `CSDMouseStealer.qml`, `RoundedRectangleShadow`, `compositor_wayland.cpp` | Drag, double-click, right-click and edge resize work on KDE Wayland, GNOME Wayland and X11; shadow, radius and border show; fully opaque with blur off; with the system title bar on, nothing breaks; folder name navigates (screenshots under Xvfb have no compositor, so check shadow and corners on KWin)
| **M2.4** | Separate Subtitle and Audio buttons (audio includes output device); Playlist button becomes Queue; restyle the queue panel (header "N items - duration", sort, repeat, shuffle, remove, add) | M | Reserved control-ID slots; `TracksListPage`, `AudioDeviceModel`; old `LANG_BUTTON` profiles still load | Track/device switching verified on the multi-track clip |
| **M2.5** | Fullscreen edge-hover reveal, Hide UI, resume prompt near the controls | M | `PlayerToolbarVisibilityFSM` (+ unit test like `tst_FSM.qml`), `MinimalView`, `ResumeDialog` | New QML test passes; chrome hides instantly away from the edges |
| **M2.6** | One shared "…" menu and right-click menu builder; Hide UI; Open entries limited to file(s), folder(s) and recent (no disc, network, capture, clipboard, convert, stream, plugins) | M | `menus/menus.cpp` | Same entries from both menus; per-entry checklist passes |
| **M2.7** | Playback essentials: auto-next through the folder without building a playlist (upstream #22382), reliable per-file resume, mouse-wheel setting (volume or seek) | M | `vlc_playlist`, `ResumeDialog`, media library playback state, `MainCtx` wheel handling | Last episode in a folder rolls into the next; resume survives restart; wheel setting persists |

**Gate R0 "Looks like Redux"** comes after M2.3 (internal screenshot review); M2.4–M2.7 count toward R1.

### Track D: Library core
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M3.1** | Icon rail: Home, Videos, Playlists, Recent, pinned folders/playlists, Add (no Music or Network, D14); no drag-to-resize handle (collapse/expand button only); the back button shows only when there is a page to go back to | M | `navigationmodel.cpp` (+ update `tests/test_navigation_model.cpp`), `SideNavigationPane.qml` | All entries navigate; tests pass; sidebar score ≤ 0.5× baseline |; no resize handle; back button hidden on top-level pages
| **M3.2** | Library header: back/forward, breadcrumb address bar, count, view toggle, sort (incl. Unwatched/Watched first via existing `playcount` sort), search | M | `ViewHeader`, `SortControl`, `NetworkAddressbar`, `MLVideoModel` | Sorts and search work; breadcrumbs navigate |
| **M3.3** | Grid and list items with watched-progress underline | M | `VideoGridItem`, `GridItem`, `VideoProgressBar`, `EnhancedImageExt` | Partially watched item shows underline; grid score ≤ 0.5× baseline |
| **M3.4** | File, folder and playlist context menus (incl. mark watched/unwatched, favorite; no Stream or Convert) | M | `MLContextMenu.qml`, medialibrary favorites | Every entry works |
| **M3.5** | Floating miniplayer card in the corner, draggable | M | `PIPPlayer.qml` / `MiniPlayer.qml` | Library shows the card while video keeps playing; expand returns to the player |
| **M3.6** | Home (Continue Watching, Recently Added, Frequently Visited Folders, Playlists) and Recent | M | `HomePage`/`HomeDisplay`, `MLRecentVideoModel` | A partly played episode resumes from Continue |

**Gate R1 "Daily driver":** prerelease `r1`. You use it for a week; the old Preferences dialog stays reachable on purpose until M8.

### Track E: Customize Player
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M4.1** | Missing controls (±10/15s, PiP, Go Home, Settings, Replay, Bookmarks, Chapters, Playlists, Zoom, file/folder/playlist name labels, Favorite; no Record or Artist Name); fix the swapped FRAME_PREV/NEXT files (upstreamable) | M | `control_list_model.hpp` (append only into the 22 free slots), `PlayerControlbarControls.qml`, `jumpTime()` | Each item placeable, working and persisted; old profiles unaffected |
| **M4.2** | Customize modal over the player plus profile management | M | `dialogs/toolbar/qml/*`, `ControlbarProfileModel`, `Dialogs.qml` host | Live preview; Cancel reverts; Save persists |

### Track F: Right sidebar and panels
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M5.1** | Right sidebar with Playback, Video, Audio and Subtitles tabs (Subtitles default), hosting the existing tracks pages | M | `TracksPage*.qml`, the queue pane's docking mechanism | Opens and closes; keyboard navigable |
| **M5.2** | Audio effect cards (EQ, compressor, spatializer, stereo widener) with presets | M (spike) | New `AudioEffectsModel` lifted from `extended_panels.cpp` tables (that file stays untouched); `equalizer_presets.h` | Audible change; filter appears in the log |
| **M5.3** | Video tab: aspect, zoom, crop, deinterlace, flip/rotate, adjust | M | `PlayerController`'s existing VLCVarChoiceModels; `adjust`/`transform` filters | Visible changes; reset works |
| **M5.4** | Subtitle styling (relative/precise size, font, outline, position) and default language | M | `vlc_player_SetSubtitleTextScale`, `sub-language`, `TrackDelayButton` | Live updates; setting saved to `vlcrc` |
| **M5.5** | Playback tab: speed, A-B loop, frame stepping (forward and back), metadata; bookmarks and chapters as queue-panel tabs (D12); Ctrl+B. No reverse or sleep timer (D14) | M | `MLBookmarkModel` (make add/remove invokable; upstreamable), existing A-B loop and frame-next player calls | Bookmarks persist and show as ticks; A-B loop and frame steps work |
| **M5.6** | Add Subtitles dialog (file/folder/playlist, auto and manual matching), local files only | M | VLC's own autodetect heuristics (`src/input/subtitles.c`); matcher written test-first | Mismatched test `.srt` files auto-match; manual matches survive restart |
| **M5.7** | Online subtitle search: OpenSubtitles REST API via Qt networking, inside the Add Subtitles dialog and the tracks popup; off until the user consents (Privacy page) | M | `QNetworkAccessManager`; no VLSub/Lua; G9 (API key, terms) | Search, download and auto-load work on a test title; no network traffic before consent |
| **M5.8** | Subtitle timeline on the seek bar (zoomed window, cue blocks, nudge buttons) | L (spike) | G7: where cue times come from (parse external files ourselves vs a core hook) | Cue blocks match the subtitle file; nudging changes the delay |
| **M5.9** | Sidebar presets: named bundles of subtitle, audio and video settings, re-applied in one click | M | G8; sidebar models from M5.2–M5.4 | Saving and applying a preset restores every included setting |

### Track G: Media visuals (cut or future under D14)
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M6.1** | *Future.* Seek-bar thumbnails | L (spike) | Core `vlc_preparser_req_NewThumbnail` (fast seek), IINA's pre-generate approach, closed upstream MR !7822 as reference, `EnhancedImageExt` | Preview frames on hover; idle CPU afterwards; no crash on media change |
| **M6.2** | *Cut (D14).* Music now-playing screen (blurred artwork, centered cover, title–artist) | M | Existing `DualKawaseBlur` in `Player.qml`'s audio branch | Music score ≤ 0.5× baseline |
| **M6.3** | *Cut (D14).* Waveform provider (background thread, cached) | L (spike) | Choose between a second VLC player (`amem`) and libav decode; BBC `.dat` cache format; no GPL-3 code | Unit test passes; a 4-min track takes under 2 s; cache hits are instant |
| **M6.4** | *Cut (D14).* Waveform seek bar (played part in the accent color) | M | `SliderBar.qml` | Loud and quiet sections visible; seeking unchanged |

### Track H: Library extended
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M7.1** | Open file(s) and Open folder(s) dialogs, New playlist dialog (no network streams, M3U lists or capture, D14) | M | `dialogs/open` file pane, `dialogs/playlists` | Files and folders open into the queue; a new playlist saves with its name and thumbnail |
| **M7.2** | Compact library panel beside the video, opened from the folder name in the top bar | M | Queue-pane docking | Matches frame 187:328 (G19: it is this panel) |

**Gate R2 "Feature preview":** `r2` goes to a wider group of testers.

### Track I: Settings
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M8.1** | Settings framework and General page: declarative JSON page specs, generic rows, info icons, search, basic-then-advanced; legacy advanced tree still reachable | L (spike) | `dialogs/preferences/expert_model.*`, `vlc_config_Get*Choices`, `Dialogs.qml` host | Theme and accent change live and persist; search crosses pages; unknown config keys fail a check |
| **M8.2** | Pages: Interface, Playback, Video, Audio, Subtitles (human-worded dropdowns, no duplicates) | M | `settings-map.tsv` | Sampled settings write the right `vlcrc` keys |
| **M8.3** | Pages: Privacy (incl. online-subtitle consent and the "Save a log" setting that replaces the log viewer), Controls, Library, Performance. No Network, Recording or Extensions pages (D14) | M | `settings-map.tsv` | Same as M8.2 |
| **M8.4** | Keyboard shortcuts dialog (search, rebind, conflicts, reset) | M | Existing hotkeys panel logic, `vlc_actions` | Rebinding survives restart; conflicts flagged |

### Track J: Onboarding and polish
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M9.1** | 3-step QML onboarding (D12) replacing the first-run wizard (also update `shoot.sh`) | M–L | Settings row delegates, `MLFoldersModel` | Clean profile indexes the library through the new flow |
| **M9.2** | Light theme, HiDPI and accessibility polish; light-theme check of the window chrome (shadow and border contrast) | M–L | `makeLightPalette()`, complete tokens | Day scenes readable; keyboard-only walkthrough passes |

### Track K: Release
| ID | Milestone | Size | Key reuse / files | Accept |
|---|---|---|---|---|
| **M10.1** | Identity: app ID, icon, About credits, licences, designer contact (name decided: Redux Video Player, D16) | S | D16, G21 | App ID confirmed; credits shown |
| **M10.2** | **Moved into Q0.7 (D23).** CI: GitHub Actions builds the image and VLC, runs tests, the codec matrix and the screenshot diff, builds the Flatpak, uploads the report | M | Existing tools, M0.6 matrix, M0.7 manifest | PRs show green checks plus a report artifact |
| **M10.3** | Flathub submission, tagged release, install docs (Flatpak only, D13) | L | M0.7 manifest | Installs from Flathub (or the repo's own Flatpak remote) and plays the matrix on your machine and a second distro |

**Gate R3 "1.0 public".**

**Future** (parked under D14; each needs a `DECISIONS.md` entry to become a milestone):
- seek-bar thumbnails (M6.1)
- NVDEC hardware decoding
- live video-filter previews
- key shown in on-screen messages
- two-tone menu icons

Pins, subtitle timeline, OpenSubtitles and presets moved into milestones (M3.1, M5.7–M5.9). HDR stays as the Video
tab's HDR option plus libplacebo tone-mapping in M0.7. Not planned at all: Windows, macOS, AppImage (D13).

**Execution order:**
1. M0.5 → M0.6 → M0.7 (scope, lean build, Flatpak)
2. Q0.1 → Q0.7 (CI) → Q0.2 → Q0.6 (QA, D23, D26), then M0.8 (trim), the first milestone verified by QA
3. M1.1 → M0.2
4. M1.2 → M1.5
5. M2.1 → M2.3 → **R0**
6. M2.4 → M2.7, then M3.1 → M3.6 → **R1**
7. M4 → M5 (M5.1–M5.9) → M7 → **R2**
8. M8 → M9 → M10 → **R3**

## Risks and mitigations
| Risk | Mitigation |
|---|---|
| Upstream changes cause merge conflicts | Monthly syncs on `sync/<date>-<sha>` branches; new files over deep edits; weekly `git log` watch |
| VLC 4 master bugs unrelated to our work | Pin green commits; reproduce on stock VLC at the pin first |
| Qt version skew (6.11 in the dev container and the Flatpak's KDE 6.11 runtime; 6.8 in VLC's contribs) | Dev and Flatpak share Qt 6.11.2; keep QML compatible with 6.8 so upstream merges stay easy; rebuild the Flatpak when the KDE runtime updates Qt (private headers, D22) |
| Misleading diff scores | Region crops, video area masked; your eyes are final |
| Scope creep (~100 frames) | Strict out-of-scope per milestone; backlog; gates |
| Context loss between sessions | `CLAUDE.md` + `STATUS.md` + "next step" log entries |
| Two people editing the same files | One milestone per person, claimed by issue assignment; parallel milestones must not touch the same files (D25) |
| Headless Wayland/KWin in a container is fiddly | Xvfb fallback; your desktop for chrome and shadows; L5/L7 start non-blocking (D23) |
| Clash with an installed system VLC config | Isolated profile (M0.3); Flatpak from M0.7 |
| Wayland limits (always-on-top, title bars differ) | In-window floating card; window chrome is ours on every desktop (M2.3, D19); test both title-bar modes |
| Subtitle timeline or library scans cause UI stalls | Worker threads, cancellation, memory caps, QML profiler |
| Licensing (GPL-3 code, fonts, design, trademark) | No GPL-3 copying; Inter under OFL; M10.1 checks; credit the designer |
| Cutting a module breaks a format users expect | The M0.6 matrix runs on every build; a cut is reverted with a `DECISIONS.md` entry |
| Codec licensing and patents in a public Flatpak | Bundle FFmpeg as Flathub VLC does; no encoders or disc decryption (D14, D15) |

## Upstream sync
- **Cadence:** monthly or at each gate, only between milestones.
- **Steps:**
  1. Merge a green upstream commit.
  2. Run the full build, tests, all scenes and the diff report.
  3. Update `redux/UPSTREAM_COMMIT`.
  4. Log conflicts in `DECISIONS.md`.
