#!/usr/bin/env bash
include ../../lib/common || exit 1

function main(){
    log "Setting Hostname."

    # set the hostname based on public ip address now and on every reboot
    hostnamectl hostname "$(fetch ifconfig.me | tr . -)"
    install_file base etc/cron.d/hostname
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
