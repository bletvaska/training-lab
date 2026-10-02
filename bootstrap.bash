#!/usr/bin/env bash
# EC2 user-data: prepares the machine and hands the provisioning over to just
# copy the content to user-data of the launch template and set the variables below

set -o errexit  # stop when error occurs
set -o pipefail # if not, expressions like `error here | true` will always succeed
set -o nounset  # detects uninitialised variables

readonly repository="https://github.com/bletvaska/training-lab.git"
readonly branch="main"
readonly training="docker"  # name of the just recipe
readonly target="/tmp/provisioning"  # tmpfs, removed by the reboot at the end

# the machine powers off after this time (any value accepted by date --date)
# set shutdown behavior to "terminate" in the launch template, so it is terminated
export LIFETIME="30 days"

# hash of the user password, generate with: openssl passwd -6
# keep the single quotes, the hash contains $ characters
# if not set, the password is not set and ssh login with password stays disabled
# export USER_PASSWORD_HASH='CHANGE-ME'

set -o xtrace   # print commands and their arguments as they are executed

export DEBIAN_FRONTEND="noninteractive"

apt-get update
apt-get full-upgrade --yes
apt-get install --yes git just

git clone --depth 1 --branch "${branch}" "${repository}" "${target}"
git -C "${target}" rev-parse HEAD > /etc/training-lab-release
just --justfile "${target}/justfile" "${training}"
