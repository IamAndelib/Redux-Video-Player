#!/usr/bin/env bash
# Generate the test media library used for screenshots and manual testing.
# Everything is synthesized with ffmpeg, so there are no licensing questions. The layout
# mirrors the content shown in the Figma frames (a "The Wand" season). Codec and format coverage
# is tested separately by the M0.6 matrix; this set is for screenshots and the library UI.
#
#   redux/dev.sh run redux/tools/make-media.sh [output-dir]     (default: build/media)
set -euo pipefail

out="${1:-build/media}"
ff=(ffmpeg -hide_banner -loglevel error -y)

show="$out/Videos/Shows/The Wand/S01"
mkdir -p "$show" "$out/Videos/Clips" "$out/Audio" "$out/Playlists"

# One 1080p reference episode for player screenshots, long enough to scrub through. Its picture is
# flat gray like the video in the Figma player frames, so visual diffs measure the UI, not the video.
"${ff[@]}" -f lavfi -i "color=c=0x2c2c2c:size=1920x1080:rate=30:duration=90,drawbox=x=0:y=640:w=1920:h=440:color=0x252525:t=fill" \
  -f lavfi -i "sine=frequency=330:duration=90" \
  -c:v libx264 -preset veryfast -crf 28 -pix_fmt yuv420p -c:a aac -b:a 96k \
  -metadata title="The Wand S01E04" "$show/The_Wand_S01E04.mp4"

# The rest of the season: short 360p clips with distinct patterns, so thumbnails differ.
patterns=(smptebars rgbtestsrc testsrc yuvtestsrc smptehdbars pal75bars)
for ep in 01 02 03 05 06 07 08 09 10 11 12 13 14 15; do
  pat="${patterns[$((10#$ep % ${#patterns[@]}))]}"
  "${ff[@]}" -f lavfi -i "$pat=size=640x360:rate=25:duration=12" \
    -f lavfi -i "sine=frequency=$((200 + 10#$ep * 20)):duration=12" \
    -c:v libx264 -preset veryfast -crf 30 -pix_fmt yuv420p -c:a aac -b:a 64k \
    -metadata title="The Wand S01E$ep" "$show/The_Wand_S01E$ep.mp4"
done

# Subtitles: one matching file and one with a mismatched name, for the subtitle-matching UI.
srt=$'1\n00:00:01,000 --> 00:00:04,000\nYou\'ll never find the wand.\n\n2\n00:00:05,000 --> 00:00:08,000\nEvil, evil man. You\'ll pay for my lost aura.\n'
printf '%s' "$srt" > "$show/The_Wand_S01E04.srt"
printf '%s' "$srt" > "$show/the.wand.s01e05.EN.srt"

# A 4K HDR-tagged clip for the HDR options and video panels.
"${ff[@]}" -f lavfi -i "testsrc2=size=3840x2160:rate=24:duration=8" \
  -c:v libx265 -preset ultrafast -x265-params log-level=error:colorprim=bt2020:transfer=smpte2084:colormatrix=bt2020nc \
  -pix_fmt yuv420p10le -tag:v hvc1 "$out/Videos/Clips/hdr10_test_4k.mp4"

# One audio file with embedded cover art: audio still plays (without a music library, D14), and
# the player shows the attached picture.
cover="$out/Audio/cover.png"
"${ff[@]}" -f lavfi -i "color=c=0x0a0a0a:size=600x600" \
  -vf "drawbox=x=150:y=150:w=300:h=300:color=0x373737:t=6" -frames:v 1 "$cover"
"${ff[@]}" -f lavfi -i "sine=frequency=330:duration=30" -i "$cover" \
  -map 0 -map 1 -c:a libmp3lame -b:a 128k -c:v mjpeg -disposition:v attached_pic \
  -metadata title="untangle" -metadata artist="juxtopposed" "$out/Audio/untangle.mp3"
rm "$cover"

# A user playlist named like the one in the Figma playlist panel.
{
  echo "#EXTM3U"
  for f in "$show"/The_Wand_S01E0[1-5].mp4; do echo "../Videos/Shows/The Wand/S01/$(basename "$f")"; done
} > "$out/Playlists/Anime to Watch.m3u"

find "$out" -type f | sort | sed "s|^$out/||"
du -sh "$out"
