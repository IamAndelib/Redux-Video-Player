#!/usr/bin/env bash
# QA check l1.kwin-session (Q0.2, redux/QA.md): the real app runs as a Wayland client in a headless KDE session
# (redux/tools/kwin-session.sh). It opens SMPTE colour bars, a screenshot through KWin shows the bars, and it quits
# cleanly with no unexplained log problems. Run by redux/tools/qa.sh (L1) inside the dev container; appends its
# result to $QA_RESULTS and keeps the log and screenshot in $QA_OUT/l1/.
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
root="$PWD"
out="$QA_OUT/l1"
verdict="$out/kwin-session.verdict"
mkdir -p "$out"

if [[ "${1:-}" != --in-session ]]; then
  rm -f "$verdict"
  redux/tools/kwin-session.sh "$0" --in-session > "$out/kwin-session.log" 2>&1
  if [[ -s "$verdict" ]]; then
    IFS=$'\t' read -r status detail < "$verdict"
  else
    status=fail detail="the KWin session didn't run the check; see $out/kwin-session.log"
  fi
  printf '%s\t%s\t%s\n' l1.kwin-session "$status" "$detail" >> "$QA_RESULTS"
  echo "  $status  l1.kwin-session  ($detail)"
  exit 0
fi

# --- inside the session ----------------------------------------------------------------------------------------
verdict() { printf '%s\t%s\n' "$1" "$2" > "$verdict"; exit 0; }

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
app_start "$log" -vv --no-qt-privacy-ask --vout=wl --no-hw-dec "$clip" || verdict fail "no video output; see $log"
sleep 3   # a few frames on screen
python3 -I redux/tools/kwin-shot.py "$shot" >> "$out/kwin-session.log" 2>&1
shot_status=$?
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

found="$(problems "$log")"
if [[ "$alive" == no ]]; then
  verdict fail "the player died while playing (exit $status); see $log"
elif [[ $status -ne 0 ]]; then
  verdict fail "quit with exit $status; see $log"
elif [[ $shot_status -ne 0 ]]; then
  verdict fail "no screenshot; see $out/kwin-session.log"
elif ! bars_seen; then
  verdict fail "the screenshot doesn't show the colour bars; see $shot"
elif [[ -n "$found" ]]; then
  printf '%s\n' "$found" > "$out/kwin-app.problems"
  verdict fail "$(wc -l <<< "$found") log problem(s), first: $(head -1 <<< "$found" | cut -c1-140)"
else
  verdict pass "plays in KWin (Wayland), screenshot shows the video, quit with exit 0"
fi
