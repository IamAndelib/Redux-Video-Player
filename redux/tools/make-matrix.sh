#!/usr/bin/env bash
# Generate the codec/format matrix: short synthetic files covering the containers, video codecs, audio codecs,
# subtitle formats and archives Redux Video Player must play (M0.6). redux/tools/play-matrix.sh plays them all.
#
#   redux/dev.sh run redux/tools/make-matrix.sh [output-dir]     (default: build/matrix)
#
# Each case is one line in the table below: name (the file written), what it checks, then ffmpeg output options.
# Every case uses the same 2-second test inputs ($V video, $A stereo audio, $A6 5.1 audio). Formats ffmpeg can't
# synthesize (VC-1, PGS/VobSub/DVB bitmap subtitles, Dolby Vision, RAR) need real samples (gap G22).
set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
out="${1:-build/matrix}"
# Start clean, but keep real/: fetch-samples.sh downloads the FATE samples there, and play-matrix.sh calls this
# script when the synthetic files are missing, which would otherwise delete samples fetched earlier.
mkdir -p "$out"
find "$out" -mindepth 1 -maxdepth 1 ! -name real -exec rm -rf {} +
ff=(ffmpeg -hide_banner -loglevel error -nostdin -y)
export SVT_LOG=1   # keep the SVT-AV1 encoder quiet
V=(-f lavfi -i "testsrc2=size=640x360:rate=25:duration=2")
A=(-f lavfi -i "sine=frequency=440:duration=2:sample_rate=48000,aformat=channel_layouts=stereo")
A6=(-f lavfi -i "sine=frequency=330:duration=2:sample_rate=48000,aformat=channel_layouts=5.1")
hdr=(-x265-params "log-level=error:colorprim=bt2020:transfer=smpte2084:colormatrix=bt2020nc:hdr10=1")
x264=(-c:v libx264 -preset ultrafast -pix_fmt yuv420p)

# Subtitle sources: SubRip, ASS (styled) and WebVTT.
cat > "$out/.subs.srt" <<'EOF'
1
00:00:00,200 --> 00:00:01,800
Matrix subtitle line
EOF
cat > "$out/.subs.ass" <<'EOF'
[Script Info]
ScriptType: v4.00+
PlayResX: 640
PlayResY: 360

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,DejaVu Sans,28,&H00FFFFFF,&H000000FF,&H00000000,&H64000000,0,0,0,0,100,100,0,0,1,2,1,2,10,10,20,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,0:00:00.20,0:00:01.80,Default,,0,0,0,,{\b1}Styled{\b0} ASS line
EOF
cat > "$out/.subs.vtt" <<'EOF'
WEBVTT

00:00:00.200 --> 00:00:01.800
WebVTT line
EOF

case_() { # case_ <file> <ffmpeg args...> (inputs come first in the args)
  local file="$1"; shift
  "${ff[@]}" "$@" "$out/$file" || { echo "FAILED to generate $file" >&2; exit 1; }
}

# Video codecs in their usual containers.
case_ h264-aac.mp4            "${V[@]}" "${A[@]}" "${x264[@]}" -c:a aac
case_ h264-10bit-flac.mkv     "${V[@]}" "${A[@]}" -c:v libx264 -preset ultrafast -pix_fmt yuv420p10le -c:a flac
case_ hevc-ac3.mkv            "${V[@]}" "${A6[@]}" -c:v libx265 -preset ultrafast -x265-params log-level=error -c:a ac3
case_ hevc-10bit-hdr10-eac3.mp4 "${V[@]}" "${A6[@]}" -c:v libx265 -preset ultrafast "${hdr[@]}" -pix_fmt yuv420p10le -tag:v hvc1 -c:a eac3
case_ av1-opus.mkv            "${V[@]}" "${A[@]}" -c:v libsvtav1 -preset 12 -c:a libopus
case_ av1-opus.webm           "${V[@]}" "${A[@]}" -c:v libaom-av1 -cpu-used 8 -row-mt 1 -c:a libopus
case_ vp9-opus.webm           "${V[@]}" "${A[@]}" -c:v libvpx-vp9 -deadline realtime -cpu-used 8 -c:a libopus
case_ vp8-vorbis.webm         "${V[@]}" "${A[@]}" -c:v libvpx -deadline realtime -cpu-used 8 -c:a libvorbis
case_ mpeg2-mp2.mpg           "${V[@]}" "${A[@]}" -c:v mpeg2video -c:a mp2 -f vob
case_ mpeg1-mp2.mpg           "${V[@]}" "${A[@]}" -c:v mpeg1video -c:a mp2
case_ mpeg2-ac3.ts            "${V[@]}" "${A6[@]}" -c:v mpeg2video -c:a ac3
case_ h264-ac3.m2ts           "${V[@]}" "${A6[@]}" "${x264[@]}" -c:a ac3 -f mpegts -mpegts_m2ts_mode 1
case_ mpeg4-mp3.avi           "${V[@]}" "${A[@]}" -c:v mpeg4 -c:a libmp3lame
case_ msmpeg4-mp3.avi         "${V[@]}" "${A[@]}" -c:v msmpeg4 -c:a libmp3lame
case_ wmv2-wma.wmv            "${V[@]}" "${A[@]}" -c:v wmv2 -c:a wmav2
case_ mjpeg-pcm.mov           "${V[@]}" "${A[@]}" -c:v mjpeg -q:v 5 -c:a pcm_s16le
case_ prores-pcm24.mov        "${V[@]}" "${A[@]}" -c:v prores_ks -profile:v 0 -c:a pcm_s24le
case_ dnxhr-pcm.mov           "${V[@]}" "${A[@]}" -c:v dnxhd -profile:v dnxhr_lb -pix_fmt yuv422p -c:a pcm_s16le
case_ ffv1-flac.mkv           "${V[@]}" "${A[@]}" -c:v ffv1 -c:a flac
case_ theora-vorbis.ogv       "${V[@]}" "${A[@]}" -c:v libtheora -c:a libvorbis
case_ h263-aac.3gp            -f lavfi -i "testsrc2=size=352x288:rate=25:duration=2" "${A[@]}" -c:v h263 -c:a aac -ar 16000 -ac 1
case_ flv1-mp3.flv            "${V[@]}" "${A[@]}" -c:v flv -c:a libmp3lame -ar 44100
case_ h264-alac.mov           "${V[@]}" "${A[@]}" "${x264[@]}" -c:a alac
case_ hevc-aac.mp4            "${V[@]}" "${A[@]}" -c:v libx265 -preset ultrafast -x265-params log-level=error -tag:v hvc1 -c:a aac

# Audio codecs (audio-only files still play).
case_ dts-5.1.mka             "${A6[@]}" -c:a dca -strict -2
case_ truehd-5.1.mka          "${A6[@]}" -c:a truehd -strict -2
case_ eac3.mka                "${A6[@]}" -c:a eac3
case_ flac.flac               "${A[@]}" -c:a flac
case_ alac.m4a                "${A[@]}" -c:a alac
case_ aac.m4a                 "${A[@]}" -c:a aac
case_ opus.opus               "${A[@]}" -c:a libopus
case_ vorbis.ogg              "${A[@]}" -c:a libvorbis
case_ mp3.mp3                 "${A[@]}" -c:a libmp3lame
case_ mp2.mp2                 "${A[@]}" -c:a mp2
case_ wma.wma                 "${A[@]}" -c:a wmav2
case_ pcm.wav                 "${A[@]}" -c:a pcm_s16le
case_ pcm.aiff                "${A[@]}" -c:a pcm_s16be
case_ wavpack.wv              "${A[@]}" -c:a wavpack
case_ tta.tta                 "${A[@]}" -c:a tta

# Subtitles: embedded text tracks, multiple tracks with languages, and external files next to the video.
case_ subs-srt-embedded.mkv   "${V[@]}" "${A[@]}" -i "$out/.subs.srt" -map 0 -map 1 -map 2 "${x264[@]}" -c:a aac -c:s subrip
case_ subs-ass-embedded.mkv   "${V[@]}" "${A[@]}" -i "$out/.subs.ass" -map 0 -map 1 -map 2 "${x264[@]}" -c:a aac -c:s ass
case_ subs-movtext.mp4        "${V[@]}" "${A[@]}" -i "$out/.subs.srt" -map 0 -map 1 -map 2 "${x264[@]}" -c:a aac -c:s mov_text
case_ subs-webvtt.webm        "${V[@]}" "${A[@]}" -i "$out/.subs.vtt" -map 0 -map 1 -map 2 -c:v libvpx-vp9 -deadline realtime -cpu-used 8 -c:a libopus -c:s webvtt
case_ multitrack-2audio-2subs.mkv "${V[@]}" "${A[@]}" "${A6[@]}" -i "$out/.subs.srt" -i "$out/.subs.ass" \
  -map 0 -map 1 -map 2 -map 3 -map 4 "${x264[@]}" -c:a:0 aac -c:a:1 ac3 -c:s:0 subrip -c:s:1 ass \
  -metadata:s:a:0 language=eng -metadata:s:a:1 language=jpn -metadata:s:s:0 language=eng -metadata:s:s:1 language=jpn
for ext in srt ass vtt; do
  case_ "subs-external-$ext.mp4" "${V[@]}" "${A[@]}" "${x264[@]}" -c:a aac
  cp "$out/.subs.$ext" "$out/subs-external-$ext.$ext"
done

# Chapters.
printf ';FFMETADATA1\n[CHAPTER]\nTIMEBASE=1/1000\nSTART=0\nEND=1000\ntitle=Opening\n[CHAPTER]\nTIMEBASE=1/1000\nSTART=1000\nEND=2000\ntitle=Ending\n' > "$out/.chapters.txt"
case_ chapters.mkv            "${V[@]}" "${A[@]}" -i "$out/.chapters.txt" -map 0 -map 1 -map_metadata 2 -map_chapters 2 "${x264[@]}" -c:a aac

# Files inside archives (zip stored and deflated, 7z).
(cd "$out" && zip -q -0 archive-stored.zip h264-aac.mp4 && zip -q -9 archive-deflated.zip hevc-ac3.mkv \
  && 7z a -bd -bso0 archive.7z vp9-opus.webm)

rm -f "$out"/.subs.* "$out/.chapters.txt"
echo "$(find "$out" -maxdepth 1 -type f | wc -l) files, $(du -sh "$out" | cut -f1) in $out"
