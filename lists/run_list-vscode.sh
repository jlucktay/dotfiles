#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

script_name=$(basename "${BASH_SOURCE[-1]}")

if ! chezmoi_source="$(chezmoi data | jq --exit-status --raw-output '.chezmoi.sourceDir')"; then
  echo "$script_name: couldn't fetch source directory from 'chezmoi data'"
  exit 1
fi

# shellcheck disable=SC1090
source "$chezmoi_source/lists/func.process_list.sh"

vscode_list_cmd="code --list-extensions"
vscode_list=$(realpath "$chezmoi_source/lists/list.vscode.txt")

process_list "$vscode_list_cmd" "$vscode_list"
