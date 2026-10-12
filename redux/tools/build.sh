#!/usr/bin/env bash
# Configure, build and run VLC Redux. Meant to run inside the dev container:
#
#   redux/dev.sh run redux/tools/build.sh            configure if needed, then build everything
#   redux/dev.sh run redux/tools/build.sh qt         rebuild only the Qt interface plugin (fast UI loop)
#   redux/dev.sh run redux/tools/build.sh run [args] start the built player (vlc-static uses the build tree's plugins)
#   redux/dev.sh run redux/tools/build.sh reconfigure
#
# Build directory: build/meson (override with BUILD_DIR). Extra meson options: MESON_OPTS.
set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
builddir="${BUILD_DIR:-build/meson}"

configure() {
  # The Qt interface and the media library are what this project is about, so they're required;
  # skins2 stays off since we replace the UI rather than skin it.
  meson setup "$builddir" ${1:+"$1"} \
    --buildtype=debugoptimized \
    -Dqt=enabled \
    -Dmedialibrary=enabled \
    -Dskins2=disabled \
    -Dtests=enabled \
    ${MESON_OPTS:-}
}

ensure_configured() {
  [[ -f "$builddir/build.ninja" ]] || configure
}

case "${1:-build}" in
  build)
    ensure_configured
    meson compile -C "$builddir"
    ;;
  qt)
    ensure_configured
    meson compile -C "$builddir" qt_plugin
    ;;
  run)
    shift
    exec "$builddir/bin/vlc-static" "$@"
    ;;
  reconfigure)
    if [[ -f "$builddir/build.ninja" ]]; then configure --reconfigure; else configure; fi
    ;;
  *)
    sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
