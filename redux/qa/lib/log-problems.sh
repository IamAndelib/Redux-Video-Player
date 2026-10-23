# Shared by the L1 checks (redux/qa/l1-hygiene.sh, l1-kwin.sh): which lines of a VLC log count as problems.
#
#   problems <log>   prints every Qt warning or error (QML included) and every VLC error, minus the allowlists
#
# Errors that only mean "no GPU" are allowed, each with its reason, in log-allowlist.txt; the software-rasterizer
# list only when the log itself shows a software rasterizer (log-allowlist-swrast.txt).
qa_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
allow="$qa_dir/log-allowlist.txt"
allow_swrast="$qa_dir/log-allowlist-swrast.txt"

problems() { # problems <log>: every Qt warning or error (QML included) and every VLC error, minus the allowlist
  local patterns
  patterns="$(grep -v -e '^#' -e '^$' "$allow")"
  # The software-rasterizer list applies only when this log proves there is no GPU (CI runners, VMs).
  if grep -q 'suspected to be a software rasterizer' "$1"; then
    patterns+=$'\n'"$(grep -v -e '^#' -e '^$' "$allow_swrast")"
  fi
  grep -E '^\[[0-9a-f]+\] (\[qt\] )?qt [a-z]+ (warning|error): |^\[qt\] |^\[[0-9a-f]+\] .* error: ' "$1" |
    grep -vEf <(printf '%s\n' "$patterns") | sed 's/^\[[0-9a-f]*\] //' | sort -u
}
