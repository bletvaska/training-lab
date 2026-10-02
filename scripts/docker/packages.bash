#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

readonly packages=(aardvark-dns passt podman rootlesskit)

log "Installing Container Packages: ${packages[*]}"

apt-get update
apt-get install --yes --no-install-recommends --no-install-suggests "${packages[@]}"
