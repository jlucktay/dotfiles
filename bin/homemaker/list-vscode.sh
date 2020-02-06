#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# shellcheck disable=SC1090
. "$(realpath "$script_dir/func.processList.sh")"

vscode_list=$(realpath "$script_dir/../../list.vscode.txt")

processList "code --list-extensions" "$vscode_list"
