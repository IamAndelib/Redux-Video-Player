#!/usr/bin/env bash
# Configure, build and run Redux Video Player. Meant to run inside the dev container:
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

options() {
  # The Qt interface and the media library are what this project is about, so they're required;
  # skins2 stays off since we replace the UI rather than skin it. Plugins outside the product scope
  # (redux/SCOPE.md) are listed in redux/cut-modules.txt and not built (D20). After editing that list,
  # run `build.sh reconfigure`.
  local cut
  cut="$(grep -v '^[[:space:]]*#' redux/cut-modules.txt | sed '/^[[:space:]]*$/d' | paste -sd, -)"
  opts=(
    --buildtype=debugoptimized
    -Dqt=enabled
    -Dmedialibrary=enabled
    -Dskins2=disabled
    -Dtests=enabled
    -Dredux_cut_modules="$cut"
    -Dstream_outputs=false
    -Dvideolan_manager=false
    ${MESON_OPTS:-}
  )
}

configure() {
  options
  meson setup "$builddir" "${opts[@]}"
}

reconfigure() {
  # Two steps, so options added to meson_options.txt since the last setup are known before they're set.
  options
  meson setup --reconfigure "$builddir"
  meson configure "$builddir" "${opts[@]}"
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
    if [[ -f "$builddir/build.ninja" ]]; then reconfigure; else configure; fi
    ;;
  *)
    sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
