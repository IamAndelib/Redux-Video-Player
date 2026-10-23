#!/usr/bin/env bash
# The QA suite (redux/QA.md): runs every layer built so far and writes build/qa/report.md. Run it inside the dev
# container:
#
#   redux/dev.sh run redux/tools/qa.sh            all layers: L1 hygiene, L2 codec matrix, L3 VLC's tests
#   redux/dev.sh run redux/tools/qa.sh L1 L3      only these layers
#
# Exit status: 0 green, 1 a check failed, 2 a test case file is invalid. Results: build/qa/results.tsv
# ("<check>\t<pass|fail|skip>\t<detail>"), logs under build/qa/. The Flatpak layer (L8) runs on the host with
# redux/tools/flatpak.sh matrix until CI runs it (Q0.7).
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
builddir="${BUILD_DIR:-build/meson}"
export QA_OUT="$PWD/build/qa" QA_RESULTS="$PWD/build/qa/results.tsv"
layers=("$@")
[[ ${#layers[@]} -gt 0 ]] || layers=(L1 L2 L3)
for layer in "${layers[@]}"; do
  [[ "$layer" =~ ^L[123]$ ]] || { echo "unknown layer '$layer' (built so far: L1 L2 L3)" >&2; exit 2; }
done
rm -rf "$QA_OUT" && mkdir -p "$QA_OUT"
: > "$QA_RESULTS"
result() { printf '%s\t%s\t%s\n' "$1" "$2" "$3" >> "$QA_RESULTS"; echo "  $2  $1${3:+  ($3)}"; }
wants() { [[ " ${layers[*]} " == *" $1 "* ]]; }

[[ -f "$builddir/build.ninja" ]] || redux/tools/build.sh > "$QA_OUT/configure.log" 2>&1

if wants L1; then
  echo "== L1 build and hygiene"
  redux/qa/l1-hygiene.sh
  redux/qa/l1-kwin.sh   # the app in a headless KWin Wayland session (Q0.2)
  if lint="$(redux/qa/token-lint.sh 2>&1)"; then   # exit 1: violations, 2: it couldn't run
    result l1.token-lint pass "$(tail -1 <<< "$lint")"
  else
    printf '%s\n' "$lint" > "$QA_OUT/token-lint.txt"
    result l1.token-lint fail "$(($(wc -l <<< "$lint") - 1)) line(s); see $QA_OUT/token-lint.txt"
  fi
fi

if wants L3; then
  echo "== L3 VLC's test suite (meson test)"
  # Upstream's CI gives each test 60 s (extras/ci/gitlab-ci.yml); the 10 s default fails under parallel load (G25).
  testlog="$builddir/meson-logs/testlog.json"
  rm -f "$testlog"   # never report a previous run's results
  VLC_TEST_TIMEOUT="${VLC_TEST_TIMEOUT:-60}" meson test -C "$builddir" --num-processes "$(nproc)" \
    > "$QA_OUT/meson-test.log" 2>&1
  status=$?
  if [[ $status -eq 125 || ! -s "$testlog" ]]; then   # 125: meson couldn't build the tests
    result l3.run fail "meson test exited $status without results; see $QA_OUT/meson-test.log"
  else
    result l3.run pass "meson test exited $status"
  fi
  [[ -s "$testlog" ]] && python3 -I - "$testlog" "$QA_RESULTS" <<'EOF'
import json, sys
status = {"OK": "pass", "SKIP": "skip", "EXPECTEDFAIL": "pass"}
with open(sys.argv[2], "a") as out:
    for line in open(sys.argv[1]):
        test = json.loads(line)
        result = status.get(test["result"], "fail")
        detail = "" if result != "fail" else f"{test['result']} after {test['duration']:.1f} s; see build/qa/meson-test.log"
        name = test["name"].rsplit(":", 1)[-1]   # "src+test_src+test - VLC:test_src_player_eof" -> the test name
        out.write(f"l3.{name}\t{result}\t{detail}\n")
EOF
  grep -E "^(Ok|Fail|Skipped|Timeout):" "$QA_OUT/meson-test.log" | tr -s ' ' | paste -sd' ' | sed 's/^/  /'
fi

if wants L2; then
  echo "== L2 codec and format matrix"
  [[ -d build/matrix ]] || { redux/tools/make-matrix.sh > "$QA_OUT/make-matrix.log" 2>&1; }
  redux/tools/play-matrix.sh > "$QA_OUT/matrix.log" 2>&1
  summary="$(grep -E '^[0-9]+ passed, [0-9]+ failed' "$QA_OUT/matrix.log")"
  if [[ "$summary" =~ ^[0-9]+\ passed,\ 0\ failed ]]; then
    result l2.matrix pass "${summary%% (*}"
  else
    result l2.matrix fail "${summary:-no summary} $(grep -m3 FAIL "$QA_OUT/matrix.log" | awk '{print $1}' | paste -sd' ')"
  fi
fi

echo "== report"
python3 -I redux/qa/report.py "$QA_RESULTS" "$QA_OUT/report.md"
status=$?
echo "  $QA_OUT/report.md"
exit $status
