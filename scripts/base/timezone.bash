#!/usr/bin/env bash
include ../../lib/common || exit 1

readonly timezone="Europe/Bratislava"


function main(){
    log "Setting Timezone: ${timezone}"

    timedatectl set-timezone "${timezone}"
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
