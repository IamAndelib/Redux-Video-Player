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
base="${QA_BASE:-$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null)}"
[[ -n "$base" ]] || { echo "token-lint: no base to compare with (set QA_BASE, or fetch main)" >&2; exit 2; }

hex='"#[0-9A-Fa-f]{3}([0-9A-Fa-f]{3}([0-9A-Fa-f]{2})?)?"'   # "#rgb", "#rrggbb", "#aarrggbb"
radius='radius[[:space:]]*:[[:space:]]*[0-9]'

qml=('modules/gui/qt/*.qml' ':(exclude)modules/gui/qt/style/*')
diff="$(git diff -U0 "$base" -- "${qml[@]}")" || { echo "token-lint: git diff against $base failed" >&2; exit 2; }
# New files git doesn't track yet are all added lines.
while IFS= read -r f; do
  diff+=$'\n'"$(git diff -U0 --no-index /dev/null "$f")"
done < <(git ls-files --others --exclude-standard -- "${qml[@]}")
found="$(awk '/^\+\+\+ / { file = substr($0, 7); next } /^@@/ { split($3, a, ","); line = substr(a[1], 2) - 1; next }
              /^\+/ { line++; print file ":" line ": " substr($0, 2) }' <<< "$diff" | grep -E "$hex|$radius")"

if [[ -n "$found" ]]; then
  echo "Hard-coded colours or radii in added QML lines (use VLCStyle / ColorContext tokens):"
  echo "$found"
  exit 1
fi
echo "no hard-coded colours or radii in QML added since $(git rev-parse --short "$base")"
