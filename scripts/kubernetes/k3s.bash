#!/usr/bin/env bash
include ../../lib/common || exit 1

function main(){
    log "Installing K3s."

    # also links kubectl to k3s, so its version matches the cluster
    fetch https://get.k3s.io | sh -

    install_completion k3s completion bash
    install_completion kubectl completion bash
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
