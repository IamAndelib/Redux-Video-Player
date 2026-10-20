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

### D9 · 2026-10-13 · Upstream contributions as we go
- **Decision:**
  - Small, generally useful fixes and features are prepared on `up/<slug>` branches from `upstream/master` in VLC commit style.
  - The maintainer submits them as MRs on code.videolan.org, and they're cherry-picked into `main`.
- **Candidates so far:**
  - `systempalette.cpp:635` alpha bug
  - swapped FRAME_PREV/NEXT entries in `PlayerControlbarControls.qml`
  - `MLBookmarkModel` invokables
  - later: seek thumbnails, waveform
- **Why:** goodwill, fewer merge conflicts, and others benefit.
- **Alternatives:** keep everything in the fork.

### D10 · 2026-10-13 · Player first
- **Decision:** milestone order makes the redesigned player usable first (design system → player screen, gate R0), then the library (R1 daily driver), then customize, panels and visuals (R2), then settings, onboarding and release (R3).
- **Why:** the player is where users spend their time, and the maintainer chose it.
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
