#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

log "Installing Docker Tools."

# install grype
url=$(get_github_latest_release "anchore/grype" "linux" "amd64" "deb")
apt_install "${url}"

# install dive
url=$(get_github_latest_release "wagoodman/dive" "linux" "amd64" "deb")
apt_install "${url}"

# install dry
url=$(get_github_latest_release "moncho/dry" "linux" "amd64" "amd64")
download_binary "${url}" "/usr/local/bin/dry"

# install hadolint
url=$(get_github_latest_release "hadolint/hadolint" "linux" "x86_64" "x86_64")
download_binary "${url}" "/usr/local/bin/hadolint"
