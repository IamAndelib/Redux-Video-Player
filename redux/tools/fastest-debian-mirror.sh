#!/usr/bin/env bash
# Print the fastest Debian mirror that carries sid, like dnf's fastestmirror.
# Each candidate downloads the same index file for a few seconds, all in parallel;
# the one with the highest throughput wins. Override the choice with DEBIAN_MIRROR=<url>.
set -euo pipefail

if [[ -n "${DEBIAN_MIRROR:-}" ]]; then
  echo "$DEBIAN_MIRROR"
  exit 0
fi

candidates=(
  http://deb.debian.org/debian            # Fastly CDN, the default
  https://mirror.xeonbd.com/debian        # Bangladesh
  https://mirror.sg.gs/debian             # Singapore
  https://mirror.xtom.com.hk/debian       # Hong Kong
  https://mirrors.tuna.tsinghua.edu.cn/debian
  https://mirrors.ustc.edu.cn/debian
  http://ftp.jp.debian.org/debian
  http://ftp.kr.debian.org/debian
  http://ftp.de.debian.org/debian
  http://ftp.us.debian.org/debian
  https://mirror.xtom.com/debian          # US/EU
)

probe=dists/sid/main/binary-amd64/Packages.xz
results="$(mktemp)"
trap 'rm -f "$results"' EXIT

for m in "${candidates[@]}"; do
  (
    out="$(curl -sL -o /dev/null --max-time 6 -w '%{http_code} %{speed_download}' "$m/$probe" || true)"
    read -r code speed <<<"$out"
    [[ "$code" == 200 ]] && printf '%.0f %s\n' "$speed" "$m" >>"$results"
  ) &
done
wait

best="$(sort -rn "$results" | head -n1)"
if [[ -z "$best" ]]; then
  echo "http://deb.debian.org/debian"
  exit 0
fi
echo "fastest Debian mirror: ${best#* } ($(( ${best%% *} / 1024 )) KiB/s)" >&2
echo "${best#* }"
