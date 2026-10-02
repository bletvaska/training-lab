#!/usr/bin/env bash
include ../../lib/common || exit 1

readonly config="etc/ssh/sshd_config.d/10-password.conf"


function enable_password_authentication(){
    log "Enabling SSH Password Authentication."
    install_file base "${config}"
}


function disable_password_authentication(){
    log "Variable USER_PASSWORD_HASH is not set, SSH password authentication stays disabled."
    rm --force "/${config}"
}


function main(){
    # password authentication only makes sense when the user has a password
    if [[ -n "${USER_PASSWORD_HASH:-}" ]]; then
        enable_password_authentication
    else
        disable_password_authentication
    fi

    # apply the configuration, useful when the step runs separately
    systemctl try-reload-or-restart ssh
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
