#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# shellcheck source=/dev/null
. "$(realpath "$ScriptDirectory/func.processList.sh")"

VsCodeList=$(realpath "$ScriptDirectory/../../list.vscode.txt")

processList "code --list-extensions" "$VsCodeList"
