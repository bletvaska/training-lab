#!/usr/bin/env bash
include ../../lib/common || exit 1

readonly lifetime="${LIFETIME:-30 days}"
readonly dropin="/etc/systemd/system/expire.timer.d/date.conf"


function compute_expiration(){
    date --date="+${lifetime}" "+%F %H:%M"
}


function install_units(){
    install_file base etc/systemd/system/expire.service
    install_file base etc/systemd/system/expire.timer
    install_file base etc/update-motd.d/99-expire 755
}


function set_expiration(){
    local expires="${1:?Date of expiration is missing.}"
    local file="${2:-${dropin}}"

    mkdir --parents "$(dirname "${file}")"
    printf '[Timer]\nOnCalendar=%s\n' "${expires}" > "${file}"
}


function main(){
    local expires
    expires=$(compute_expiration)

    log "Setting End of Machine Lifetime: ${expires}"

    install_units
    set_expiration "${expires}"

    systemctl daemon-reload
    systemctl enable --now expire.timer
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
