#!/usr/bin/env bash
# Build and install VLC into the Flatpak (/app). Called by the manifest's VLC module from the source root, so
# redux/cut-modules.txt stays the single list of plugins we don't build (D20), exactly as in redux/tools/build.sh.
set -euo pipefail

meson="${MESON:-meson}"   # the manifest points this at a newer meson than the SDK's
cut="$(grep -v '^[[:space:]]*#' redux/cut-modules.txt | sed '/^[[:space:]]*$/d' | paste -sd, -)"
"$meson" setup _flatpak --prefix=/app --libdir=lib --buildtype=release \
  -Dqt=enabled -Dmedialibrary=enabled -Dskins2=disabled -Dtests=disabled \
  -Dlua=disabled -Dupdate-check=disabled -Drust=disabled -Dqt_gtk=disabled -Dnls=enabled \
  -Dlibplacebo=enabled -Dvulkan=enabled -Dwayland=enabled -Dx11=enabled -Dxcb=enabled \
  -Davcodec=enabled -Davformat=enabled -Dswscale=enabled -Ddav1d=enabled \
  -Dmatroska=enabled -Dlibdvbpsi=enabled -Dtaglib=enabled -Dlibass=enabled \
  -Dpulse=enabled -Dpipewire=enabled -Ddbus=enabled \
  -Dgnutls=disabled -Dlibsecret=disabled -Dlibgcrypt=disabled -Dchromecast=disabled -Davahi=disabled \
  -Dupnp=disabled -Dstream_outputs=false -Dvideolan_manager=false \
  -Dredux_cut_modules="$cut"
"$meson" compile -C _flatpak
"$meson" install -C _flatpak
