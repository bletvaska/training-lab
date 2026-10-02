#!/usr/bin/env bash
include ../../lib/common || exit 1

function main(){
    log "Installing Starship."

    fetch https://starship.rs/install.sh | sh -s -- -y
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
