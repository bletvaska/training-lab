#!/usr/bin/env bash
# shellcheck source=SCRIPTDIR/../../lib/common.bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.bash"

readonly lifetime="${LIFETIME:-30 days}"

expires=$(date --date="+${lifetime}" "+%F %H:%M")
readonly expires

log "Setting End of Machine Lifetime: ${expires}"

install_file base etc/systemd/system/expire.service
install_file base etc/systemd/system/expire.timer
install_file base etc/update-motd.d/99-expire 755

mkdir --parents /etc/systemd/system/expire.timer.d
printf '[Timer]\nOnCalendar=%s\n' "${expires}" > /etc/systemd/system/expire.timer.d/date.conf

systemctl daemon-reload
systemctl enable --now expire.timer
