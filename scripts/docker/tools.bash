#!/usr/bin/env bash
include ../../lib/common || exit 1

function install_grype(){
    local url
    url=$(get_github_latest_release "anchore/grype" "linux" "amd64" "deb")
    apt_install "${url}"
}


function install_dive(){
    local url
    url=$(get_github_latest_release "wagoodman/dive" "linux" "amd64" "deb")
    apt_install "${url}"
}


function install_dry(){
    local url
    url=$(get_github_latest_release "moncho/dry" "linux" "amd64" "amd64")
    download_binary "${url}" "/usr/local/bin/dry"
}


function install_hadolint(){
    local url
    url=$(get_github_latest_release "hadolint/hadolint" "linux" "x86_64" "x86_64")
    download_binary "${url}" "/usr/local/bin/hadolint"
}


function main(){
    log "Installing Docker Tools."

    install_grype
    install_dive
    install_dry
    install_hadolint
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
