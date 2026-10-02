#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

log "Creating Swap."

# swap file 2G in /swap
if [[ ! -f /swap ]]; then
    fallocate -l 2G /swap
    chmod 600 /swap
    mkswap /swap
fi

# activate swap
if ! swapon --show=NAME --noheadings | grep --quiet --line-regexp /swap; then
    swapon /swap
fi

append_line_if_not_exists /etc/fstab "/swap none swap sw 0 0"
