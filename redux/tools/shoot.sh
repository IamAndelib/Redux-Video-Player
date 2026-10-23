#!/usr/bin/env bash
# Capture screenshots of the built player at 1920x1080 in the headless KDE session (redux/tools/kwin-session.sh), for
# comparison against the Figma frames (redux/tools/compare.sh). Run inside the dev container:
#
#   redux/dev.sh run redux/tools/shoot.sh [scene...]        (default: all scenes)
#
# Scenes (redux/qa/visual/scenes.py, Q0.4): first-run, library, player, window. Output: build/shots/<scene>.png.
# THEME=night|day|system picks VLC's color scheme (default night, to match the dark Figma frames).
# The scenes drive the app through AT-SPI like a user and share a throw-away profile (build/shots/session/) whose
# Videos folder is the generated test media. The first-run scene walks the first-run wizard, which indexes that
# folder for the library scene, so run it first (the default order does).
# KWin takes screenshots only with a DRM render node (a GPU or vgem), so this doesn't run on GitHub's runners (G27).
set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
out=build/shots

if [[ "${1:-}" == --in-session ]]; then
  source redux/qa/lib/webdriver.sh
  webdriver_start "$out/session/driver.log" || { echo "the WebDriver server didn't start" >&2; exit 1; }
  /opt/e2e/bin/python -I redux/qa/visual/scenes.py "$2"   # not exec: the server must stop with this script
  exit 0   # (set -e already left with the runner's status if it failed)
fi

[[ -x "${BUILD_DIR:-build/meson}/bin/vlc-static" ]] || { echo "no player; run redux/tools/build.sh first" >&2; exit 1; }
compgen -G '/dev/dri/renderD*' >/dev/null || { echo "no DRM render node: KWin can't take screenshots (G27)" >&2; exit 1; }
[[ -d build/media ]] || redux/tools/make-media.sh >/dev/null
mkdir -p "$out/session"
scenes=("$@")
[[ ${#scenes[@]} -gt 0 ]] || scenes=(first-run library player window)
for scene in "${scenes[@]}"; do
  [[ "$scene" =~ ^(first-run|library|player|window)$ ]] || { echo "unknown scene: $scene" >&2; exit 1; }
  # One session per scene. The window scene sits away from the corner so its shadow shows.
  position=0,0; [[ "$scene" == window ]] && position=160,90
  if ! KWIN_WINDOW_POSITION="$position" redux/tools/kwin-session.sh "$0" --in-session "$scene" \
       > "$out/session/$scene.log" 2>&1; then
    echo "scene $scene failed; see $out/session/$scene.log" >&2
    exit 1
  fi
  grep -o 'captured .*' "$out/session/$scene.log"
done
