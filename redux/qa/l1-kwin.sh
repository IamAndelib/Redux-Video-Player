#!/usr/bin/env bash
# QA checks for the headless KDE session (Q0.2, redux/QA.md), run by redux/tools/qa.sh (L1) inside the dev container:
#   l1.kwin-session     the real app runs as a Wayland client in redux/tools/kwin-session.sh: it opens SMPTE colour
#                       bars and quits cleanly with no unexplained log problems
#   l1.kwin-screenshot  a screenshot through KWin shows the bars; needs OpenGL compositing, so a DRM render node (a GPU,
#                       or vgem); skipped where there is none, e.g. GitHub's runners (G27)
# Appends the results to $QA_RESULTS and keeps the log and screenshot in $QA_OUT/l1/.
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
root="$PWD"
out="$QA_OUT/l1"
verdict="$out/kwin-session.verdict"
mkdir -p "$out"

if [[ "${1:-}" != --in-session ]]; then
  rm -f "$verdict"
  redux/tools/kwin-session.sh "$0" --in-session > "$out/kwin-session.log" 2>&1
  [[ -s "$verdict" ]] ||
    printf '%s\t%s\t%s\n' l1.kwin-session fail "the KWin session didn't run the check; see $out/kwin-session.log" \
      l1.kwin-screenshot skip "the session didn't run" > "$verdict"
  while IFS=$'\t' read -r check status detail; do
    printf '%s\t%s\t%s\n' "$check" "$status" "$detail" >> "$QA_RESULTS"
    echo "  $status  $check  ($detail)"
  done < "$verdict"
  exit 0
fi

# --- inside the session ----------------------------------------------------------------------------------------
verdict() { # verdict <session status> <detail> [<screenshot status> <detail>]
  printf '%s\t%s\t%s\n' l1.kwin-session "$1" "$2" l1.kwin-screenshot "${3:-skip}" "${4:-the session check failed}" \
    > "$verdict"
  exit 0
}

vlc="$root/${BUILD_DIR:-build/meson}/bin/vlc-static"
clip="$root/build/media/Videos/Shows/The Wand/S01/The_Wand_S01E06.mp4"   # 12 s of SMPTE bars (make-media.sh)
log="$out/kwin-app.log"
shot="$out/kwin-session.png"
export HOME="$out/profile-kwin"
rm -rf "$HOME" "$shot" && mkdir -p "$HOME"
[[ -f "$clip" ]] || redux/tools/make-media.sh >/dev/null

source redux/tools/lib/app-session.sh
source redux/qa/lib/log-problems.sh

# Software only, the same on every machine: the shared-memory Wayland video output (VLC's OpenGL output refuses
# llvmpipe, #72, and its GBM path can crash under software GL, #73; the Qt interface still renders with OpenGL) and
# software decoding (with a GPU visible, VA-API frames can't take the OSD title blend in shared memory; CI has no
# VA-API at all). Hardware decoding is a hand check on a real desktop (M0.7-3).
if ! app_start "$log" -vv --no-qt-privacy-ask --vout=wl --no-hw-dec "$clip"; then
  app_stop >/dev/null 2>&1
  problems "$log" > "$out/kwin-app.problems"
  verdict fail "no video output; see $log"
fi
sleep 3   # a few frames on screen
# KWin takes screenshots only when it composites with OpenGL, which needs a DRM render node (D30, G27); an Azure VM's
# display-only card0 doesn't count. A cancelled screenshot is a skip only where there is no render node at all;
# with one, KWin should have composited with OpenGL, so it's a failure (a broken GPU stack mustn't hide as a skip).
python3 -I redux/tools/kwin-shot.py "$shot" > "$out/kwin-shot.log" 2>&1
shot_status=$?
if [[ $shot_status -eq 3 ]] && ! compgen -G '/dev/dri/renderD*' >/dev/null; then
  shot_status=skip
fi
alive=yes; kill -0 "$app_pid" 2>/dev/null || alive=no
app_stop; status=$?

# The bars' 75 % yellow, cyan and magenta must each cover a real area of the screenshot.
bars_seen() {
  local colour count
  for colour in "rgb(191,191,0)" "rgb(0,191,191)" "rgb(191,0,191)"; do
    count="$(magick "$shot" -alpha off -fuzz 12% -fill black +opaque "$colour" -fill white -opaque "$colour" \
               -format '%[fx:round(mean*w*h)]' info: 2>/dev/null)" || return 1
    (( ${count:-0} >= 1000 )) || return 1
  done
}

if [[ "$shot_status" == skip ]]; then
  screenshot=(skip "no DRM render node for OpenGL compositing (G27)")
elif [[ "$shot_status" -ne 0 ]]; then
  screenshot=(fail "no screenshot; see $out/kwin-shot.log")
elif ! bars_seen; then
  screenshot=(fail "the screenshot doesn't show the colour bars; see $shot")
else
  screenshot=(pass "the screenshot shows the video")
fi

found="$(problems "$log")"
if [[ "$alive" == no ]]; then
  verdict fail "the player died while playing (exit $status); see $log" "${screenshot[@]}"
elif [[ $status -ne 0 ]]; then
  verdict fail "quit with exit $status; see $log" "${screenshot[@]}"
elif [[ -n "$found" ]]; then
  printf '%s\n' "$found" > "$out/kwin-app.problems"
  verdict fail "$(wc -l <<< "$found") log problem(s), first: $(head -1 <<< "$found" | cut -c1-140)" "${screenshot[@]}"
else
  verdict pass "plays in KWin (Wayland) and quits with exit 0" "${screenshot[@]}"
fi
