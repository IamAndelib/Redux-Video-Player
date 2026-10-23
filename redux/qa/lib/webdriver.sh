# Shared by the checks that drive the app through AT-SPI inside redux/tools/kwin-session.sh (Q0.3's end-to-end flows,
# Q0.4's screenshot scenes): KDE's selenium-webdriver-at-spi server (D31).
#
#   webdriver_start <log>   starts the server on port 4723 and waits for it (10 s); returns 1 if it didn't start, or
#                           if another one already answers there (it would launch the app in its own, older session).
#                           It's stopped when the calling script exits (so don't `exec` from that script).

webdriver_start() {
  if curl -fs http://127.0.0.1:4723/status >/dev/null 2>&1; then
    echo "a WebDriver server from another session already answers on port 4723" >> "$1"
    return 1
  fi
  # The driver injects keyboard and mouse input through this KWin's fake-input protocol.
  KWIN_PID="$(pidof kwin_wayland)"
  export KWIN_PID
  (cd /usr/local/share/selenium-webdriver-at-spi &&
     exec env FLASK_APP=selenium-webdriver-at-spi.py python3 -m flask run --port 4723 --no-reload) > "$1" 2>&1 &
  webdriver_pid=$!
  trap 'kill "$webdriver_pid" 2>/dev/null || true' EXIT
  for _ in $(seq 100); do
    curl -fs http://127.0.0.1:4723/status >/dev/null 2>&1 && return 0
    sleep 0.1
  done
  return 1
}
