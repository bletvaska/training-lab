#!/usr/bin/env bash
include ../../lib/common || exit 1

function main(){
    log "Installing Docker."

    # limit size of docker container logs and build cache
    # must exist before docker installation, so the daemon starts with it
    install_file docker etc/docker/daemon.json

    fetch https://get.docker.com/ | sh
    usermod --append --groups docker "${USER_NAME}"
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
