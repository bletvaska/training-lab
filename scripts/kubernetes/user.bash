#!/usr/bin/env bash
include ../../lib/common || exit 1

readonly kubeconfig="${USER_HOME}/.kube/config"


# copy of the admin kubeconfig of k3s, readable only by the user
function setup_kubeconfig(){
    runuser --user "${USER_NAME}" -- mkdir --parents "$(dirname "${kubeconfig}")"
    install --owner="${USER_NAME}" --group="${USER_NAME}" --mode=600 \
        /etc/rancher/k3s/k3s.yaml "${kubeconfig}"

    runuser --user "${USER_NAME}" -- \
        kubectl --kubeconfig "${kubeconfig}" config set-context --current --namespace default
}


# krew is installed into the user's home directory, so it runs as the user
function install_krew(){
    local krew
    krew=$(mktemp)

    install_binary_from_github "kubernetes-sigs/krew" "./krew-linux_amd64" "${krew}"
    chmod 755 "${krew}"
    runuser --user "${USER_NAME}" -- "${krew}" install krew
    rm --force "${krew}"
}


function main(){
    log "Kubernetes User Setup."

    setup_kubeconfig
    install_krew
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
