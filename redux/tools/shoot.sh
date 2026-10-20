#!/usr/bin/env bash
# Capture screenshots of the built player at 1920x1080 on a headless X server, for
# comparison against the Figma frames (redux/tools/compare.sh). Run inside the dev container:
#
#   redux/dev.sh run redux/tools/shoot.sh [scene...]        (default: all scenes)
#
# Scenes: first-run, library, player. Output: build/shots/<scene>.png
# THEME=night|day|system picks VLC's color scheme for the later scenes (default night, to
# match the dark Figma frames).
# The player uses a throwaway profile (build/shots/profile) whose Videos folder points at the
# generated test media. The first-run scene walks the first-run wizard, which adds that folder
# to the media library, so run it before library (the default order does). The library is
# video-only (redux/SCOPE.md), so there is no music scene.
set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
root="$PWD"
builddir="${BUILD_DIR:-build/meson}"
vlc="$root/$builddir/bin/vlc-static"
media="$root/build/media"
out="$root/build/shots"
profile="$out/profile"
W=1920 H=1080
case "${THEME:-night}" in system) scheme=0 ;; day) scheme=1 ;; night) scheme=2 ;; *) echo "THEME must be night, day or system" >&2; exit 1 ;; esac

[[ -x "$vlc" ]] || { echo "no player at $vlc; run redux/tools/build.sh first" >&2; exit 1; }
[[ -d "$media" ]] || redux/tools/make-media.sh "$media" >/dev/null

mkdir -p "$out" "$profile/.config"
printf 'XDG_VIDEOS_DIR="%s"\n' "$media/Videos" > "$profile/.config/user-dirs.dirs"

# Headless X server; force Qt onto it even when the host Wayland socket is passed through.
display=:99
Xvfb "$display" -screen 0 "${W}x${H}x24" -nolisten tcp &
xvfb_pid=$!
trap 'kill "$xvfb_pid" 2>/dev/null || true' EXIT
export DISPLAY="$display" QT_QPA_PLATFORM=xcb HOME="$profile"
unset WAYLAND_DISPLAY
for _ in $(seq 50); do xdpyinfo >/dev/null 2>&1 && break; sleep 0.1; done

vlc_pid=""
start_vlc() {
  # Dummy audio output: Xvfb runs have no sound server, and VLC would show an error banner.
  "$vlc" --no-qt-system-tray --no-qt-video-autoresize --aout=dummy "$@" >"$out/vlc.log" 2>&1 &
  vlc_pid=$!
  local wins=""
  for _ in $(seq 100); do
    wins="$(xdotool search --onlyvisible --pid "$vlc_pid" 2>/dev/null || true)"
    [[ -n "$wins" ]] && break
    sleep 0.2
  done
  [[ -n "$wins" ]] || { echo "VLC window did not appear; see $out/vlc.log" >&2; return 1; }
}

fill_screen() {
  # VLC maps several windows; there's no window manager, so size them all ourselves.
  # (xdotool --sync would wait forever for a window manager's reply.)
  local w
  for w in $(xdotool search --onlyvisible --pid "$vlc_pid" 2>/dev/null || true); do
    xdotool windowmove "$w" 0 0 windowsize "$w" "$W" "$H" 2>/dev/null || true
  done
  sleep 1
}

stop_vlc() {
  [[ -n "$vlc_pid" ]] || return 0
  kill "$vlc_pid" 2>/dev/null || true
  wait "$vlc_pid" 2>/dev/null || true
  vlc_pid=""
}

shoot() { # shoot <scene> <settle-seconds>
  sleep "$2"
  import -window root "$out/$1.png"
  echo "captured $out/$1.png"
}

scene_first_run() {
  rm -rf "$profile/.config/vlc" "$profile/.local/share/vlc" "$profile/.cache/vlc"
  start_vlc --qt-privacy-ask
  shoot first-run 3
  # Accept the wizard defaults, which include the XDG Videos folder. Use the buttons'
  # mnemonics (&Next, &Finish): Return would hit the folder page's "add folder" button.
  for _ in 1 2 3 4; do xdotool key alt+n; sleep 1; done
  xdotool key alt+f
  sleep 10   # let the media library index the test media
  stop_vlc
  set_scheme
}

set_scheme() {
  local conf="$profile/.config/vlc/vlc-qt-interface.conf"
  [[ -f "$conf" ]] || return 0
  if grep -q '^color-scheme-index=' "$conf"; then
    sed -i "s/^color-scheme-index=.*/color-scheme-index=$scheme/" "$conf"
  else
    sed -i "s/^\\[MainWindow\\]$/[MainWindow]\\ncolor-scheme-index=$scheme/" "$conf"
  fi
}

scene_library() {
  start_vlc --no-qt-privacy-ask
  fill_screen
  shoot library 4
  stop_vlc
}

scene_player() {
  start_vlc --no-qt-privacy-ask --start-time=40 --start-paused \
    "$media/Videos/Shows/The Wand/S01/The_Wand_S01E04.mp4"
  fill_screen
  xdotool mousemove $((W / 2)) $((H - 60))   # hovering reveals the player controls
  shoot player 3
  stop_vlc
}

scenes=("$@")
[[ ${#scenes[@]} -gt 0 ]] || scenes=(first-run library player)
for s in "${scenes[@]}"; do
  fn="scene_${s//-/_}"
  declare -F "$fn" >/dev/null || { echo "unknown scene: $s" >&2; exit 1; }
  "$fn"
done
