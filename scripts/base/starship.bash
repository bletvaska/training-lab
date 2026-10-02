#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

log "Installing Starship."

fetch https://starship.rs/install.sh | sh -s -- -y
