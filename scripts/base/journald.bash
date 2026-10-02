#!/usr/bin/env bash
include ../../lib/common || exit 1

function main(){
    log "Limiting Size of Journal."

    install_file base etc/systemd/journald.conf.d/size.conf

    # apply the configuration, useful when the step runs separately
    systemctl try-reload-or-restart systemd-journald
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
