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

git_list_cmd="find \"$HOME\" -type d -name \".git\" \
    -not -path \"*/.cache/*\" \
    -not -path \"*/.glide/cache/*\" \
    -not -path \"*/.terraform/*\" \
    -not -path \"*/go/pkg/dep/sources/*\" \
    -not -path \"*/Library/*\" \
    -execdir pwd \\; 2>/dev/null"
git_list=$(realpath "$chezmoi_source/lists/list.git.txt")

process_list "$git_list_cmd" "$git_list"
