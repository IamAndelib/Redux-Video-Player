#!/usr/bin/env bash
# Download the real-world samples listed in redux/tools/samples.tsv (from FFmpeg's FATE suite) into
# build/matrix/real/, keeping the FATE folder in the file name. Files already present are kept; a sha256 pinned in
# samples.tsv is checked, an empty one is printed so it can be pinned. Runs on the host or in the container.
#
#   redux/tools/fetch-samples.sh [output-dir]      (default: build/matrix/real)
set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
out="${1:-build/matrix/real}"
base=https://fate-suite.ffmpeg.org
mkdir -p "$out"
bad=0
while IFS=$'\t' read -r path kind sha; do
  [[ -z "$path" || "$path" == \#* ]] && continue
  file="$out/${path//\//--}"
  if [[ ! -s "$file" ]]; then
    curl -fsSL --retry 3 --retry-delay 3 -o "$file.part" "$base/$path" && mv "$file.part" "$file" \
      || { echo "FAILED to download $path" >&2; rm -f "$file.part"; bad=1; continue; }
  fi
  got="$(sha256sum "$file" | cut -d' ' -f1)"
  if [[ -z "$sha" ]]; then
    echo "unpinned $path $got"
  elif [[ "$got" != "$sha" ]]; then
    echo "CHECKSUM MISMATCH $path" >&2; bad=1
  fi
done < redux/tools/samples.tsv
echo "$(find "$out" -type f | wc -l) samples, $(du -sh "$out" | cut -f1) in $out"
exit $bad
