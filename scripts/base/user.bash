#!/usr/bin/env bash
include ../../lib/common || exit 1

# set user password; generate the hash with: openssl passwd -6
function set_password(){
    if [[ -n "${USER_PASSWORD_HASH:-}" ]]; then
        echo "${USER_NAME}:${USER_PASSWORD_HASH}" | chpasswd --encrypted
    else
        log "Variable USER_PASSWORD_HASH is not set, skipping user password."
    fi
}


# shell, tmux, vim and editorconfig
function install_dotfiles(){
    install_user_file base .bashrc.local
    append_line_if_not_exists "${USER_HOME}/.bashrc" "source ~/.bashrc.local"
    install_user_file base .tmux.conf
    install_user_file base .tmux/themes/basic.tmuxtheme
    install_user_file base .vimrc
    install_user_file base .editorconfig
}


function main(){
    log "User Setup."

    set_password
    install_dotfiles
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
