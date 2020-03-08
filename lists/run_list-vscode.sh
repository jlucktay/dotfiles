#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"

# shellcheck disable=SC1090
source "$script_dir/func.process_list.sh"

vscode_list=$(realpath "$script_dir/list.vscode.txt")

process_list "code --list-extensions" "$vscode_list"
