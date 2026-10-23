#!/usr/bin/env bash
# Run a command inside a headless KDE Plasma Wayland session: KWin's virtual backend, a private D-Bus session bus
# and an AT-SPI accessibility bus, in the dev container (Q0.2, D30). The command runs as a normal Wayland client;
# the session ends when it exits, with its exit status.
#
#   redux/dev.sh run redux/tools/kwin-session.sh <command> [args...]
#
# Inside the session, `python3 -I redux/tools/kwin-shot.py <out.png>` takes a screenshot of the whole desktop.
# Rendering is software everywhere (Mesa's llvmpipe), so a desktop with a GPU behaves like a CI runner without one.
# KWin composites with OpenGL, which its screenshots need; that takes a DRM device: the GPU on a desktop, or the
# kernel's virtual `vgem` device (as in KDE's CI). Without one, as on GitHub's runners (G27), KWin falls back to
# QPainter: apps still run, but screenshots fail. KWIN_WIDTH/KWIN_HEIGHT set the screen size (default 1920x1080).
#
# The session recipe follows KDE's own test runner, selenium-webdriver-at-spi's run.rb (ideas only; credited in
# redux/CREDITS.md).
set -euo pipefail

self="$(readlink -f "${BASH_SOURCE[0]}")"

if [[ "${1:-}" == --inner ]]; then
  # Inside KWin: WAYLAND_DISPLAY is set and the session bus is up. Start the accessibility bus now and export its
  # address, so Qt apps find it without racing its on-demand start.
  shift
  /usr/libexec/at-spi-bus-launcher --launch-immediately >/dev/null 2>&1 &
  for _ in $(seq 50); do
    addr="$(gdbus call --session --dest org.a11y.Bus --object-path /org/a11y/bus \
              --method org.a11y.Bus.GetAddress 2>/dev/null | sed -n "s/^('\(.*\)',)$/\1/p")" || true
    [[ -n "$addr" ]] && break
    sleep 0.1
  done
  [[ -n "${addr:-}" ]] && export AT_SPI_BUS_ADDRESS="$addr"
  # KWin's own exit status doesn't carry the command's, so hand it over in a file.
  status=0
  "$@" || status=$?
  echo "$status" > "$REDUX_SESSION_DIR/status"
  exit "$status"
fi

[[ $# -ge 1 ]] || { sed -n '2,13p' "$self" | sed 's/^# \{0,1\}//'; exit 2; }

# A private runtime dir and throw-away settings, so nothing from the host desktop (its Wayland socket, which
# redux/dev.sh passes through, or its KDE config) leaks into the session.
session="$(mktemp -d)"
trap 'rm -rf "$session"' EXIT
mkdir -m 700 "$session/runtime"
export XDG_RUNTIME_DIR="$session/runtime" XDG_CONFIG_HOME="$session/config" XDG_CACHE_HOME="$session/cache" \
       XDG_DATA_HOME="$session/data" XDG_STATE_HOME="$session/state"
unset WAYLAND_DISPLAY DISPLAY
export REDUX_SESSION_DIR="$session"

export LIBGL_ALWAYS_SOFTWARE=1 KWIN_COMPOSE="${KWIN_COMPOSE:-O2}" QT_QPA_PLATFORM=wayland \
       KWIN_SCREENSHOT_NO_PERMISSION_CHECKS=1 KWIN_WAYLAND_NO_PERMISSION_CHECKS=1 \
       KWIN_XKB_DEFAULT_KEYMAP=true XKB_DEFAULT_LAYOUT=us

# KWin takes the command to start as one string; a small script avoids quoting the arguments into it.
printf '#!/usr/bin/env bash\nexec %q --inner' "$self" > "$session/command"
printf ' %q' "$@" >> "$session/command"
chmod +x "$session/command"

dbus-run-session -- kwin_wayland --virtual --no-lockscreen --no-global-shortcuts \
  --width="${KWIN_WIDTH:-1920}" --height="${KWIN_HEIGHT:-1080}" --socket=wayland-redux \
  --exit-with-session "$session/command" || true
if [[ ! -s "$session/status" ]]; then
  echo "kwin-session: the session ended before the command finished (KWin failed to start?)" >&2
  exit 125
fi
exit "$(<"$session/status")"
