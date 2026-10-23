#!/usr/bin/env bash
# Play every file of the codec/format matrix headless and check that VLC opens it and finds a decoder for each
# kind of stream it contains (video, audio, subtitles). Exits non-zero if any file fails (M0.6).
#
#   redux/dev.sh run redux/tools/play-matrix.sh [matrix-dir]     (default: build/matrix)
#   VLC_CMD="<command>" redux/tools/play-matrix.sh               (another player, e.g. the Flatpak:
#                                                                  redux/tools/flatpak.sh matrix)
#
# Two sets are played:
#   <matrix-dir>/*       synthetic files from redux/tools/make-matrix.sh (generated if missing)
#   <matrix-dir>/real/*  real-world samples from redux/tools/fetch-samples.sh (FFmpeg's FATE suite), when present;
#                        subtitle-only samples are loaded with --sub-file over one of the synthetic videos.
# Expected streams come from ffprobe; files inside archives are expected to have video and audio, and
# subs-external-* files expect the subtitle file next to them to be loaded. Writes <matrix-dir>/report.tsv and
# keeps each file's VLC log in <matrix-dir>/logs/.
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
dir="${1:-build/matrix}"
# The expected streams come from ffprobe; without it every stream check would silently pass.
command -v ffprobe >/dev/null || { echo "ffprobe not found (install ffmpeg or run inside the dev container)" >&2; exit 1; }
if [[ -n "${VLC_CMD:-}" ]]; then
  read -ra vlccmd <<< "$VLC_CMD"
else
  vlc="${BUILD_DIR:-build/meson}/bin/vlc-static"
  [[ -x "$vlc" ]] || { echo "no player at $vlc; run redux/tools/build.sh first" >&2; exit 1; }
  vlccmd=("$vlc")
fi
[[ -f "$dir/h264-aac.mp4" ]] || redux/tools/make-matrix.sh "$dir" >/dev/null
mkdir -p "$dir/logs"
report="$dir/report.tsv"
printf 'file\tdemux\tvideo\taudio\tsubtitles\tresult\n' > "$report"
play=("${vlccmd[@]}" -I dummy -vv --aout=dummy --vout=dummy --no-media-library --play-and-exit --sub-track=0 --stop-time=5)
pass=0 fail=0

pick() { grep -m1 -oE "using $1 module \"[^\"]+\"" "$2" | sed 's/.*"\(.*\)"/\1/'; }

check() { # check <label> <wanted stream kinds> <vlc args...>
  local label="$1" want="$2"; shift 2
  local log="$dir/logs/${label//\//--}.log" code demux video audio spu result problems=()
  timeout 30 "${play[@]}" "$@" > "$log" 2>&1
  code=$?
  demux="$(pick demux "$log")"; video="$(pick 'video decoder' "$log")"; audio="$(pick 'audio decoder' "$log")"
  spu="$(pick 'spu decoder' "$log")"
  # The dummy audio output accepts AC-3, E-AC-3, DTS and TrueHD as passthrough, so VLC hands them to the "spdif"
  # pseudo-decoder and never decodes them. Play those again with FFmpeg's decoder preferred to prove they decode.
  if [[ "$audio" == spdif ]]; then
    timeout 30 "${play[@]}" --codec=avcodec,any "$@" > "$log.decode" 2>&1
    audio="$(pick 'audio decoder' "$log.decode")"
    [[ -n "$audio" ]] && audio+=" (spdif)"
  fi

  [[ $code -eq 0 ]] || problems+=("exit $code")
  [[ -n "$demux" ]] || problems+=("no demux")
  [[ "$want" != *video* || -n "$video" ]] || problems+=("no video decoder")
  [[ "$want" != *audio* || -n "$audio" ]] || problems+=("no audio decoder")
  [[ "$want" != *subtitle* || -n "$spu" ]] || problems+=("no subtitle decoder")
  # Only real decoder failures count; hardware probes (e.g. "vaapi ... profile is not supported") fall back to software.
  grep -qE "Codec \`.*' \(.*\) is not supported|no suitable decoder module" "$log" && problems+=("unsupported codec in log")

  if [[ ${#problems[@]} -eq 0 ]]; then result=ok; pass=$((pass + 1)); else result="FAIL: ${problems[*]}"; fail=$((fail + 1)); fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$label" "${demux:--}" "${video:--}" "${audio:--}" "${spu:--}" "$result" >> "$report"
}

streams() { ffprobe -v error -show_entries stream=codec_type -of csv=p=0 "$1" 2>/dev/null | sort -u | tr '\n' ' '; }

# Synthetic files.
for f in "$dir"/*; do
  [[ -f "$f" ]] || continue
  name="$(basename "$f")"
  case "$name" in report.tsv|*.srt|*.ass|*.vtt) continue ;; esac
  case "$name" in *.zip|*.7z) want="video audio" ;; *) want="$(streams "$f")" ;; esac
  [[ "$name" == subs-external-* ]] && want+=" subtitle"
  check "$name" "$want" "$f"
done

# Real-world samples (kind from samples.tsv). A missing sample fails: a matrix that silently shrinks proves less.
while IFS=$'\t' read -r path kind _; do
  [[ -z "$path" || "$path" == \#* ]] && continue
  f="$dir/real/${path//\//--}"
  if [[ ! -f "$f" ]]; then
    printf '%s\t-\t-\t-\t-\t%s\n' "real/${path}" "FAIL: sample missing (run redux/tools/fetch-samples.sh)" >> "$report"
    fail=$((fail + 1))
    continue
  fi
  case "$kind" in
    media) check "real/${path}" "$(streams "$f")" "$f" ;;
    sub) check "real/${path}" "video audio subtitle" "$dir/h264-aac.mp4" --sub-file="$f" ;;
  esac
done < redux/tools/samples.tsv

column -t -s $'\t' "$report"
echo
echo "$pass passed, $fail failed (report: $report)"
[[ $fail -eq 0 && $pass -gt 0 ]]
