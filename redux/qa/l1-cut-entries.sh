#!/usr/bin/env bash
# QA check l1.cut-entries (M0.8, redux/QA.md): no UI entry point of a cut feature is left, by the rules in
# redux/qa/cut-entries.tsv. Run by redux/tools/qa.sh (L1); appends its result to $QA_RESULTS.
set -uo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
export QA_RESULTS="${QA_RESULTS:-$PWD/build/qa/results.tsv}"
rules=redux/qa/cut-entries.tsv
found=()
checked=0
[[ -r "$rules" ]] || found+=("$rules can't be read")
while IFS=$'\t' read -r kind file pattern what; do
  [[ -z "$kind" || "$kind" == \#* ]] && continue
  checked=$((checked + 1))
  grep -qE -- "$pattern" "$file" 2>/dev/null
  status=$?   # 0 matches, 1 no match, 2 error (a missing file or a bad pattern: never a silent pass)
  if [[ $status -eq 2 || ( "$kind" != absent && "$kind" != present ) ]]; then
    found+=("$what: rule can't be checked ($kind, $file)")
  elif [[ "$kind" == absent && $status -eq 0 ]]; then
    found+=("$what: still in $file:$(grep -nE -- "$pattern" "$file" | head -1 | cut -d: -f1)")
  elif [[ "$kind" == present && $status -eq 1 ]]; then
    found+=("$what: not hidden in $file")
  fi
done < <(cat "$rules" 2>/dev/null)
[[ $checked -gt 0 ]] || found+=("no rules in $rules")

if [[ ${#found[@]} -eq 0 ]]; then
  printf '%s\t%s\t%s\n' l1.cut-entries pass "all $checked rules in $rules hold" >> "$QA_RESULTS"
  echo "  pass  l1.cut-entries"
else
  printf '%s\n' "${found[@]}" > "$(dirname "$QA_RESULTS")/cut-entries.txt"
  printf '%s\t%s\t%s\n' l1.cut-entries fail \
    "${#found[@]} entry point(s) left, first: ${found[0]}; see $(dirname "$QA_RESULTS")/cut-entries.txt" >> "$QA_RESULTS"
  echo "  fail  l1.cut-entries  (${#found[@]} left; first: ${found[0]})"
fi
