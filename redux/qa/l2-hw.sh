#!/usr/bin/env bash
# QA check: hardware playback (Q0.8, redux/QA.md), run by redux/tools/qa.sh (L2) inside the dev container. On a machine
# with a GPU, every clip in redux/qa/hw-clips.tsv plays in the headless KDE session (redux/tools/kwin-session.sh) with
# the GPU's OpenGL, as on a desktop:
#   l2.hw.<clip>  decoded on the GPU (VA-API) where vainfo lists the clip's profile, else in software (with several
#                 GPUs, where only some list it, either); either way no dropped picture, no log problem, a clean exit
#   l2.hw.cpu     the HEVC 10-bit clip's CPU time as played and with --no-hw-dec (reported, not gated: it's noisy)
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
clip_file() { # clip_file <name> <FFmpeg options>: the cached clip, named after its options so a change remakes it
  echo "$clips/$1-$(sha1sum <<< "$2" | cut -c1-8).mkv"
}
clip_list() { grep -v -e '^#' -e '^$' redux/qa/hw-clips.tsv; }

if [[ "${1:-}" != --in-session ]]; then
  rm -f "$results"
  finish() {
    cat "$results" >> "$QA_RESULTS"
    while IFS=$'\t' read -r check status detail; do echo "  $status  $check${detail:+  ($detail)}"; done < "$results"
    exit 0
  }
  nodes=(/dev/dri/renderD*)
  if [[ ! -e "${nodes[0]}" ]]; then
    result l2.hw skip "no DRM render node, so no GPU to test (G27)"; finish
  fi
  # Every GPU's decode profiles: the player decodes on the one KWin renders with, which this script can't tell.
  rm -f "$out"/vainfo-*.txt
  for node in "${nodes[@]}"; do
    vainfo --display drm --device "$node" > "$out/vainfo-${node##*/}.txt" 2>&1
  done
  if ! grep -q 'VAEntrypointVLD' "$out"/vainfo-*.txt; then
    result l2.hw skip "no VA-API decoder on ${nodes[*]}; see $out/vainfo-*.txt"; finish
  fi

  # 8 s of 1080p30 test pattern per clip, made once (never the 2 s matrix clips: too short to judge playback).
  mkdir -p "$clips"
  while IFS=$'\t' read -r name _ options; do
    file="$(clip_file "$name" "$options")"
    [[ -s "$file" ]] && continue
    read -ra options <<< "$options"
    ffmpeg -nostdin -hide_banner -loglevel error -y -f lavfi -i testsrc2=size=1920x1080:rate=30:duration=8 \
      "${options[@]}" "$file.tmp.mkv" > "$out/encode-$name.log" 2>&1 && mv "$file.tmp.mkv" "$file"
  done < <(clip_list)

  # Up to 60 s per play (10 clips and the software run), more than kwin-session's default.
  REDUX_SESSION_GPU=1 KWIN_SESSION_TIMEOUT="${KWIN_SESSION_TIMEOUT:-900}" \
    redux/tools/kwin-session.sh "$0" --in-session > "$out/session.log" 2>&1
  status=$?
  # A session cut short mustn't pass on the clips it got to.
  while IFS=$'\t' read -r name _; do
    grep -q "^l2\.hw\.$name"$'\t' "$results" 2>/dev/null ||
      result "l2.hw.$name" fail "not played: the KWin session ended early (exit $status); see $out/session.log"
  done < <(clip_list)
  finish
fi

# --- inside the session ----------------------------------------------------------------------------------------
source redux/qa/lib/log-problems.sh
vlc="$root/${BUILD_DIR:-build/meson}/bin/vlc-static"
export HOME="$out/profile"
rm -rf "$HOME" && mkdir -p "$HOME"
tick="$(getconf CLK_TCK)"

# The GPU's video engine time (ns) used by a process so far, from the kernel's DRM usage stats
# (docs.kernel.org/gpu/drm-usage-stats.html): amdgpu's drm-engine-dec, or drm-engine-enc where newer VCNs decode on the
# unified queue (the player never encodes); i915's drm-engine-video. A client's fds count once (drm-client-id).
# amdgpu lists only engines a client has used, so any engine line with no video one means 0; empty when the driver
# reports no engine time at all (e.g. Xe, NVIDIA), and the log is then the only evidence.
engine_ns() {
  awk 'FNR == 1 { client = FILENAME }
       /^drm-client-id:/ { client = $2 }
       /^drm-engine-/ { seen = 1 }
       /^drm-engine-(dec|enc|video):/ { if ($2 > used[client]) used[client] = $2 }
       END { if (seen) { for (c in used) sum += used[c]; print sum + 0 } }' /proc/"$1"/fdinfo/* 2>/dev/null
}

# play <log> <clip> [vlc option…]: plays the clip to its end, then sets: status (the exit status, or "timeout"),
# engine (ns, or empty), cpu (s).
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

gpus="$(ls "$out"/vainfo-*.txt | wc -l)"
declare -A played_cpu played_on
while IFS=$'\t' read -r name profile options; do
  check="l2.hw.$name"
  file="$(clip_file "$name" "$options")"
  if [[ ! -s "$file" ]]; then
    result "$check" fail "FFmpeg couldn't make the clip; see $out/encode-$name.log"; continue
  fi
  listing="$(grep -lE "^[[:space:]]*$profile[[:space:]]*:[[:space:]]*VAEntrypointVLD" "$out"/vainfo-*.txt | wc -l)"
  if (( listing == gpus )); then expect=gpu; elif (( listing == 0 )); then expect=software; else expect=either; fi
  log="$out/$name.log"
  status=
  play "$log" "$file"

  on_gpu=no
  grep -q 'vaapi generic: Using ' "$log" && grep -q 'using glinterop module "glinterop_vaapi"' "$log" && on_gpu=yes
  dropped="$(grep -c 'picture is too late to be displayed' "$log")"   # one line per lost picture
  late="$(grep -c 'picture displayed late' "$log")"
  decoder="$(grep -o 'using video decoder module "[^"]*"' "$log" | tail -1 | cut -d'"' -f2)"
  found="$(problems "$log")"
  # Falling back means VLC first probed the GPU and logged why it can't ("profile(32) is not supported",
  # "avcodec_get_hw_frames_parameters failed"): an error only where the GPU was expected to decode.
  [[ $expect != gpu ]] && found="$(grep -v '^vaapi generic error: ' <<< "$found")"
  [[ -n "$found" ]] && printf '%s\n' "$found" > "$out/$name.problems"
  engine_s="${engine:+$(awk -v n="$engine" 'BEGIN { printf "%.1f", n / 1e9 }')}"
  played_cpu[$name]="$cpu"; played_on[$name]="$on_gpu"

  if [[ "$status" != 0 ]]; then
    result "$check" fail "the player exited with $status; see $log"
  elif [[ $expect == gpu && $on_gpu == no ]]; then
    result "$check" fail "decoded in software (${decoder:-no decoder}), but vainfo lists $profile; see $log"
  elif [[ $on_gpu == yes && "$engine" == 0 ]]; then
    result "$check" fail "VLC reports VA-API, but the GPU's decode engine stayed idle; see $log"
  elif [[ $expect == software && $on_gpu == yes ]]; then
    result "$check" fail "decoded with VA-API although vainfo doesn't list $profile; see $log"
  elif (( dropped > 0 )); then
    result "$check" fail "$dropped dropped picture(s) ($expect decoding); see $log"
  elif [[ -n "$found" ]]; then
    result "$check" fail "$(wc -l <<< "$found") log problem(s), first: $(head -1 <<< "$found" | cut -c1-120)"
  elif [[ $on_gpu == yes ]]; then
    result "$check" pass "VA-API${engine_s:+, decode engine ${engine_s} s}; CPU ${cpu} s; 0 dropped, $late late"
  elif [[ $expect == software ]]; then
    result "$check" pass "software (${decoder}) as expected: the GPU lacks $profile; CPU ${cpu} s; 0 dropped, $late late"
  else
    result "$check" pass "software (${decoder}): only some GPUs list $profile; CPU ${cpu} s; 0 dropped, $late late"
  fi
done < <(clip_list)

# What the GPU saves: the HEVC 10-bit clip again, decoded in software.
if [[ -n "${played_cpu[hevc-10bit]:-}" ]]; then
  status=
  play "$out/hevc-10bit-software.log" "$(clip_file hevc-10bit "$(clip_list | awk -F'\t' '$1 == "hevc-10bit" { print $3 }')")" \
    --no-hw-dec
  if [[ "$status" != 0 ]]; then
    result l2.hw.cpu fail "the software run exited with $status; see $out/hevc-10bit-software.log"
  else
    how=software; [[ ${played_on[hevc-10bit]} == yes ]] && how="the GPU"
    result l2.hw.cpu pass "HEVC 10-bit 1080p, 8 s: CPU ${played_cpu[hevc-10bit]} s as played (on $how), ${cpu} s with --no-hw-dec"
  fi
fi
