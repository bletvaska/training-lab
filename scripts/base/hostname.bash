#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

log "Setting Hostname."

# set the hostname based on public ip address now and on every reboot
hostnamectl hostname "$(fetch ifconfig.me | tr . -)"
install_file base etc/cron.d/hostname
