#!/usr/bin/env bash
# Generate the test media library used for screenshots and manual testing.
# Everything is synthesized with ffmpeg, so there are no licensing questions. The layout
# mirrors the content shown in the Figma frames (a "The Wand" season, a "My Songs" album).
#
#   redux/dev.sh run redux/tools/make-media.sh [output-dir]     (default: build/media)
set -euo pipefail

out="${1:-build/media}"
ff=(ffmpeg -hide_banner -loglevel error -y)

show="$out/Videos/Shows/The Wand/S01"
songs="$out/Music/My Songs"
mkdir -p "$show" "$songs" "$out/Videos/Clips"

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

# Album cover: a dark guitar-ish motif like the Figma music frame.
cover="$songs/cover.png"
"${ff[@]}" -f lavfi -i "color=c=0x0a0a0a:size=1000x1000" \
  -vf "drawbox=x=0:y=380:w=1000:h=4:color=0x6b6b6b@0.8:t=fill,drawbox=x=0:y=420:w=1000:h=3:color=0x6b6b6b@0.7:t=fill,drawbox=x=0:y=460:w=1000:h=2:color=0x6b6b6b@0.6:t=fill,drawbox=x=300:y=300:w=400:h=400:color=0x373737:t=6" \
  -frames:v 1 "$cover"

# Songs: varied loudness envelopes so the waveform seek bar has something to draw.
i=0
for title in untangle drift "lost aura" queue "cone zone"; do
  i=$((i + 1))
  "${ff[@]}" -f lavfi -i "sine=frequency=$((220 + i * 55)):duration=100" \
    -f lavfi -i "anoisesrc=color=pink:amplitude=0.15:duration=100" -i "$cover" \
    -filter_complex "[0][1]amix=inputs=2,volume='0.3+0.7*abs(sin(t*$i/7))':eval=frame[a]" \
    -map "[a]" -map 2 -c:a libmp3lame -b:a 128k -c:v mjpeg -disposition:v attached_pic \
    -metadata title="$title" -metadata artist="juxtopposed" -metadata album="My Songs" \
    -metadata track="$i" -metadata genre="Ambient" \
    "$songs/$(printf '%02d' $i) - $title.mp3"
done

# Playlist files named like the ones in the Figma playlist panel.
{
  echo "#EXTM3U"
  for f in "$show"/The_Wand_S01E0[1-5].mp4; do echo "../Videos/Shows/The Wand/S01/$(basename "$f")"; done
} > "$out/Music/Anime to Watch.m3u"
{ echo "#EXTM3U"; for f in "$songs"/*.mp3; do echo "My Songs/$(basename "$f")"; done; } > "$out/Music/Cool Songs.m3u"

find "$out" -type f | sort | sed "s|^$out/||"
du -sh "$out"
