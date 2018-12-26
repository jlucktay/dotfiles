#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# shellcheck source=/dev/null
. "$(realpath "$ScriptDirectory/func.processList.sh")"

Now=$(date +%Y%m%d.%H%M%S.%N%z)

VsCodeList=$(realpath "$ScriptDirectory/../../list.vscode.txt")
VsCodeListArchive=$(realpath "$ScriptDirectory/../../list.vscode.$Now.txt")

processList "$Now" "code --list-extensions" "$VsCodeList" "$VsCodeListArchive"
