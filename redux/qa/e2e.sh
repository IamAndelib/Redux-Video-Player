#!/usr/bin/env bash
# QA layer L5 (Q0.3, redux/QA.md): end-to-end user flows in the real app, driven through AT-SPI by KDE's
# selenium-webdriver-at-spi inside the headless KDE session (redux/tools/kwin-session.sh). Run by redux/tools/qa.sh
# (`qa.sh L5`) inside the dev container; appends one `l5.<test>` result per test to $QA_RESULTS and keeps the
# driver and player logs in $QA_OUT/l5/.
#
#   redux/qa/e2e.sh [test ...]     default: every test in redux/qa/e2e/test_*.py (names as `test_playback.EndAndRestart`)
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
export QA_OUT="${QA_OUT:-$PWD/build/qa}" QA_RESULTS="${QA_RESULTS:-$PWD/build/qa/results.tsv}"
out="$QA_OUT/l5"
mkdir -p "$out"

if [[ "${1:-}" != --in-session ]]; then
  [[ -d build/media/Videos ]] || redux/tools/make-media.sh >/dev/null
  rm -f "$out/results.tsv"
  # Each app launch takes a while, and a failing test waits out its timeouts: more time than kwin-session's default.
  KWIN_SESSION_TIMEOUT="${KWIN_SESSION_TIMEOUT:-900}" redux/tools/kwin-session.sh "$0" --in-session "$@" \
    > "$out/session.log" 2>&1
  status=$?
  if [[ -s "$out/results.tsv" ]]; then
    # 125: the session ended without the runner's status (its timeout killed it, or KWin died). Rows so far are kept.
    [[ $status -eq 125 ]] &&
      printf '%s\t%s\t%s\n' l5.run fail "the session ended early (exit $status); see $out/session.log" >> "$out/results.tsv"
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
source redux/qa/lib/webdriver.sh
if ! webdriver_start "$out/driver.log"; then
  printf '%s\t%s\t%s\n' l5.driver fail "the WebDriver server didn't start; see $out/driver.log" > "$out/results.tsv"
  exit 1
fi

/opt/e2e/bin/python -I redux/qa/e2e/run.py "$out/results.tsv" "$@"
