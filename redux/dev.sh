#!/usr/bin/env bash
# Run Redux Video Player development commands inside a Podman container so the host stays untouched.
#
#   redux/dev.sh image          build (or rebuild) the dev image
#   redux/dev.sh shell          interactive shell in the container
#   redux/dev.sh run <cmd...>   run one command in the container
#   redux/dev.sh app [file...]  open the built player on your desktop (what the app-menu launcher runs)
#
# The repo is mounted at /workspace and commands run as your own user, so files
# created in the container belong to you on the host. The host's Wayland/X11
# display, PipeWire/PulseAudio and GPU are passed through, so the built player
# can be run and heard from inside the container.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image="localhost/vlc-redux-dev:latest"

build_image() {
  local mirror ca build_args=() saved="$repo/build/debian-mirror"
  # The mirror is a build argument, so changing it invalidates every cached layer. Benchmark once,
  # save the winner and reuse it; DEBIAN_MIRROR=… overrides, deleting build/debian-mirror re-picks.
  if [[ -n "${DEBIAN_MIRROR:-}" ]]; then
    mirror="$DEBIAN_MIRROR"
  elif [[ -s "$saved" ]]; then
    mirror="$(<"$saved")"
  else
    mirror="$("$repo/redux/tools/fastest-debian-mirror.sh")"
    mkdir -p "$repo/build" && echo "$mirror" > "$saved"
  fi
  build_args+=(--build-arg "DEBIAN_MIRROR=$mirror")
  # Lend the host's CA bundle to the first apt step so an https mirror works from the start.
  for ca in /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt; do
    [[ -f "$ca" ]] && { build_args+=(--volume "$ca:/run/host-ca.crt:ro"); break; }
  done
  podman build --security-opt label=disable "${build_args[@]}" \
    -t "$image" -f "$repo/.devcontainer/Containerfile" "$repo/.devcontainer"
}

container_args() { # container_args [home-inside-container]
  local runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" home="${1:-/tmp/home}"
  args=(
    --rm --init
    --userns=keep-id
    --security-opt label=disable       # SELinux: don't relabel the host checkout
    --hostname vlc-redux-dev
    -v "$repo:/workspace"
    -v vlc-redux-ccache:/ccache:U
    -w /workspace
    --tmpfs /tmp/runtime:rw,mode=0700,U   # private XDG runtime dir owned by you
    -e HOME="$home"
    -e XDG_RUNTIME_DIR=/tmp/runtime
    -e TERM="${TERM:-xterm-256color}"
  )
  # Display: Wayland first, X11 (Xwayland) as fallback for tools that need it.
  if [[ -n "${WAYLAND_DISPLAY:-}" && -S "$runtime/$WAYLAND_DISPLAY" ]]; then
    args+=(-v "$runtime/$WAYLAND_DISPLAY:/tmp/runtime/$WAYLAND_DISPLAY"
           -e WAYLAND_DISPLAY="$WAYLAND_DISPLAY" -e QT_QPA_PLATFORM="wayland;xcb")
  fi
  if [[ -n "${DISPLAY:-}" && -d /tmp/.X11-unix ]]; then
    args+=(-v /tmp/.X11-unix:/tmp/.X11-unix:ro -e DISPLAY="$DISPLAY")
    [[ -n "${XAUTHORITY:-}" && -f "$XAUTHORITY" ]] && args+=(-v "$XAUTHORITY:/tmp/.Xauthority:ro" -e XAUTHORITY=/tmp/.Xauthority)
  fi
  # Audio.
  [[ -S "$runtime/pipewire-0" ]] && args+=(-v "$runtime/pipewire-0:/tmp/runtime/pipewire-0")
  [[ -S "$runtime/pulse/native" ]] && args+=(-v "$runtime/pulse/native:/tmp/runtime/pulse/native"
                                           -e PULSE_SERVER=unix:/tmp/runtime/pulse/native)
  # GPU (hardware decoding and Qt Quick rendering).
  [[ -d /dev/dri ]] && args+=(--device /dev/dri --group-add keep-groups)
  return 0
}

ensure_image() {
  podman image exists "$image" || build_image
}

# HOME is throwaway; anything worth keeping lives in /workspace or the ccache volume.
prelude='mkdir -p "$HOME"'

case "${1:-}" in
  image)
    build_image
    ;;
  shell)
    ensure_image; container_args
    exec podman run -it "${args[@]}" "$image" bash -c "$prelude && exec bash"
    ;;
  app)
    # The player with a persistent profile (build/app-home: settings and library survive, and the
    # system VLC config is never touched) and your home folder mounted read-only at the same path,
    # so the player can open your own files and take drag and drop from the file manager.
    shift
    if [[ ! -x "$repo/build/meson/bin/vlc-static" ]]; then
      msg="Redux Video Player isn't built yet. Run: redux/dev.sh run redux/tools/build.sh"
      echo "$msg" >&2
      command -v notify-send >/dev/null && notify-send "Redux Video Player" "$msg"
      exit 1
    fi
    ensure_image; container_args /workspace/build/app-home
    args+=(-v "$HOME:$HOME:ro")
    # Audio: the container has no PipeWire client config, but the host's PulseAudio socket (PipeWire's
    # pulse server on most desktops) is mounted, so use VLC's PulseAudio output.
    exec podman run "${args[@]}" "$image" bash -c "$prelude && exec redux/tools/build.sh run --aout=pulse \"\$@\"" bash "$@"
    ;;
  run)
    shift; [[ $# -ge 1 ]] || { echo "usage: $0 run <cmd...>" >&2; exit 1; }
    ensure_image; container_args
    tty=(); [[ -t 0 && -t 1 ]] && tty=(-it)
    exec podman run "${tty[@]}" "${args[@]}" "$image" bash -c "$prelude && exec \"\$@\"" bash "$@"
    ;;
  *)
    sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
