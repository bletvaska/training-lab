#!/usr/bin/env bash
include ../../lib/common || exit 1

readonly packages=(aardvark-dns passt podman rootlesskit)


function main(){
    log "Installing Container Packages: ${packages[*]}"

    apt-get update
    apt-get install --yes --no-install-recommends --no-install-suggests "${packages[@]}"
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
