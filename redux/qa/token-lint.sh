#!/usr/bin/env bash
# QA token lint (redux/QA.md L1/L6; Definition of Done): QML lines added since this branch left main must not
# hard-code colours or radii; they come from VLCStyle / ColorContext tokens. Only added lines are checked
# ("tokenize only what you touch"), so stock VLC code doesn't fail the lint. modules/gui/qt/style/ defines the
# tokens and is exempt.
#
#   redux/qa/token-lint.sh            prints offending lines; exit 1 if there are any
#   QA_BASE=<ref> ...                 compare against another base (default: the merge-base with main)
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
base="${QA_BASE:-$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main)}"

hex='"#[0-9A-Fa-f]{3}([0-9A-Fa-f]{3}([0-9A-Fa-f]{2})?)?"'   # "#rgb", "#rrggbb", "#aarrggbb"
radius='radius[[:space:]]*:[[:space:]]*[0-9]'

found="$(git diff -U0 "$base" -- 'modules/gui/qt/*.qml' ':(exclude)modules/gui/qt/style/*' |
  awk '/^\+\+\+ b\// { file = substr($0, 7) } /^@@/ { split($3, a, ","); line = substr(a[1], 2) - 1 }
       /^\+[^+]/ { line++; print file ":" line ": " substr($0, 2) } /^ / { line++ }' |
  grep -E "$hex|$radius")"

if [[ -n "$found" ]]; then
  echo "Hard-coded colours or radii in added QML lines (use VLCStyle / ColorContext tokens):"
  echo "$found"
  exit 1
fi
echo "no hard-coded colours or radii in QML added since $(git rev-parse --short "$base")"
