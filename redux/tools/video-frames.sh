#!/usr/bin/env bash
# Extract the picked reference frames from the designer's video at full resolution. The picks
# list is committed, so anyone with the video can regenerate the same frames; the frames
# themselves stay out of git.
#
#   redux/dev.sh run redux/tools/video-frames.sh [video] [picks]
#     video  default redux/design/source/video.mp4
#     picks  default redux/design/frame-picks.tsv
#
# picks is tab-separated: time (m:ss or m:ss.s), slug, caption, and an optional crop in source
# pixels (WxH+X+Y, e.g. 480x120+1400+950) for close-ups. Lines starting with # are skipped.
# Each row writes redux/design/source/video-frames/MMSS-<slug>.jpg; index.tsv lists them all.
set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
video="${1:-redux/design/source/video.mp4}"
picks="${2:-redux/design/frame-picks.tsv}"
out=redux/design/source/video-frames
im=$(command -v magick || command -v convert)

[[ -f "$video" ]] || { echo "no video at $video" >&2; exit 1; }
[[ -f "$picks" ]] || { echo "no picks list at $picks" >&2; exit 1; }
rm -rf "$out"
mkdir -p "$out"
tmp=$(mktemp --suffix=.png)
trap 'rm -f "$tmp"' EXIT

printf 'file\ttime\tcaption\n' > "$out/index.tsv"
while IFS=$'\t' read -r time slug caption crop; do
  [[ -z "$time" || "$time" == \#* ]] && continue
  [[ "$slug" =~ ^[a-z0-9-]+$ ]] || { echo "bad slug '$slug' at $time" >&2; exit 1; }
  sec=$(awk -F: '{ print $1 * 60 + $2 }' <<< "$time")
  name=$(awk -v s="$sec" -v slug="$slug" 'BEGIN { s = int(s); printf "%02d%02d-%s.jpg", s / 60, s % 60, slug }')
  [[ -e "$out/$name" ]] && { echo "duplicate frame name $name" >&2; exit 1; }

  ffmpeg -nostdin -v error -ss "$sec" -i "$video" -frames:v 1 -y "$tmp"
  if [[ -n "${crop:-}" ]]; then
    "$im" "$tmp" -crop "$crop" +repage -quality 85 "$out/$name"
  else
    "$im" "$tmp" -quality 85 "$out/$name"
  fi
  printf '%s\t%s\t%s\n' "$name" "$time" "$caption" >> "$out/index.tsv"
done < "$picks"

echo "$(($(wc -l < "$out/index.tsv") - 1)) frames, $(du -sh "$out" | cut -f1) in $out"
