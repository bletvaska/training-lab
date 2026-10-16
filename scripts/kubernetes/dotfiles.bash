#!/usr/bin/env bash
include ../../lib/common || exit 1

readonly templates=(configmap cronjob deployment hpa ingress job namespace pod pv pvc secrets service)


function install_templates(){
    local template

    for template in "${templates[@]}"; do
        install_user_file kubernetes "templates/${template}.yaml"
    done
}


function main(){
    log "Installing Kubernetes Dotfiles."

    install_user_file kubernetes .bash_aliases
    install_user_file kubernetes .bashrc.kubernetes
    append_line_if_not_exists "${USER_HOME}/.bashrc" "source ~/.bashrc.kubernetes"
    install_user_file kubernetes .config/starship.toml
    install_templates
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
