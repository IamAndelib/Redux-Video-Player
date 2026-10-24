#!/usr/bin/env bash
# QA check l1.cut-entries (M0.8, redux/QA.md): no UI entry point of a cut feature is left, by the rules in
# redux/qa/cut-entries.tsv. Run by redux/tools/qa.sh (L1); appends its result to $QA_RESULTS.
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
export QA_RESULTS="${QA_RESULTS:-$PWD/build/qa/results.tsv}"
found=()
while IFS=$'\t' read -r kind file pattern what; do
  [[ -z "$kind" || "$kind" == \#* ]] && continue
  if [[ ! -f "$file" ]]; then
    found+=("$what: $file is missing")
  elif [[ "$kind" == absent ]] && grep -qE -- "$pattern" "$file"; then
    found+=("$what: still in $file:$(grep -nE -- "$pattern" "$file" | head -1 | cut -d: -f1)")
  elif [[ "$kind" == present ]] && ! grep -qE -- "$pattern" "$file"; then
    found+=("$what: not hidden in $file")
  fi
done < redux/qa/cut-entries.tsv

if [[ ${#found[@]} -eq 0 ]]; then
  printf '%s\t%s\t%s\n' l1.cut-entries pass "every rule in redux/qa/cut-entries.tsv holds" >> "$QA_RESULTS"
  echo "  pass  l1.cut-entries"
else
  printf '%s\n' "${found[@]}" > "$(dirname "$QA_RESULTS")/cut-entries.txt"
  printf '%s\t%s\t%s\n' l1.cut-entries fail \
    "${#found[@]} entry point(s) left, first: ${found[0]}; see $(dirname "$QA_RESULTS")/cut-entries.txt" >> "$QA_RESULTS"
  echo "  fail  l1.cut-entries  (${#found[@]} left; first: ${found[0]})"
fi
