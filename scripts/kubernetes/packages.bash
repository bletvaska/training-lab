#!/usr/bin/env bash
include ../../lib/common || exit 1

readonly packages=(fzf kubectx)


function main(){
    log "Installing Kubernetes Packages: ${packages[*]}"

    apt-get update
    apt-get install --yes --no-install-recommends --no-install-suggests "${packages[@]}"

    # short names for kubectx and kubens
    ln --force --symbolic /usr/bin/kubectx /usr/local/bin/kctx
    ln --force --symbolic /usr/bin/kubens /usr/local/bin/kns
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
