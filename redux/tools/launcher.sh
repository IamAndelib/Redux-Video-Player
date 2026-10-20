#!/usr/bin/env bash
# Add (or remove) a "Redux Video Player (dev)" entry in your desktop's app menu. It opens the
# player built in this checkout through `redux/dev.sh app`, and shows up under "Open with" for
# video files. Run on the host (it only writes one .desktop file under ~/.local/share):
#
#   redux/tools/launcher.sh install
#   redux/tools/launcher.sh uninstall
#
# After a milestone, rebuild (`redux/dev.sh run redux/tools/build.sh`) and open the app from the menu.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
desktop="$apps/io.github.iamandelib.Redux-Video-Player.Devel.desktop"

case "${1:-}" in
  install)
    mkdir -p "$apps"
    cat > "$desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Redux Video Player (dev)
GenericName=Video Player
Comment=Development build from $repo
Exec="$repo/redux/dev.sh" app %F
Icon=multimedia-video-player
Terminal=false
Categories=AudioVideo;Video;Player;
MimeType=video/mp4;video/x-matroska;video/webm;video/quicktime;video/x-msvideo;video/mpeg;video/x-ms-wmv;video/x-flv;video/ogg;video/mp2t;video/3gpp;
EOF
    command -v update-desktop-database >/dev/null && update-desktop-database "$apps" 2>/dev/null || true
    echo "installed $desktop"
    ;;
  uninstall)
    rm -f "$desktop"
    command -v update-desktop-database >/dev/null && update-desktop-database "$apps" 2>/dev/null || true
    echo "removed $desktop"
    ;;
  *)
    sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
