#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# shellcheck source=/dev/null
. "$(realpath "$ScriptDirectory/func.processList.sh")"

NPMListCmd="npm list -g --depth=0 --parseable"
NPMList=$(realpath "$ScriptDirectory/../../list.npm.txt")

processList "$NPMListCmd" "$NPMList"
