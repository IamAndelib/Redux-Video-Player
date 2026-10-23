# Run the built player headless: on Xvfb, or as a Wayland client inside redux/tools/kwin-session.sh. Sourced by
# redux/tools/shoot.sh and redux/qa/l1-*.sh. Callers set `vlc` (the player binary) and HOME (a throwaway profile).
#
#   xvfb_start <display> <width> <height>   start Xvfb and point Qt at it
#   xvfb_stop
#   app_start <log> [vlc args...]            start the player; returns 1 if its window never appears (on Wayland,
#                                            where no client sees another's windows: until video output starts,
#                                            so pass media and -vv)
#   app_stop                                 SIGTERM (as when the session ends); returns the player's exit
#                                            status, 124 if it had to be killed

xvfb_start() {
  Xvfb "$1" -screen 0 "${2}x${3}x24" -nolisten tcp 2>/dev/null &   # xkbcomp keymap warnings are noise
  xvfb_pid=$!
  export DISPLAY="$1" QT_QPA_PLATFORM=xcb   # even when the host Wayland socket is passed through
  unset WAYLAND_DISPLAY
  local _
  for _ in $(seq 50); do xdpyinfo >/dev/null 2>&1 && return 0; sleep 0.1; done
  echo "Xvfb did not start on $1" >&2
  return 1
}

xvfb_stop() {
  [[ -n "${xvfb_pid:-}" ]] || return 0
  kill "$xvfb_pid" 2>/dev/null || true
  wait "$xvfb_pid" 2>/dev/null || true
  xvfb_pid=""
}

app_start() {
  local log="$1" _
  shift
  # Dummy audio output: Xvfb runs have no sound server, and VLC would show an error banner.
  "$vlc" --no-qt-system-tray --no-qt-video-autoresize --aout=dummy "$@" >"$log" 2>&1 &
  app_pid=$!
  for _ in $(seq 100); do
    if [[ -n "${REDUX_SESSION_DIR:-}" ]]; then   # inside redux/tools/kwin-session.sh
      grep -q 'using vout display module' "$log" 2>/dev/null && return 0
    else
      xdotool search --onlyvisible --pid "$app_pid" >/dev/null 2>&1 && return 0
    fi
    kill -0 "$app_pid" 2>/dev/null || break
    sleep 0.2
  done
  echo "the player window did not appear; see $log" >&2
  return 1
}

app_stop() {
  [[ -n "${app_pid:-}" ]] || return 0
  local pid="$app_pid" status=0 _
  app_pid=""
  kill -TERM "$pid" 2>/dev/null || true
  for _ in $(seq 60); do kill -0 "$pid" 2>/dev/null || break; sleep 0.25; done
  if kill -0 "$pid" 2>/dev/null; then
    kill -KILL "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
    return 124
  fi
  wait "$pid" || status=$?
  return "$status"
}
