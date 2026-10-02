#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

log "Installing Docker Dotfiles."

install_user_file docker .bash_aliases
