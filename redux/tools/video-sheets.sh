#!/usr/bin/env bash
# Screen every moment of the designer's video: one frame every STEP seconds tiled into labelled
# contact sheets, plus a list of scene cuts. Reviewing the sheets is how reference frames are
# picked for redux/design/brief.md (procedure: redux/milestones/M0.4-video-brief.md).
#
#   redux/dev.sh run redux/tools/video-sheets.sh [video]     (default redux/design/source/video.mp4)
#
# Output in redux/design/source/video-work/ (git-ignored, rebuilt on every run):
#   info.txt     duration, size and frame rate
#   cov/         one 640 px frame every STEP seconds, named by second: t0000.jpg, t0002.jpg …
#   sheets/      4x4 contact sheets, each tile labelled mm:ss: sheet-0000-0030.jpg …
#   scenes.tsv   seconds and mm:ss of every scene cut (change score above SCENE)
# STEP defaults to 2 seconds and SCENE to 0.25.
set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
video="${1:-redux/design/source/video.mp4}"
out=redux/design/source/video-work
step="${STEP:-2}"
scene="${SCENE:-0.25}"

[[ -f "$video" ]] || { echo "no video at $video" >&2; exit 1; }
rm -rf "$out"
mkdir -p "$out/cov" "$out/sheets"

mmss() { printf '%02d:%02d' $(($1 / 60)) $(($1 % 60)); }

ffprobe -v error -show_entries format=duration:stream=codec_type,width,height,r_frame_rate \
  -of default=nw=1 "$video" > "$out/info.txt"

# Coverage frames: the first frame at or after every multiple of step, so frame n (1-based)
# is at (n-1)*step seconds.
ffmpeg -v error -i "$video" -an \
  -vf "select='isnan(prev_selected_t)+gte(t-prev_selected_t\,$step-0.001)',scale=640:-2" \
  -fps_mode vfr -q:v 4 "$out/cov/f%05d.jpg"
for f in "$out"/cov/f*.jpg; do
  n=$((10#$(basename "$f" .jpg | tr -d f)))
  mv "$f" "$out/cov/t$(printf %04d $(((n - 1) * step))).jpg"
done

# Contact sheets of 16 frames each. ImageMagick's default label font often isn't installed,
# so name a real one.
font=$(fc-match -f '%{file}' sans 2>/dev/null || true)
mapfile -t frames < <(find "$out/cov" -name 't*.jpg' | sort)
for ((i = 0; i < ${#frames[@]}; i += 16)); do
  args=()
  for f in "${frames[@]:i:16}"; do
    s=$((10#$(basename "$f" .jpg | tr -d t)))
    args+=(-label "$(mmss "$s")" "$f")
  done
  first=$(basename "${frames[i]}" .jpg | tr -d t)
  last=$(basename "${args[-1]}" .jpg | tr -d t)
  montage ${font:+-font "$font"} "${args[@]}" -tile 4x -geometry 400x225+4+4 -pointsize 20 \
    -background '#202020' -fill white "$out/sheets/sheet-$first-$last.jpg"
done

# Scene cuts, detected on a downscaled copy for speed.
ffmpeg -v info -i "$video" -vf "scale=480:-2,select='gt(scene,$scene)',showinfo" -an -f null - 2>&1 \
  | { grep -o 'pts_time:[0-9.]*' || true; } | cut -d: -f2 \
  | awk '{ s = int($1); printf "%.1f\t%02d:%02d\n", $1, s / 60, s % 60 }' > "$out/scenes.tsv"

echo "$(find "$out/cov" -name 't*.jpg' | wc -l) frames, $(find "$out/sheets" -name '*.jpg' | wc -l) sheets," \
  "$(wc -l < "$out/scenes.tsv") scene cuts in $out"
