#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

log "User Setup."

# set user password; generate the hash with: openssl passwd -6
if [[ -n "${USER_PASSWORD_HASH:-}" ]]; then
    echo "${_user}:${USER_PASSWORD_HASH}" | chpasswd --encrypted
else
    log "Variable USER_PASSWORD_HASH is not set, skipping user password."
fi

# shell, tmux, vim and editorconfig
install_user_file base .bashrc.local
append_line_if_not_exists "${_home}/.bashrc" "source ~/.bashrc.local"
install_user_file base .tmux.conf
install_user_file base .tmux/themes/basic.tmuxtheme
install_user_file base .vimrc
install_user_file base .editorconfig
