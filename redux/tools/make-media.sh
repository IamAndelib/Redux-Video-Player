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

# A one-minute clip with an embedded, default ASS subtitle track (styled lines every 4 s), for subtitle checks in
# the app. The matrix files are only 2 s long, too short to pick a track by hand.
ass="$out/Videos/Clips/.subtitles.ass"
{
  printf '[Script Info]\nScriptType: v4.00+\nPlayResX: 1280\nPlayResY: 720\n\n[V4+ Styles]\n'
  printf 'Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\n'
  printf 'Style: Default,DejaVu Sans,48,&H00FFFFFF,&H000000FF,&H00000000,&H64000000,0,0,0,0,100,100,0,0,1,3,1,2,20,20,40,1\n\n'
  printf '[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n'
  for i in $(seq 0 14); do
    printf 'Dialogue: 0,0:00:%02d.00,0:00:%02d.50,Default,,0,0,0,,Subtitle line %d of 15: {\\b1}bold{\\b0} and {\\i1}italic{\\i0}\n' \
      $((i * 4)) $((i * 4 + 3)) $((i + 1))
  done
} > "$ass"
"${ff[@]}" -f lavfi -i "testsrc2=size=1280x720:rate=25:duration=60" -f lavfi -i "sine=frequency=440:duration=60" -i "$ass" \
  -map 0 -map 1 -map 2 -c:v libx264 -preset veryfast -crf 30 -pix_fmt yuv420p -c:a aac -b:a 64k -c:s ass \
  -metadata:s:s:0 language=eng -disposition:s:0 default "$out/Videos/Clips/subtitles-ass-demo.mkv"
rm "$ass"

# A one-minute clip with 3 chapters and two audio and two subtitle tracks (English and French, distinct tones and
# lines), for the track, chapter and subtitle panels (Q0.4).
tmp="$out/Videos/Clips/.tracks"
mkdir -p "$tmp"
printf ';FFMETADATA1\n' > "$tmp/chapters.txt"
for i in 0 1 2; do
  printf '[CHAPTER]\nTIMEBASE=1/1000\nSTART=%d\nEND=%d\ntitle=Chapter %d\n' $((i * 20000)) $((i * 20000 + 20000)) $((i + 1))
done >> "$tmp/chapters.txt"
for lang in en fr; do
  for i in $(seq 0 9); do
    printf '%d\n00:00:%02d,000 --> 00:00:%02d,500\n%s line %d\n\n' $((i + 1)) $((i * 6)) $((i * 6 + 4)) \
      "$([[ $lang == en ]] && echo English || echo Français)" $((i + 1))
  done > "$tmp/$lang.srt"
done
"${ff[@]}" -f lavfi -i "testsrc2=size=640x360:rate=25:duration=60" \
  -f lavfi -i "sine=frequency=440:duration=60" -f lavfi -i "sine=frequency=880:duration=60" \
  -i "$tmp/en.srt" -i "$tmp/fr.srt" -i "$tmp/chapters.txt" \
  -map 0:v -map 1:a -map 2:a -map 3:s -map 4:s -map_chapters 5 \
  -c:v libx264 -preset veryfast -crf 30 -pix_fmt yuv420p -c:a libopus -b:a 48k -c:s srt \
  -metadata:s:a:0 language=eng -metadata:s:a:0 title="English (440 Hz)" \
  -metadata:s:a:1 language=fra -metadata:s:a:1 title="Français (880 Hz)" \
  -metadata:s:s:0 language=eng -metadata:s:s:1 language=fra \
  -disposition:a:0 default -disposition:s:0 0 -disposition:s:1 0 "$out/Videos/Clips/tracks-demo.mkv"
rm -r "$tmp"

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
