#!/usr/bin/env bash
include ../../lib/common || exit 1

# set user password from the variable USER_PASSWORD (tag Password)
# (${USER_PASSWORD:+set} keeps the password out of the debug output)
function set_password(){
    if [[ -z "${USER_PASSWORD:+set}" ]]; then
        log "Variable USER_PASSWORD is not set, skipping user password."
        return
    fi

    # keep the password out of the debug output
    { set +o xtrace; } 2>/dev/null
    echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd
    if [[ -n "${DEBUG:-}" ]]; then
        set -o xtrace
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
