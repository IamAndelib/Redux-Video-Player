# Decisions

Lightweight decision records, newest at the bottom. Add one whenever a choice is non-obvious, touches code outside
`modules/gui/qt` and `redux/`, or would be expensive to reverse. Format: date, decision, why, alternatives considered.

---

### D1 · 2026-10-12 · Fork VLC master and redesign its Qt/QML interface
- **Decision:** Build on VLC 4 (`master`), redesigning `modules/gui/qt`. Don't write a skin or a separate libVLC app.
- **Why:**
  - VLC 4's QML UI already has a toolbar editor, mini player, themes, accent option, blur, medialibrary views and every audio filter the design needs.
  - skins2 can't do library, settings, blur or a toolbar editor.
  - A libVLC app would have to rebuild the library, preferences and effects.
- **Alternatives:** skins2 `.vlt` skin (~20–30% of the design); standalone Qt/Tauri/Electron app on libVLC.

### D2 · 2026-10-13 · Pin upstream to green CI commits and merge, never rebase
- **Decision:**
  - VLC history is imported in full; the current pin is in `redux/UPSTREAM_COMMIT` (`a5538c557d27`).
  - Syncs merge a commit whose upstream CI passed, monthly or at gates, between milestones.
- **Why:**
  - Master is unreleased and moves fast, so a known-green base keeps unrelated breakage out.
  - Merging keeps everyone's checkouts valid.
- **Alternatives:** tracking master continuously; rebasing our commits.

### D3 · 2026-10-13 · Dev image built locally from Debian sid with VideoLAN's CI package list
- **Decision:** `.devcontainer/Containerfile` copies the package list of `videolan/docker-images` `vlc-debian-unstable`. It doesn't pull `registry.videolan.org`. Android/Rust toolchains are dropped.
- **Why:** the registry served the multi-GB image at about 0.2 MB/s. Building locally from Debian's CDN takes a few minutes.
- **Alternatives:** pulling the official image; a Fedora base (package names and codecs differ from upstream CI).

### D4 · 2026-10-13 · Fastest Debian mirror chosen at build time
- **Decision:** `redux/tools/fastest-debian-mirror.sh` benchmarks mirrors and passes `DEBIAN_MIRROR` to the build. The host CA bundle is mounted for the first apt step. Python deps install with `uv` (parallel downloads).
- **Why:** apt has no fastestmirror or parallel-downloads setting. The default CDN gave about 140 kB/s here, versus 4–5 MB/s from the fastest mirror.
- **Alternatives:** a fixed mirror (not portable for other contributors).

### D5 · 2026-10-13 · medialibrary 0.13.2 built from source in the image
- **Decision:** build VideoLAN medialibrary 0.13.2 (same version and SHA-512 as VLC's `contrib/src/medialibrary`) into `/usr/local`.
- **Why:** VLC master's medialibrary module doesn't compile against Debian's 0.14.1 (the `IMedia::setThumbnail` API changed), even though meson only asks for `>= 0.13`.
- **Alternatives:** patching VLC for 0.14 (diverges from upstream); disabling the media library (loses the library UI).

### D6 · 2026-10-13 · Design source stays local; only derived data is committed
- **Decision:**
  - Figma exports (`file.json`, frame PNGs, icon SVGs) and the `.fig` live in the git-ignored `redux/design/source/`.
  - Derived artifacts are committed: `tokens.json`, `screen-map.md`, frame/icon indexes, and later the icon font.
  - Access is through `redux/tools/figma-export.py` with a personal token kept outside the repo.
- **Why:**
  - The Figma MCP Starter plan allows only a handful of calls.
  - The REST API allows about 20 heavy calls a month, so exports must be batched and cached.
  - The designer's source file shouldn't be republished.
- **Alternatives:** committing the source exports; relying on the MCP.

### D7 · 2026-10-13 · Tracking: repo docs as source of truth, mirrored to GitHub
- **Decision:**
  - `redux/milestones/` (ROADMAP, STATUS, GAPS, DECISIONS, per-milestone files) is authoritative.
  - GitHub Issues (one per milestone) grouped under GitHub Milestones R0–R3 mirror it for visibility and feedback.
- **Why:**
  - Sessions must resume from in-repo state alone; that is the defense against context loss.
  - GitHub gives the maintainer a familiar place to follow and comment.
- **Alternatives:** repo docs only; GitHub only.

### D8 · 2026-10-13 · Branching: `main` plus one PR per milestone
- **Decision:**
  - `main` is the default and integration branch.
  - Each milestone gets `m/M<ID>-<slug>` and a squash-merged PR (`M<ID>: …`).
  - Upstream syncs use `sync/<date>-<sha>` (merge commit).
  - History is never rewritten.
- **Why:** reviewable units, easy rollback per milestone, and a readable history on top of VLC's.
- **Alternatives:** direct commits with tags.
- **Exception (2026-10-20):** M0.2's transcript work, M0.4, the local setup and M0.5 were done on the cloud-session
  branch `claude/vlc-ui-redesign-scope-wzy21y` and reach `main` through one PR. From M0.6 on, the rule applies again.

### D9 · 2026-10-13 · Upstream contributions as we go
- **Decision:**
  - Small, generally useful fixes and features are prepared on `up/<slug>` branches from `upstream/master` in VLC commit style.
  - The maintainer submits them as MRs on code.videolan.org, and they're cherry-picked into `main`.
- **Candidates so far:**
  - `systempalette.cpp:635` alpha bug
  - swapped FRAME_PREV/NEXT entries in `PlayerControlbarControls.qml`
  - `MLBookmarkModel` invokables
  - later: seek thumbnails, if M6.1 comes back (the waveform was cut, D14)
- **Why:** goodwill, fewer merge conflicts, and others benefit.
- **Alternatives:** keep everything in the fork.

### D10 · 2026-10-13 · Player first
- **Decision:** milestone order makes the redesigned player usable first (design system → player screen, gate R0), then the library (R1 daily driver), then customize, panels and visuals (R2), then settings, onboarding and release (R3).
- **Why:** the player is where users spend their time, and the maintainer chose it.
- **Amended by D14:** the scope foundations M0.5–M0.8 come first; Track G visuals are cut or future, so R2 is
  customize, panels and library extended.
- **Alternatives:** library first; restyle everything before any layout change.

### D11 · 2026-10-13 · Touch-to-tokenize, no global sweeps
- **Decision:** hard-coded colors (~36 QML sites) and radii (~48) are replaced with `VLCStyle`/`ColorContext` tokens only in files a milestone already edits.
- **Why:** global sweeps would conflict with nearly every upstream merge.
- **Alternatives:** one big cleanup milestone.

### D12 · 2026-10-20 · Video frames correct three plans
- **Decision:**
  - Onboarding has **3 steps** (welcome and media folder, theme and accent, shortcuts), not 11. Figma's 12 frames are those 3 steps with step 2 drawn once per accent.
  - **Bookmarks and chapters are tabs of the queue panel** (Queue | Bookmarks | Chapters), not part of the right sidebar. M5.5 still builds them.
  - **Fullscreen sits with the window buttons**, top-right; the bottom bar has none.
- **Why:** the M0.4 frame review (`redux/design/brief.md`, Video vs Figma) shows all three in the video, and Figma agrees on the first and third.
- **Alternatives:** keeping the earlier readings (an 11-step wizard from the frame count; bookmarks in the sidebar from the narration; fullscreen bottom-right from "move them to the right side").

### D13 · 2026-10-20 · Linux only, shipped as a Flatpak
- **Decision:** Redux Video Player targets Linux only and ships as a Flatpak. AppImage, Windows and macOS are dropped.
  The Flatpak is built from M0.7 on, not only at release.
- **Why:** one packaging format reaches every distro; the maintainer runs Linux; VLC's macOS UI is native Cocoa, not
  Qt, so other platforms would double the work.
- **Alternatives:** Flatpak plus AppImage; distro packages; keeping Windows/macOS in the backlog.

### D14 · 2026-10-20 · Product scope: offline video, maximum formats, minimal features
- **Decision:** what ships is fixed in `redux/SCOPE.md` (keep / cut / future). Cut features are switched off in the
  build (M0.6) and their entry points removed from the UI (M0.8); upstream code is not deleted. Milestones M6.2–M6.4
  are cut and M6.1 is future; new milestones M0.5–M0.8, M2.7 and M5.7–M5.9 are added.
- **Why:** the maintainer wants a simple player focused on offline video with the best of VLC. Community research
  (VideoLAN forum, upstream issues, Lemmy/Reddit mirrors, Flathub's VLC) shows the cut features are online-only,
  broken, niche or better served by other tools. Disabling instead of deleting keeps upstream merges cheap (D2, D11).
- **Alternatives:** the full redesign including music, streaming and conversion; deleting upstream code.

### D15 · 2026-10-20 · Bundle FFmpeg in the Flatpak; VA-API only
- **Decision:** the Flatpak bundles a current FFmpeg plus dav1d, libplacebo (with Vulkan, for HDR tone-mapping) and
  libass, instead of relying on `org.freedesktop.Platform.codecs-extra`. Hardware decoding is VA-API only (Intel,
  AMD, and NVIDIA through nvidia-vaapi-driver); NVDEC is future. No encoders and no disc-decryption libraries ship.
- **Why:** maximum codec support has to work out of the box and on our versions. Flathub's VLC also bundles its own
  FFmpeg; users report H.264 failing with `codecs-extra`; VLC 4 needs a far newer FFmpeg (and libplacebo) than
  Flathub's VLC 3 build pins.
- **Alternatives:** `codecs-extra`; VA-API plus NVDEC.

### D16 · 2026-10-20 · Name: Redux Video Player
- **Decision:** the product is **Redux Video Player**. The GitHub repo is renamed `IamAndelib/Redux-Video-Player`
  (2026-10-20), so the app ID is `io.github.iamandelib.Redux-Video-Player`: Flathub takes the ID's last part as the
  repo name "as-is", and dashes are allowed only there (confirmed in M10.1, G21). The local checkout folder and
  internal names (`vlc-redux-dev` image, `~/.config/vlc-redux/`) stay. The About dialog and README credit
  Juxtopposed (design) and VideoLAN (VLC).
- **Why:** "VLC" and the cone are VideoLAN trademarks, and a renamed fork is the safe course.
- **Alternatives:** "VLC Redux"; deciding the name at release.

### D17 · 2026-10-20 · Fork front page in `.github/README.md`
- **Decision:** the GitHub landing page is `.github/README.md` (GitHub shows it in place of the root README). It
  explains Redux Video Player, links the fork's docs and credits Juxtopposed and VideoLAN. The root `README.md` stays
  upstream VLC's, untouched.
- **Why:** visitors land on a page about this project; editing the root README would conflict on every upstream merge.
- **Alternatives:** a banner at the top of the root README.

### D18 · 2026-10-20 · Simple loop: build, hand over, feedback
- **Decision:** Claude completes each milestone end to end (research, plan, implement, verify) and hands over a
  build the maintainer opens from the host app menu ("Redux Video Player (dev)", `redux/tools/launcher.sh`, which
  runs `redux/dev.sh app`). The maintainer tests it and gives feedback; Claude fixes and hands over again. When the
  maintainer says it's good, Claude squash-merges the milestone PR and moves on. Plans are not approved separately;
  Claude asks only when a gap needs the maintainer's decision.
- **How the app runs:** inside the dev container on the host display, with a persistent profile in
  `build/app-home` (never the system VLC config) and the maintainer's home folder mounted read-only, so their own
  files open and drag and drop works. The container gained Intel/Mesa VA-API drivers for this, and the app uses VLC's
  PulseAudio output through the host's PulseAudio/PipeWire socket. From M0.7 on, the launcher can switch to the Flatpak build.
- **Every hand-over** comes with a numbered test checklist: for each item what to open, what to do and what to
  expect, then what is known not to work yet, and how to report (`CLAUDE.md`, `TEMPLATE.md`).
- **Why:** the maintainer wants a simple loop judged on the running app, not on documents.
- **Alternatives:** plan approval before each milestone; reviewing PRs on GitHub; installing builds on the host.

### D19 · 2026-10-21 · Window chrome: VLC's custom chrome, restyled
- **Decision:** the title bar, shadow, resize edges and window buttons are VLC 4's existing Qt-based custom chrome
  (`FramelessWindowHint` with `startSystemMove`/`startSystemResize`, a QML-drawn shadow in a transparent margin,
  Wayland input mask), made the Redux default and restyled in M2.3. New pieces only: a Fullscreen window button,
  a window radius and a 1 px border from tokens, and an opaque content background. Backdrop blur is off by default;
  the system title bar stays a preference.
- **Why:** the maintainer asked to use Qt for the title bar, shadows, radius and borders. VLC already does this in Qt,
  so we configure and restyle instead of writing new code. KWin adds no shadow for frameless Wayland windows, and
  GNOME has no server-side decorations, so drawing our own chrome is the only way to match the Figma on every
  desktop. Blur exists only on KWin and, without it, makes panels see-through.
- **Alternatives:** system title bars (can't hold the Figma's folder name, centered title and Fullscreen button);
  QtWayland decoration plugins (GNOME-only look); a new frameless implementation.

### D20 · 2026-10-21 · Cut plugins by name through VLC's own `enabled` flag
- **Decision:** `redux/cut-modules.txt` lists the 190 plugins outside the product scope. `build.sh` passes it as the
  meson array option `redux_cut_modules`, and three lines in `modules/meson.build` mark those modules
  `enabled: false`, the flag VLC already uses for disabled modules (tests that need them are skipped). 232 plugins
  are built. The codec/format matrix (`make-matrix.sh`, `fetch-samples.sh`, `play-matrix.sh`) proves what remains
  plays everything in scope.
- **Why:** one list covers plugins with and without their own build options; the upstream touch is two tiny hunks
  (`meson_options.txt`, `modules/meson.build`), so merges stay easy; the dev app and the Flatpak ship the same set.
- **Alternatives:** `--auto-features=disabled` plus an allowlist (misses option-less plugins such as http, udp,
  ftp and all of `stream_out/`); per-directory meson guards (many upstream hunks); deleting plugin files at
  packaging time (the dev app would differ from what ships).

### D21 · 2026-10-21 · Play after the end restarts the video (player core)
- **Decision:** when `play-and-pause` has paused a video on its last frame (M0.6 turns it on for the last item in the
  queue), playing again starts it from the beginning. A flag `paused_at_eof` on the player input is set at that
  pause, cleared by any seek, and `vlc_player_SetPause(false)` resets the position when it is set. 14 lines in
  `src/player/{player.h,input.c,player.c}`.
- **Why:** maintainer feedback; it is what other players (MPC-HC, IINA, web players) do. Doing it in the player core,
  not the Qt button, covers every way of pressing play: the button, Space (VLC's hotkeys module), media keys and
  MPRIS. A seek in between still resumes from the seek position. VLC's 20 player tests pass. Upstreamable.
- **Alternatives:** handling it in Qt only (Space, media keys and MPRIS would bypass it); stopping instead of pausing
  at the end (loses the last frame on screen).

### D22 · 2026-10-23 · Flatpak builds on the host with Flathub's Builder app
- **Decision:** the Flatpak is built on the host with Flathub's `org.flatpak.Builder` app and the KDE 6.11
  runtime/SDK (Qt 6.11.2, the same Qt as the dev container), all installed per user from Flathub
  (`flatpak --user`, removable with `flatpak uninstall`). `redux/tools/flatpak.sh` wraps build, run, lint and the
  codec matrix inside the sandbox. This is the one exception to the "never install anything on the host" rule,
  approved by the maintainer.
- **Why:** running the app needs the runtime on the host anyway; the Builder app is how Flathub itself builds and
  lints apps; building inside the Podman container would need a privileged container for nested sandboxing.
- **Alternatives:** flatpak-builder inside the dev container.

### D23 · 2026-10-23 · Milestones are verified by a QA suite and an agent loop (amends D18)
- **Decision:** the maintainer's QA plan is adopted as [`redux/QA.md`](../QA.md). Track Q (Q0.1–Q0.7) runs after
  M0.7 and before M0.8 and builds it: test cases traced to the brief, scope and acceptance criteria; layers L1–L9
  (build hygiene, codec matrix, player core, components, end-to-end flows, visual fidelity, UX heuristics, sandbox,
  agent review); one entry point `redux/tools/qa.sh`; an agent loop that tests, triages, fixes and re-tests; CI.
  From M0.8 on, a milestone is done when the QA suite is green and its report is attached to the PR. The D18
  hand-over checklist shrinks to an optional 2–3 item real-desktop spot check (audio, GPU, feel); the maintainer
  evaluates the complete prototype with a guided script. M0.3 merges into Q0.4, and M10.2 (CI) moves into Q0.7.
- **Why:** the maintainer wants to step back from testing every milestone by hand; automated checks catch
  regressions every time, and tests derived from the docs make coverage measurable.
- **Alternatives:** keep full manual checklists (slow, misses regressions); openQA itself (heavy; region RMSE with
  masks covers the same need).

### D24 · 2026-10-23 · Upstream fixes for building without stream outputs
- **Decision:** the dev build and the Flatpak use `-Dstream_outputs=false -Dvideolan_manager=false` (VLM is cut,
  D14). Building that way exposed upstream bugs, fixed in files outside `modules/gui/qt/` and `redux/`:
  - `modules/codec/jpeg.c`: the quality option was declared only with the stream-output encoder, but the always-built
    image encoder (snapshots, thumbnails) reads it, so it hit `vlc_assert_unreachable` (undefined behaviour in
    release builds). The option now sits with the image encoder.
  - `src/preparser/internal.c`: the WebP, RGBA and ARGB thumbnail formats need image encoders that only exist with
    stream outputs; they are offered only then (PNG and JPEG are unaffected).
  - `test/src/meson.build`, `test/modules/meson.build`: tests that need stream outputs (`player_attachments`,
    `mux_webvtt`) are disabled without them; `media_source` depends on a services discovery plugin (`podcast`), so
    the D20 cut guard skips it.
  All are upstreamable and wait on the `up/no-sout-fixes` branch.
- **Why:** KISS: VLC's own option is the simplest way to drop every encoder, muxer and stream output (D15); fixing the
  bugs it exposes beats keeping code we don't ship.
- **Alternatives:** keep stream outputs on and cut each plugin by name (larger build, the bugs stay hidden).

### D25 · 2026-10-23 · Working with collaborators: GitHub issues are the work queue
- **Decision:** a collaborator works like the maintainer's agent sessions: pick an open milestone issue, assign
  yourself (that is the claim), work on its `m/<ID>-<slug>` branch, open a draft PR early, and hand over for the
  maintainer's review; the maintainer merges. One milestone per person at a time, and two people never work on the
  same milestone or on milestones that edit the same files. `STATUS.md` stays the progress record; the issue
  assignee says who. Feedback and bugs are filed as issues (or comments on the milestone issue), not kept in chat.
  The front door is [`CONTRIBUTING.md`](../../CONTRIBUTING.md).
- **Why:** the maintainer added a collaborator; work tracked only in files or conversations can't be shared.
- **Alternatives:** a GitHub Project board (needs extra token scopes and duplicates `STATUS.md`).
