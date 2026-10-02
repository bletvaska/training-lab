#!/usr/bin/env bash
include ../../lib/common || exit 1

readonly swapfile="/swap"
readonly size="2G"


function create_swapfile(){
    if [[ ! -f "${swapfile}" ]]; then
        fallocate -l "${size}" "${swapfile}"
        chmod 600 "${swapfile}"
        mkswap "${swapfile}"
    fi
}


function activate_swap(){
    if ! swapon --show=NAME --noheadings | grep --quiet --line-regexp "${swapfile}"; then
        swapon "${swapfile}"
    fi
}


function main(){
    log "Creating Swap."

    create_swapfile
    activate_swap
    append_line_if_not_exists /etc/fstab "${swapfile} none swap sw 0 0"
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
