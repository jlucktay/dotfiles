#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# shellcheck source=/dev/null
. "$(realpath "$ScriptDirectory/func.processList.sh")"

GitListCmd="find \"$HOME\" -type d -name \".git\" \
    -not -path \"*/.cache/*\" \
    -not -path \"*/.glide/cache/*\" \
    -not -path \"*/.terraform/*\" \
    -not -path \"*/go/pkg/dep/sources/*\" \
    -execdir pwd \\; 2>/dev/null"
GitList=$(realpath "$ScriptDirectory/../../list.git.txt")

processList "$GitListCmd" "$GitList"
