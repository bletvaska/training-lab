#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

# password authentication only makes sense when the user has a password
if [[ -n "${USER_PASSWORD_HASH:-}" ]]; then
    log "Enabling SSH Password Authentication."
    install_file base etc/ssh/sshd_config.d/10-password.conf
else
    log "Variable USER_PASSWORD_HASH is not set, SSH password authentication stays disabled."
    rm --force /etc/ssh/sshd_config.d/10-password.conf
fi

# apply the configuration, useful when the step runs separately
systemctl try-reload-or-restart ssh
