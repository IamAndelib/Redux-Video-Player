#!/usr/bin/env bash
# Build, install, run and check the Redux Video Player Flatpak (M0.7). Runs on the host with Flathub's
# org.flatpak.Builder app and the KDE 6.11 runtime/SDK, installed per user (DECISIONS D22).
#
#   redux/tools/flatpak.sh build      build redux/packaging/<app-id>.yml and install it for your user
#   redux/tools/flatpak.sh run [args] start the installed Flatpak
#   redux/tools/flatpak.sh lint       Flathub's linter on the manifest and the built repo
#   redux/tools/flatpak.sh matrix     play the codec/format matrix inside the Flatpak (build/matrix must exist)
#
# Build state lives in build/flatpak-* (git-ignored); ccache keeps rebuilds fast.
set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
app=io.github.iamandelib.Redux-Video-Player
manifest="redux/packaging/$app.yml"
builder=(flatpak run --filesystem="$PWD" org.flatpak.Builder)

case "${1:-}" in
  build)
    "${builder[@]}" --user --install --force-clean --ccache \
      --state-dir=build/flatpak-state --repo=build/flatpak-repo build/flatpak-build "$manifest"
    ;;
  run)
    shift
    exec flatpak run "$app" "$@"
    ;;
  lint)
    "${builder[@]}" --command=flatpak-builder-lint manifest "$manifest" || true
    "${builder[@]}" --command=flatpak-builder-lint repo build/flatpak-repo || true
    ;;
  matrix)
    # The matrix tool runs on the host; VLC_CMD points it at the player inside the Flatpak.
    # A timeout stops `flatpak run` but not the player inside the sandbox: stop the instances this run left behind,
    # never one that was already open.
    instances() { flatpak ps --columns=instance,application 2>/dev/null | awk -v a="$app" '$2 == a { print $1 }'; }
    before="$(instances)"
    status=0
    VLC_CMD="flatpak run --command=vlc $app" redux/tools/play-matrix.sh || status=$?   # host:ro already sees build/
    for i in $(instances); do
      grep -qxF "$i" <<< "$before" || flatpak kill "$i" || true
    done
    exit $status
    ;;
  *)
    sed -n '2,11p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
