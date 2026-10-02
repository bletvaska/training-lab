#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

readonly script="/usr/local/bin/vscode-server-cleanup.bash"
readonly job="0 0 * * * ${script}"

log "Scheduling VS Code Server Cleanup."

install_file base "${script#/}" 755

# run it every midnight from the user's crontab, without duplicating the job
{ crontab -u "${_user}" -l 2>/dev/null | grep --invert-match --fixed-strings "${script}" || true; echo "${job}"; } \
    | crontab -u "${_user}" -
