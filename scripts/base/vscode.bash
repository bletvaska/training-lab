#!/usr/bin/env bash
include ../../lib/common || exit 1

readonly script="/usr/local/bin/vscode-server-cleanup.bash"
readonly job="0 0 * * * ${script}"


# run the script every midnight from the user's crontab, without duplicating the job
function schedule_cleanup(){
    {
        crontab -u "${USER_NAME}" -l 2>/dev/null | grep --invert-match --fixed-strings "${script}" || true
        echo "${job}"
    } | crontab -u "${USER_NAME}" -
}


function main(){
    log "Scheduling VS Code Server Cleanup."

    install_file base "${script#/}" 755
    schedule_cleanup
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
