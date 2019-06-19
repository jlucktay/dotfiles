#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# shellcheck source=/dev/null
. "$(realpath "$ScriptDirectory/func.processList.sh")"

GoBinListCmd="find $GOPATH/bin -type f"
GoBinList=$(realpath "$ScriptDirectory/../../list.go.bin.txt")

processList "$GoBinListCmd" "$GoBinList"
