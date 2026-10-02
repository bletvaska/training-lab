#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

log "Setting Timezone: ${_timezone}"

timedatectl set-timezone "${_timezone}"
