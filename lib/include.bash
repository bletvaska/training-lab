# shellcheck shell=bash
# include of bash libraries relative to the including file, similar to load in bats
# just loads this file into every script through BASH_ENV, see justfile
#
# usage: include ../../lib/common || exit 1
#   (exit stops the script when it runs without just and include does not exist)
#
# note: the library is sourced inside a function, so its variables must not be
# declared with declare/local (they would be local), use plain assignment or readonly
#
# not named import, which is a screenshot command of ImageMagick,
# nor load, which is used by bats


function include(){
    local name="${1:?Name of the library is missing.}"
    local directory
    directory=$(dirname "${BASH_SOURCE[1]}")

    # shellcheck source=/dev/null
    source "${directory}/${name}.bash"
}
