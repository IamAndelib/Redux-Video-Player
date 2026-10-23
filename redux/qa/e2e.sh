#!/usr/bin/env bash
# QA layer L5 (Q0.3, redux/QA.md): end-to-end user flows in the real app, driven through AT-SPI by KDE's
# selenium-webdriver-at-spi inside the headless KDE session (redux/tools/kwin-session.sh). Run by redux/tools/qa.sh
# (`qa.sh L5`) inside the dev container; appends one `l5.<test>` result per test to $QA_RESULTS and keeps the
# driver and player logs in $QA_OUT/l5/.
#
#   redux/qa/e2e.sh [test ...]     default: every test in redux/qa/e2e/test_*.py (names as `test_playback.PlaybackTest`)
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
export QA_OUT="${QA_OUT:-$PWD/build/qa}" QA_RESULTS="${QA_RESULTS:-$PWD/build/qa/results.tsv}"
out="$QA_OUT/l5"
mkdir -p "$out"

if [[ "${1:-}" != --in-session ]]; then
  rm -f "$out/results.tsv"
  redux/tools/kwin-session.sh "$0" --in-session "$@" > "$out/session.log" 2>&1
  if [[ -s "$out/results.tsv" ]]; then
    cat "$out/results.tsv" >> "$QA_RESULTS"
    while IFS=$'\t' read -r check status detail; do echo "  $status  $check${detail:+  ($detail)}"; done < "$out/results.tsv"
  else
    printf '%s\t%s\t%s\n' l5.run fail "the end-to-end session didn't run; see $out/session.log" >> "$QA_RESULTS"
    echo "  fail  l5.run  (see $out/session.log)"
  fi
  exit 0
fi

# --- inside the session ----------------------------------------------------------------------------------------
shift
# The driver injects keyboard and mouse input through this KWin's fake-input protocol.
KWIN_PID="$(pidof kwin_wayland)"
export KWIN_PID
driver_dir=/usr/local/share/selenium-webdriver-at-spi
(cd "$driver_dir" && exec env FLASK_APP=selenium-webdriver-at-spi.py python3 -m flask run --port 4723 --no-reload) \
  > "$out/driver.log" 2>&1 &
driver=$!
trap 'kill "$driver" 2>/dev/null || true' EXIT
for _ in $(seq 100); do
  curl -fs http://127.0.0.1:4723/status >/dev/null 2>&1 && break
  sleep 0.1
done

/opt/e2e/bin/python -I redux/qa/e2e/run.py "$out/results.tsv" "$@"
