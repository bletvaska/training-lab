#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

readonly packages=(btop bat figlet httpie jq mc nmap python-is-python3 python3-venv tree unzip vim)

log "Installing System Packages: ${packages[*]}"

apt-get update
apt-get install --yes --no-install-recommends --no-install-suggests "${packages[@]}"
