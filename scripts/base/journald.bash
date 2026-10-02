#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

log "Limiting Size of Journal."

install_file base etc/systemd/journald.conf.d/size.conf

# apply the configuration, useful when the step runs separately
systemctl try-reload-or-restart systemd-journald
