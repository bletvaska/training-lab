#!/usr/bin/env bash
# EC2 user-data: prepares the machine and hands the provisioning over to just
# copy the content to user-data of the launch template and set the variables below
# the provisioning is configured by tags of the instance, see readme.md

set -o errexit  # stop when error occurs
set -o pipefail # if not, expressions like `error here | true` will always succeed
set -o nounset  # detects uninitialised variables

readonly repository="https://github.com/bletvaska/training-lab.git"
readonly branch="main"
readonly target="/tmp/provisioning"  # tmpfs, removed by the reboot at the end
readonly default_profile="docker"
readonly default_lifetime="30 days"
readonly metadata="http://169.254.169.254/latest"

# hash of the user password, generate with: openssl passwd -6
# keep the single quotes, the hash contains $ characters
# if not set, the password is not set and ssh login with password stays disabled
# export USER_PASSWORD_HASH='CHANGE-ME'


# prints the value of the instance tag; fails, if the tag does not exist
# or tags are not allowed in the instance metadata
function get_tag(){
    local name="${1:?Name of the tag is missing.}"
    local token

    token=$(curl --fail --silent --max-time 5 --request PUT "${metadata}/api/token" \
        --header "X-aws-ec2-metadata-token-ttl-seconds: 60")
    curl --fail --silent --max-time 5 --header "X-aws-ec2-metadata-token: ${token}" \
        "${metadata}/meta-data/tags/instance/${name}"
}


# the lock of the package lists can be held by other apt processes after boot
# and apt-get update does not wait for it, so it is retried
function apt_update(){
    local attempt

    for attempt in {1..10}; do
        apt-get update && return 0
        echo "apt-get update failed (attempt ${attempt}/10), retrying in 10 seconds" >&2
        sleep 10
    done

    return 1
}


# prints the profile from the tag, or the default one if the tag is not set
# or the profile does not exist; each profile has its directory in scripts/
# and a just recipe of the same name, base is common for all profiles
function get_profile(){
    local profile
    profile=$(get_tag Profile || true)

    if [[ -z "${profile}" ]]; then
        echo "Tag Profile is not set, using profile ${default_profile}" >&2
        profile="${default_profile}"
    elif [[ ! "${profile}" =~ ^[a-z0-9-]+$ || "${profile}" == "base" || ! -d "${target}/scripts/${profile}" ]]; then
        echo "Profile ${profile} does not exist, using profile ${default_profile}" >&2
        profile="${default_profile}"
    fi

    echo "${profile}"
}


function main(){
    export DEBIAN_FRONTEND="noninteractive"

    # other apt processes after boot (e.g. unattended-upgrades) hold the dpkg lock,
    # so apt-get waits for it instead of failing
    echo 'DPkg::Lock::Timeout "600";' > /etc/apt/apt.conf.d/90-lock-timeout

    # update the system and install tools for the provisioning
    apt_update
    apt-get full-upgrade --yes
    apt-get install --yes git just

    # get the provisioning and remember the commit used for it
    git clone --depth 1 --branch "${branch}" "${repository}" "${target}"
    git -C "${target}" rev-parse HEAD > /etc/training-lab-release

    # configuration of the provisioning from the tags of the instance
    TRAINING=$(get_tag Training || true)
    STUDENT=$(get_tag Name || true)
    LIFETIME=$(get_tag Lifetime || echo "${default_lifetime}")
    PROFILE=$(get_profile)
    export TRAINING STUDENT LIFETIME PROFILE

    just --justfile "${target}/justfile" "${PROFILE}"
}


# call the func only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
