#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

readonly DIR="${HOME}/.vscode-server/cli/servers"
readonly KEEP_VERSIONS=2

function main(){
   [ -d "$DIR" ] || exit 0

   # remove staging folders
   find "${DIR}" -maxdepth 1 -type d -name "*.staging" -exec rm -rf {} +

   # keep number of latest Stable-* versions according to KEEP_VERSIONS variable
   # (find instead of ls, which fails when no version exists)
   find "${DIR}" -maxdepth 1 -type d -name "Stable-*" -printf '%T@ %p\n' \
       | sort --numeric-sort --reverse \
       | tail --lines "+$((KEEP_VERSIONS + 1))" \
       | cut --delimiter=' ' --fields=2- \
       | xargs --no-run-if-empty --delimiter='\n' rm -rf
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
   main "$@"
fi
