#!/usr/bin/env bash
include ../../lib/common || exit 1

function main(){
    log "Installing Docker Dotfiles."

    install_user_file docker .bash_aliases
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
