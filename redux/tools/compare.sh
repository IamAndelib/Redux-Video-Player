#!/usr/bin/env bash
# Compare build/shots/<scene>.png with the matching Figma frame render and write an HTML
# report (side by side, plus a diff image and an RMSE score; lower is closer).
# Scene to frame mapping: redux/tools/shots.tsv. References: redux/design/source/frames/
# (from redux/tools/figma-export.py). Run inside the dev container:
#
#   redux/dev.sh run redux/tools/compare.sh
set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
shots=build/shots
refs=redux/design/source/frames
report="$shots/report.html"
mkdir -p "$shots/compare"

rows=""
while IFS=$'\t' read -r scene frame what; do
  [[ -z "$scene" || "$scene" == \#* ]] && continue
  shot="$shots/$scene.png"
  ref="$(ls "$refs"/*--"${frame/:/-}".png 2>/dev/null | head -n1 || true)"
  if [[ ! -f "$shot" || -z "$ref" ]]; then
    rows+="<tr><td>$scene</td><td colspan=3>missing $([[ -f $shot ]] || echo "screenshot ")$([[ -n $ref ]] || echo "Figma reference $frame")</td></tr>"
    continue
  fi
  ref_scaled="$shots/compare/$scene.ref.png"
  magick "$ref" -resize 1920x1080! "$ref_scaled"
  # compare exits 1 when images differ; that's the normal case here.
  rmse="$(magick compare -metric RMSE "$shot" "$ref_scaled" "$shots/compare/$scene.diff.png" 2>&1 >/dev/null || true)"
  magick "$shot" "$ref_scaled" +append -resize 50% "$shots/compare/$scene.side.png"
  rows+="<tr><td><b>$scene</b><br><small>$what<br>Figma $frame</small></td><td>${rmse#* }</td>"
  rows+="<td><a href=\"compare/$scene.side.png\"><img src=\"compare/$scene.side.png\" width=640></a><br><small>left: build, right: Figma</small></td>"
  rows+="<td><a href=\"compare/$scene.diff.png\"><img src=\"compare/$scene.diff.png\" width=320></a></td></tr>"
done < redux/tools/shots.tsv

cat > "$report" <<HTML
<!doctype html><meta charset=utf-8><title>VLC Redux visual diff</title>
<style>body{font:14px system-ui;background:#111;color:#ddd;margin:24px}td{vertical-align:top;padding:8px;border-bottom:1px solid #333}img{border:1px solid #333}a{color:#d37918}</style>
<h1>VLC Redux vs Figma</h1><p>Generated $(date -u +%F\ %TZ) from $(git rev-parse --short HEAD). RMSE: normalized root-mean-square difference (0 = identical).</p>
<table><tr><th>Scene</th><th>RMSE</th><th>Side by side</th><th>Diff</th></tr>$rows</table>
HTML
echo "wrote $report"
