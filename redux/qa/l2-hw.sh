#!/usr/bin/env bash
# QA check: hardware playback (Q0.8, redux/QA.md), run by redux/tools/qa.sh (L2) inside the dev container. On a machine
# with a GPU, every clip in redux/qa/hw-clips.tsv plays in the headless KDE session (redux/tools/kwin-session.sh) with
# the GPU's OpenGL, as on a desktop:
#   l2.hw.<clip>  decoded on the GPU (VA-API) where vainfo lists the clip's profile, else in software; either way no
#                 dropped picture, no log problem, and a clean exit
#   l2.hw.cpu     the HEVC 10-bit clip's CPU time with and without the GPU (reported, not gated: it's noisy)
#   l2.hw         skip: no DRM render node (GitHub's runners, G27) or no VA-API decoder on it
# Appends the results to $QA_RESULTS; logs, vainfo's output and the session log are in $QA_OUT/l2-hw/.
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
root="$PWD"
export QA_OUT="${QA_OUT:-$PWD/build/qa}" QA_RESULTS="${QA_RESULTS:-$PWD/build/qa/results.tsv}"
out="$QA_OUT/l2-hw"
clips="$root/build/hw-clips"
results="$out/results.tsv"
mkdir -p "$out"
result() { printf '%s\t%s\t%s\n' "$1" "$2" "$3" >> "$results"; }

if [[ "${1:-}" != --in-session ]]; then
  rm -f "$results"
  finish() {
    cat "$results" >> "$QA_RESULTS"
    while IFS=$'\t' read -r check status detail; do echo "  $status  $check${detail:+  ($detail)}"; done < "$results"
    exit 0
  }
  node="$(compgen -G '/dev/dri/renderD*' | head -1)"
  if [[ -z "$node" ]]; then
    result l2.hw skip "no DRM render node, so no GPU to test (G27)"; finish
  fi
  vainfo --display drm --device "$node" > "$out/vainfo.txt" 2>&1
  if ! grep -q 'VAEntrypointVLD' "$out/vainfo.txt"; then
    result l2.hw skip "no VA-API decoder on $node; see $out/vainfo.txt"; finish
  fi

  # 8 s of 1080p30 test pattern per clip, made once (never the 2 s matrix clips: too short to judge playback).
  mkdir -p "$clips"
  while IFS=$'\t' read -r name _ options; do
    [[ -z "$name" || "$name" == \#* || -s "$clips/$name.mkv" ]] && continue
    read -ra options <<< "$options"
    ffmpeg -nostdin -hide_banner -loglevel error -y -f lavfi -i testsrc2=size=1920x1080:rate=30:duration=8 \
      "${options[@]}" "$clips/$name.tmp.mkv" > "$out/encode-$name.log" 2>&1 &&
      mv "$clips/$name.tmp.mkv" "$clips/$name.mkv"
  done < redux/qa/hw-clips.tsv

  REDUX_SESSION_GPU=1 redux/tools/kwin-session.sh "$0" --in-session > "$out/session.log" 2>&1
  [[ -s "$results" ]] || result l2.hw fail "the KWin session didn't run the check; see $out/session.log"
  finish
fi

# --- inside the session ----------------------------------------------------------------------------------------
source redux/qa/lib/log-problems.sh
vlc="$root/${BUILD_DIR:-build/meson}/bin/vlc-static"
export HOME="$out/profile"
rm -rf "$HOME" && mkdir -p "$HOME"
tick="$(getconf CLK_TCK)"

# The GPU's video engine time (ns) used by a process so far, from the kernel's DRM usage stats
# (docs.kernel.org/gpu/drm-usage-stats.html): amdgpu reports drm-engine-dec (VCN), i915 drm-engine-video; a client's
# fds are counted once (drm-client-id). Empty when the driver reports neither.
engine_ns() {
  awk 'FNR == 1 { client = FILENAME }
       /^drm-client-id:/ { client = $2 }
       /^drm-engine-(dec|video):/ { seen = 1; if ($2 > used[client]) used[client] = $2 }
       END { if (seen) { for (c in used) sum += used[c]; print sum } }' /proc/"$1"/fdinfo/* 2>/dev/null
}

# play <log> <clip> [vlc option…]: plays the clip to its end, then sets: status (exit status, or "died" or
# "timeout"), engine (ns, or empty), cpu (s).
play() {
  local log="$1" clip="$2" pid sample ticks=0 deadline=$((SECONDS + 60))
  shift 2
  "$vlc" -I dummy --play-and-exit -vv --vout=gl "$@" "$clip" > "$log" 2>&1 &
  pid=$!
  engine=
  while kill -0 "$pid" 2>/dev/null; do
    sample="$(engine_ns "$pid")"
    [[ -n "$sample" ]] && engine="$sample"
    sample="$(awk '{ print $14 + $15 }' /proc/"$pid"/stat 2>/dev/null)"   # user + system time in clock ticks
    [[ -n "$sample" ]] && ticks="$sample"
    if (( SECONDS > deadline )); then kill -9 "$pid"; wait "$pid" 2>/dev/null; status=timeout; break; fi
    sleep 0.5
  done
  [[ "${status:-}" == timeout ]] || { wait "$pid"; status=$?; }
  cpu="$(awk -v t="$ticks" -v hz="$tick" 'BEGIN { printf "%.1f", t / hz }')"
}

declare -A cpu_on_gpu
while IFS=$'\t' read -r name profile _; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  check="l2.hw.$name"
  if [[ ! -s "$clips/$name.mkv" ]]; then
    result "$check" fail "FFmpeg couldn't make the clip; see $out/encode-$name.log"; continue
  fi
  expect=software
  grep -Eq "^[[:space:]]*$profile[[:space:]]*:[[:space:]]*VAEntrypointVLD" "$out/vainfo.txt" && expect=gpu
  log="$out/$name.log"
  status=
  play "$log" "$clips/$name.mkv"
  cpu_on_gpu[$name]="$cpu"

  on_gpu=no
  grep -q 'vaapi generic: Using ' "$log" && grep -q 'using glinterop module "glinterop_vaapi"' "$log" && on_gpu=yes
  dropped="$(grep -c 'picture is too late to be displayed' "$log")"   # one line per lost picture
  late="$(grep -c 'picture displayed late' "$log")"
  decoder="$(grep -o 'using video decoder module "[^"]*"' "$log" | tail -1 | cut -d'"' -f2)"
  found="$(problems "$log")"
  # Falling back means VLC first probed the GPU and logged why it can't ("profile(32) is not supported",
  # "avcodec_get_hw_frames_parameters failed"): an error only where the GPU was expected to decode.
  [[ $expect == software ]] && found="$(grep -v '^vaapi generic error: ' <<< "$found")"
  [[ -n "$found" ]] && printf '%s\n' "$found" > "$out/$name.problems"
  engine_s="${engine:+$(awk -v n="$engine" 'BEGIN { printf "%.1f", n / 1e9 }')}"

  if [[ "$status" != 0 ]]; then
    result "$check" fail "the player exited with $status; see $log"
  elif [[ $expect == gpu && $on_gpu == no ]]; then
    result "$check" fail "decoded in software (${decoder:-no decoder}), but vainfo lists $profile; see $log"
  elif [[ $expect == gpu && "$engine" == 0 ]]; then
    result "$check" fail "VLC reports VA-API, but the GPU's decode engine stayed idle; see $log"
  elif [[ $expect == software && $on_gpu == yes ]]; then
    result "$check" fail "decoded with VA-API although vainfo doesn't list $profile; see $log"
  elif (( dropped > 0 )); then
    result "$check" fail "$dropped dropped picture(s) ($expect decoding); see $log"
  elif [[ -n "$found" ]]; then
    result "$check" fail "$(wc -l <<< "$found") log problem(s), first: $(head -1 <<< "$found" | cut -c1-120)"
  elif [[ $expect == gpu ]]; then
    result "$check" pass "VA-API${engine_s:+, decode engine ${engine_s} s}; CPU ${cpu} s; 0 dropped, $late late"
  else
    result "$check" pass "software (${decoder}) as expected: the GPU lacks $profile; CPU ${cpu} s; 0 dropped, $late late"
  fi
done < redux/qa/hw-clips.tsv

# What the GPU saves: the HEVC 10-bit clip again, decoded in software.
if [[ -n "${cpu_on_gpu[hevc-10bit]:-}" ]]; then
  status=
  play "$out/hevc-10bit-software.log" "$clips/hevc-10bit.mkv" --no-hw-dec
  if [[ "$status" != 0 ]]; then
    result l2.hw.cpu fail "the software run exited with $status; see $out/hevc-10bit-software.log"
  else
    result l2.hw.cpu pass "HEVC 10-bit 1080p, 8 s: CPU ${cpu_on_gpu[hevc-10bit]} s with the GPU, ${cpu} s in software"
  fi
fi
