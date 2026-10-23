#!/usr/bin/env bash
# QA layer L1 (redux/QA.md): the build is clean, no cut plugin is built, and the real Qt app starts in Night and
# Day without QML warnings or unexplained errors and quits cleanly. Run by redux/tools/qa.sh inside the dev
# container; appends "<check>\t<pass|fail>\t<detail>" lines to $QA_RESULTS and keeps logs in $QA_OUT/l1/.
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
root="$PWD"
builddir="${BUILD_DIR:-build/meson}"
vlc="$root/$builddir/bin/vlc-static"
out="$QA_OUT/l1"
clip="$root/build/media/Videos/Clips/subtitles-ass-demo.mkv"   # 60 s, video + audio + ASS subtitles
mkdir -p "$out"

result() { printf '%s\t%s\t%s\n' "$1" "$2" "$3" >> "$QA_RESULTS"; echo "  $2  $1${3:+  ($3)}"; }

# --- the dev image's files match their Debian checksums (G26) ---------------------------------------------------
# A bit flipped in memory once corrupted a cached library and made the build crash; this tells such environment
# faults apart from code bugs before anything else runs.
bad="$(dpkg --verify 2>/dev/null | grep -E '^..5' | awk '{print $NF}')"
if [[ -z "$bad" ]]; then
  result l1.env-integrity pass "every packaged file matches its checksum"
else
  result l1.env-integrity fail "checksum mismatch (memory or disk fault, G26): $(head -3 <<< "$bad" | paste -sd' ')"
fi

# --- build -----------------------------------------------------------------------------------------------------
if meson compile -C "$builddir" > "$out/build.log" 2>&1; then
  result l1.build pass "$(grep -c ': warning:' "$out/build.log") compiler warnings in what this run rebuilt"
else
  result l1.build fail "see $out/build.log: $(grep -m1 -E 'error:|FAILED' "$out/build.log" | cut -c1-120)"
fi

# --- no cut plugin is built (D20) ------------------------------------------------------------------------------
built=()
while read -r name; do
  [[ -e "$builddir/modules/lib${name}_plugin.so" ]] && built+=("$name")
done < <(grep -v '^[[:space:]]*#' redux/cut-modules.txt | sed '/^[[:space:]]*$/d')
if [[ ${#built[@]} -eq 0 ]]; then
  result l1.cut-plugins pass "$(grep -cv -e '^[[:space:]]*#' -e '^[[:space:]]*$' redux/cut-modules.txt) cut, none built"
else
  result l1.cut-plugins fail "built although cut: ${built[*]}"
fi

# --- the Qt app starts clean and quits clean, in Night and Day -------------------------------------------------

source redux/tools/lib/app-session.sh
source redux/qa/lib/log-problems.sh
[[ -f "$clip" ]] || redux/tools/make-media.sh >/dev/null
xvfb_start :97 1920 1080 || { result l1.startup fail "Xvfb did not start"; exit 0; }
trap 'app_stop >/dev/null 2>&1 || true; xvfb_stop' EXIT

for theme in night day; do
  case "$theme" in day) scheme=1 ;; night) scheme=2 ;; esac
  profile="$out/profile-$theme"
  rm -rf "$profile" && mkdir -p "$profile/.config/vlc"
  printf '[MainWindow]\ncolor-scheme-index=%s\n' "$scheme" > "$profile/.config/vlc/vlc-qt-interface.conf"
  export HOME="$profile" XDG_RUNTIME_DIR="$profile/run"
  mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"
  log="$out/startup-$theme.log"

  if ! app_start "$log" -vv --no-qt-privacy-ask "$clip"; then
    result "l1.startup.$theme" fail "no window; see $log"
    app_stop >/dev/null 2>&1
    continue
  fi
  sleep 8   # play a while: subtitles render, the queue autosaves, the library starts
  alive=yes; kill -0 "$app_pid" 2>/dev/null || alive=no
  app_stop; status=$?
  found="$(problems "$log")"
  if [[ "$alive" == no ]]; then
    result "l1.startup.$theme" fail "the player died while playing (exit $status); see $log"
  elif [[ $status -ne 0 ]]; then
    result "l1.startup.$theme" fail "quit with exit $status; see $log"
  elif [[ -n "$found" ]]; then
    result "l1.startup.$theme" fail "$(wc -l <<< "$found") log problem(s), first: $(head -1 <<< "$found" | cut -c1-140)"
    printf '%s\n' "$found" > "$out/startup-$theme.problems"
  else
    result "l1.startup.$theme" pass "window shown, no Qt/QML warnings or errors, quit with exit 0"
  fi
done

# --- quitting with the media library loaded (G24) --------------------------------------------------------------
export HOME="$out/profile-quit"; rm -rf "$HOME"; mkdir -p "$HOME"
timeout 60 "$vlc" -I dummy --media-library --aout=dummy --vout=dummy --play-and-exit --stop-time=2 "$clip" \
  > "$out/quit.log" 2>&1
status=$?
if [[ $status -eq 0 ]]; then
  result l1.quit pass "exit 0 with the media library loaded"
else
  result l1.quit fail "exit $status (139 = segfault, 124 = hung); see $out/quit.log"
fi
