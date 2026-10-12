#!/usr/bin/env bash
include ../../lib/common || exit 1

function install_helm(){
    fetch https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
    install_completion helm completion bash
}


function install_kompose(){
    install_binary_from_github "kubernetes/kompose" "kompose-linux-amd64" "/usr/local/bin/kompose"
    install_completion kompose completion bash
}


function install_k9s(){
    local url
    url=$(get_github_latest_release "derailed/k9s" "linux" "amd64" ".deb")
    apt_install "${url}"
    install_completion k9s completion bash
}


function install_kubecolor(){
    local url
    url=$(get_github_latest_release "kubecolor/kubecolor" "linux" "amd64" ".deb")
    apt_install "${url}"
}


function install_kubeconform(){
    install_binary_from_github "yannh/kubeconform" "kubeconform" "/usr/local/bin/kubeconform"
}


function install_stern(){
    install_binary_from_github "stern/stern" "stern" "/usr/local/bin/stern"
    install_completion stern --completion bash
}


function install_popeye(){
    local url
    url=$(get_github_latest_release "derailed/popeye" "linux" "amd64" ".deb")
    apt_install "${url}"
    install_completion popeye completion bash
}


function main(){
    log "Installing Kubernetes Tools."

    install_helm
    install_kompose
    install_k9s
    install_kubecolor
    install_kubeconform
    install_stern
    install_popeye
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
