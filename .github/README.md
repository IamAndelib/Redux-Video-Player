# Redux Video Player

A lean, Linux-only video player built on [VLC](https://www.videolan.org/vlc/) 4, wearing
[Juxtopposed](https://www.youtube.com/@juxtopposed)'s redesign of VLC
([video](https://youtu.be/ERFeOgqk324), [Figma](https://www.figma.com/design/CAuJVJyM5yY7PnyQQK9X24/VLC-Redesign--Community-)).

- **Offline video first:** plays local files with the widest codec and format support we can ship.
- **Minimal:** the best of VLC, without the features most people never use. What ships is listed in
  [`redux/SCOPE.md`](../redux/SCOPE.md).
- **Linux only, as a Flatpak.**

> **Status:** early development. Nothing to install yet. Progress is in
> [`redux/milestones/STATUS.md`](../redux/milestones/STATUS.md).

## For contributors
- Session rules and commands: [`CLAUDE.md`](../CLAUDE.md)
- Dev environment (Podman): [`redux/README.md`](../redux/README.md)
- Roadmap: [`redux/milestones/ROADMAP.md`](../redux/milestones/ROADMAP.md)
- Design guide: [`redux/design/brief.md`](../redux/design/brief.md)

Everything specific to this project lives in `redux/` and `modules/gui/qt/`. The rest of the tree is upstream VLC
(its own README is [`README.md`](../README.md)).

## Credits and licence
- Design: Juxtopposed, who released the redesign as open source and free to use.
- Player engine: VLC by VideoLAN and its contributors. Redux Video Player is not affiliated with or endorsed by
  VideoLAN; "VLC" and the cone are VideoLAN trademarks.
- Licence: GPL-2.0-or-later, like VLC's Qt interface (see [`COPYING`](../COPYING)).
