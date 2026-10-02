# shellcheck shell=bash
# common settings and helper functions, sourced by every script in scripts/

set -o errexit  # stop when error occurs
set -o pipefail # if not, expressions like `error here | true` will always succeed
set -o nounset  # detects uninitialised variables
set -o errtrace # ERR trap is inherited by functions

# show where the script failed
trap 'log "Error in ${BASH_SOURCE[0]} on line ${LINENO}: ${BASH_COMMAND}"' ERR

# print commands and their arguments as they are executed, enable with: just DEBUG=1 <recipe>
if [[ -n "${DEBUG:-}" ]]; then
    set -o xtrace
fi


# global variables
PROJECT_ROOT=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
readonly PROJECT_ROOT
readonly USER_NAME="ubuntu"
readonly USER_HOME="/home/${USER_NAME}"

export HOME="${USER_HOME}"


# functions
function log(){
    local now
    now=$(date +%H:%M:%S)
    local message="${*}"

    printf "\e[0;35m%s\e[m: \e[0;33m%s\e[m\n" "${now}" "${message}"
}


function fetch(){
    curl --fail --silent --show-error --location "${@}"
}


function get_github_latest_release(){
    local project="${1:?Project Github URL is missing.}"
    local kernel="${2}"
    local machine="${3}"
    local package="${4:-}"  # extension or ends with

    fetch "https://api.github.com/repos/${project}/releases/latest" \
        | jq --raw-output ".. | objects | .browser_download_url? // empty | select(contains(\"${kernel}\") and contains(\"${machine}\") and endswith(\"${package}\"))"
}


function apt_install(){
    local url="${1:?URL of deb package is missing.}"

    local temp
    temp=$(mktemp --suffix=".deb")
    fetch "${url}" --output "${temp}"
    # apt-get resolves dependencies, unlike dpkg; readable for the _apt sandbox user
    chmod 644 "${temp}"
    apt-get install --yes "${temp}"
    rm --force "${temp}"
}


function download_binary(){
    local url="${1:?URL of binary is missing.}"
    local target="${2:?Missing destination path.}"

    fetch "${url}" --output "${target}"
    chmod +x "${target}"
}


# installs files/<profile>/<path> to /<path>
function install_file(){
    local profile="${1:?Profile is missing.}"
    local path="${2:?Path is missing.}"
    local mode="${3:-644}"

    install -D --mode="${mode}" "${PROJECT_ROOT}/files/${profile}/${path}" "/${path}"
}


# installs files/<profile>/home/<path> to the user's home directory
function install_user_file(){
    local profile="${1:?Profile is missing.}"
    local path="${2:?Path is missing.}"
    local target="${USER_HOME}/${path}"

    # created as the user, so also the intermediate directories are owned by the user
    runuser --user "${USER_NAME}" -- mkdir --parents "$(dirname "${target}")"
    install --owner="${USER_NAME}" --group="${USER_NAME}" --mode=644 \
        "${PROJECT_ROOT}/files/${profile}/home/${path}" "${target}"
}


function append_line_if_not_exists(){
    local file="${1:?File is missing.}"
    local line="${2:?Line is missing.}"

    # add missing newline at end of file, otherwise the line would be glued to the last one
    if [[ -s "${file}" && -n "$(tail --bytes=1 "${file}")" ]]; then
        echo >> "${file}"
    fi

    grep --quiet --line-regexp --fixed-strings --no-messages -- "${line}" "${file}" \
        || printf '%s\n' "${line}" >> "${file}"
}
