# Status

One row per milestone. Update the row (and the milestone file's status log) whenever its state changes.
Statuses: `todo` → `research` → `wip` → `review` → `done`; `blocked` (name the gap); `cut` and `future` (out of scope or parked under D14, see `redux/SCOPE.md`). Scores are the region
RMSE from `compare.sh` (baseline set in M0.3).

**Next up: M0.6 hand-over** (lean build and codec/format matrix, in review: test it in the app), then M0.7 (Flatpak skeleton) → M0.8 (UI trim) before the design work resumes at M1.1. Scope: [`redux/SCOPE.md`](../SCOPE.md).

| ID | Milestone | Track | Size | Status | Issue / PR | Region score | Updated |
|---|---|---|---|---|---|---|---|
| P0 | Phase 0: dev container, VLC import, build, media, harness, transcript | A | — | done | — | player 0.168 (whole frame) | 2026-10-13 |
| M0.1 | Tracking scaffolding | A | S | done | [#1](https://github.com/IamAndelib/Redux-Video-Player/issues/1) | | 2026-10-13 |
| M0.2 | Complete the design source | A | S | todo | [#2](https://github.com/IamAndelib/Redux-Video-Player/issues/2) | |  |
| M0.3 | Harness v2 and isolated run profile | A | S–M | todo | [#3](https://github.com/IamAndelib/Redux-Video-Player/issues/3) | |  |
| M0.4 | Video design brief (cleaned transcript, brief, frames) | A | S–M | done | [#52](https://github.com/IamAndelib/Redux-Video-Player/issues/52) / [PR #53](https://github.com/IamAndelib/Redux-Video-Player/pull/53) | | 2026-10-21 |
| M0.5 | Scope foundation (SCOPE.md, D13–D16, roadmap, issues) | A | S | done | [#44](https://github.com/IamAndelib/Redux-Video-Player/issues/44) / [PR #53](https://github.com/IamAndelib/Redux-Video-Player/pull/53) | | 2026-10-21 |
| M0.6 | Lean build profile and codec/format matrix | A | M | review | [#45](https://github.com/IamAndelib/Redux-Video-Player/issues/45) | | 2026-10-21 |
| M0.7 | Flatpak skeleton | A | M | todo | [#46](https://github.com/IamAndelib/Redux-Video-Player/issues/46) | |  |
| M0.8 | Feature trim in the UI | A | M | todo | [#47](https://github.com/IamAndelib/Redux-Video-Player/issues/47) | |  |
| M1.1 | Night palette from Figma tokens | B | S | todo | [#4](https://github.com/IamAndelib/Redux-Video-Player/issues/4) | |  |
| M1.2 | Typography and shape tokens | B | M | todo | [#5](https://github.com/IamAndelib/Redux-Video-Player/issues/5) | |  |
| M1.3 | Live accent presets | B | M | todo | [#6](https://github.com/IamAndelib/Redux-Video-Player/issues/6) | |  |
| M1.4 | Monochrome icon set | B | M | todo | [#7](https://github.com/IamAndelib/Redux-Video-Player/issues/7) | |  |
| M1.5 | Base widgets | B | M | todo | [#8](https://github.com/IamAndelib/Redux-Video-Player/issues/8) | |  |
| M2.1 | One-row bottom bar | C | M | todo | [#9](https://github.com/IamAndelib/Redux-Video-Player/issues/9) | |  |
| M2.2 | Cone volume | C | S | todo | [#10](https://github.com/IamAndelib/Redux-Video-Player/issues/10) | |  |
| M2.3 | Top bar | C | M | todo | [#11](https://github.com/IamAndelib/Redux-Video-Player/issues/11) | |  |
| **R0** | **Gate R0** | | | todo | | | |
| M2.4 | Subtitle, Audio and Queue buttons | C | M | todo | [#12](https://github.com/IamAndelib/Redux-Video-Player/issues/12) | |  |
| M2.5 | Edge-hover reveal, Hide UI, resume prompt | C | M | todo | [#13](https://github.com/IamAndelib/Redux-Video-Player/issues/13) | |  |
| M2.6 | Shared … and right-click menu | C | M | todo | [#14](https://github.com/IamAndelib/Redux-Video-Player/issues/14) | |  |
| M2.7 | Playback essentials: folder auto-next, resume, wheel setting | C | M | todo | [#48](https://github.com/IamAndelib/Redux-Video-Player/issues/48) | |  |
| M3.1 | Icon rail sidebar (Home, Videos, Playlists, Recent, pins) | D | M | todo | [#15](https://github.com/IamAndelib/Redux-Video-Player/issues/15) | |  |
| M3.2 | Library header (breadcrumbs, sort, search) | D | M | todo | [#16](https://github.com/IamAndelib/Redux-Video-Player/issues/16) | |  |
| M3.3 | Grid and list items with progress underline | D | M | todo | [#17](https://github.com/IamAndelib/Redux-Video-Player/issues/17) | |  |
| M3.4 | Library context menus | D | M | todo | [#18](https://github.com/IamAndelib/Redux-Video-Player/issues/18) | |  |
| M3.5 | Floating miniplayer card | D | M | todo | [#19](https://github.com/IamAndelib/Redux-Video-Player/issues/19) | |  |
| M3.6 | Home and Recent pages (no streams or music) | D | M | todo | [#20](https://github.com/IamAndelib/Redux-Video-Player/issues/20) | |  |
| **R1** | **Gate R1** | | | todo | | | |
| M4.1 | Missing Customize controls | E | M | todo | [#21](https://github.com/IamAndelib/Redux-Video-Player/issues/21) | |  |
| M4.2 | Customize modal and profiles | E | M | todo | [#22](https://github.com/IamAndelib/Redux-Video-Player/issues/22) | |  |
| M5.1 | Right sidebar shell | F | M | todo | [#23](https://github.com/IamAndelib/Redux-Video-Player/issues/23) | |  |
| M5.2 | Audio effect cards | F | M (spike) | todo | [#24](https://github.com/IamAndelib/Redux-Video-Player/issues/24) | |  |
| M5.3 | Video tab | F | M | todo | [#25](https://github.com/IamAndelib/Redux-Video-Player/issues/25) | |  |
| M5.4 | Subtitle styling and default language | F | M | todo | [#26](https://github.com/IamAndelib/Redux-Video-Player/issues/26) | |  |
| M5.5 | Playback tab, A-B loop, frame stepping, bookmarks and chapters | F | M | todo | [#27](https://github.com/IamAndelib/Redux-Video-Player/issues/27) | |  |
| M5.6 | Add Subtitles dialog (local) | F | M | todo | [#28](https://github.com/IamAndelib/Redux-Video-Player/issues/28) | |  |
| M5.7 | Online subtitle search (OpenSubtitles) | F | M | todo | [#49](https://github.com/IamAndelib/Redux-Video-Player/issues/49) | |  |
| M5.8 | Subtitle timeline | F | L (spike) | todo | [#50](https://github.com/IamAndelib/Redux-Video-Player/issues/50) | |  |
| M5.9 | Sidebar presets | F | M | todo | [#51](https://github.com/IamAndelib/Redux-Video-Player/issues/51) | |  |
| M6.1 | Seek-bar thumbnails | G | L (spike) | future | [#29](https://github.com/IamAndelib/Redux-Video-Player/issues/29) | | 2026-10-20 |
| M6.2 | Music now-playing screen | G | M | cut | [#30](https://github.com/IamAndelib/Redux-Video-Player/issues/30) | | 2026-10-20 |
| M6.3 | Waveform provider | G | L (spike) | cut | [#31](https://github.com/IamAndelib/Redux-Video-Player/issues/31) | | 2026-10-20 |
| M6.4 | Waveform seek bar | G | M | cut | [#32](https://github.com/IamAndelib/Redux-Video-Player/issues/32) | | 2026-10-20 |
| M7.1 | Open file/folder dialogs and New playlist | H | M | todo | [#33](https://github.com/IamAndelib/Redux-Video-Player/issues/33) | |  |
| M7.2 | Compact library panel beside the video | H | M | todo | [#34](https://github.com/IamAndelib/Redux-Video-Player/issues/34) | |  |
| **R2** | **Gate R2** | | | todo | | | |
| M8.1 | Settings framework and General page | I | L (spike) | todo | [#35](https://github.com/IamAndelib/Redux-Video-Player/issues/35) | |  |
| M8.2 | Settings pages: Interface, Playback, Video, Audio, Subtitles | I | M | todo | [#36](https://github.com/IamAndelib/Redux-Video-Player/issues/36) | |  |
| M8.3 | Settings pages: Privacy, Controls, Library, Performance | I | M | todo | [#37](https://github.com/IamAndelib/Redux-Video-Player/issues/37) | |  |
| M8.4 | Keyboard shortcuts dialog | I | M | todo | [#38](https://github.com/IamAndelib/Redux-Video-Player/issues/38) | |  |
| M9.1 | QML onboarding (3 steps) | J | M–L | todo | [#39](https://github.com/IamAndelib/Redux-Video-Player/issues/39) | |  |
| M9.2 | Light theme, HiDPI and accessibility polish | J | M–L | todo | [#40](https://github.com/IamAndelib/Redux-Video-Player/issues/40) | |  |
| M10.1 | Identity: app ID, icon, credits (name decided, D16) | K | S | todo | [#41](https://github.com/IamAndelib/Redux-Video-Player/issues/41) | |  |
| M10.2 | CI | K | M | todo | [#42](https://github.com/IamAndelib/Redux-Video-Player/issues/42) | |  |
| M10.3 | Flathub submission and launch | K | L | todo | [#43](https://github.com/IamAndelib/Redux-Video-Player/issues/43) | |  |
| **R3** | **Gate R3** | | | todo | | | |
