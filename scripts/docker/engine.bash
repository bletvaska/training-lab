#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

log "Installing Docker."

# limit size of docker container logs and build cache
# must exist before docker installation, so the daemon starts with it
install_file docker etc/docker/daemon.json

fetch https://get.docker.com/ | sh
usermod --append --groups docker "${_user}"
