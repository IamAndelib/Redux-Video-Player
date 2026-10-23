#!/usr/bin/env bash
# Make the dev image available as localhost/vlc-redux-dev:latest (what redux/dev.sh runs) without rebuilding it when
# a copy already exists. Used by CI (.github/workflows/), also runs locally with Podman.
#
#   redux/tools/ci-image.sh            pull ghcr.io/iamandelib/redux-dev:<tag>, or build it with dev.sh on a miss
#   redux/tools/ci-image.sh --push     same, and push a freshly built image (needs `podman login ghcr.io`)
#
# <tag> is a hash of the files in .devcontainer/, so editing the Containerfile produces a new tag: a pull request
# that changes it builds and tests its own image, every other run reuses the published one. Prints the tag, and
# writes `tag=<tag>` to $GITHUB_OUTPUT when it is set. REDUX_IMAGE_REPO overrides the registry path.
set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
registry="${REDUX_IMAGE_REPO:-ghcr.io/iamandelib/redux-dev}"
local_image=localhost/vlc-redux-dev:latest
push=false
[[ "${1:-}" == --push ]] && push=true

# Hash the index entries (mode, blob hash, path) of .devcontainer/: needs no history and no file reads.
tag="$(git ls-files -s .devcontainer | sha256sum | cut -c1-16)"
remote="$registry:$tag"

if podman pull --quiet "$remote" >/dev/null 2>&1; then
  echo "pulled $remote" >&2
  podman tag "$remote" "$local_image"
else
  echo "no $remote yet; building it" >&2
  redux/dev.sh image
  if $push; then
    podman tag "$local_image" "$remote"
    podman tag "$local_image" "$registry:latest"
    podman push "$remote"
    podman push "$registry:latest"
  fi
fi

echo "$tag"
[[ -n "${GITHUB_OUTPUT:-}" ]] && echo "tag=$tag" >> "$GITHUB_OUTPUT"
exit 0
