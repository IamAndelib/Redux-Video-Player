#!/usr/bin/env bash
# QA check l7.contrast (Q0.4, redux/QA.md): the app dumps its Night and Day palettes (REDUX_PALETTE_DUMP,
# modules/gui/qt/style/palettedump.cpp) in the headless KDE session, and redux/qa/contrast.py writes the WCAG contrast
# report to $QA_OUT/contrast.md. Run by redux/tools/qa.sh (L7) inside the dev container.
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
export QA_OUT="${QA_OUT:-$PWD/build/qa}" QA_RESULTS="${QA_RESULTS:-$PWD/build/qa/results.tsv}"
out="$QA_OUT/l7"

if [[ "${1:-}" == --in-session ]]; then
  # The palette is built as the interface starts; a few seconds are plenty, then the player is stopped.
  for scheme in night:2 day:1; do
    home="$out/profile-${scheme%%:*}"
    rm -rf "$home" && mkdir -p "$home/.config/vlc"
    printf '[MainWindow]\ncolor-scheme-index=%s\n' "${scheme##*:}" > "$home/.config/vlc/vlc-qt-interface.conf"
    HOME="$home" XDG_CONFIG_HOME="$home/.config" REDUX_PALETTE_DUMP="$out" \
      timeout 10 "${BUILD_DIR:-build/meson}/bin/vlc-static" --no-qt-privacy-ask > "$out/vlc-${scheme%%:*}.log" 2>&1
  done
  exit 0
fi

rm -rf "$out" && mkdir -p "$out"
redux/tools/kwin-session.sh "$0" --in-session > "$out/session.log" 2>&1
python3 -I redux/qa/contrast.py "$out" "$QA_OUT/contrast.md"
