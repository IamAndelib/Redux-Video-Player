#!/usr/bin/env bash
# Transcribe a video with AI-Video-Transcriber inside a Podman container.
# Usage: redux/tools/transcriber/transcribe.sh <url> [transcribe.py options]
# Output lands in redux/design/transcript/.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(git -C "$here" rev-parse --show-toplevel)"
image="localhost/vlc-redux-transcriber:latest"
out="$repo/redux/design/transcript"

[[ $# -ge 1 ]] || { echo "usage: $0 <url> [options]" >&2; exit 1; }

if ! podman image exists "$image"; then
  podman build -t "$image" -f "$here/Containerfile" "$here"
fi

mkdir -p "$out"
exec podman run --rm \
  --userns=keep-id \
  --security-opt label=disable \
  -v vlc-redux-whisper-cache:/cache:U \
  -e HOME=/tmp \
  -v "$out:/out" \
  "$image" "$1" --output-dir /out --no-llm --no-video "${@:2}"
