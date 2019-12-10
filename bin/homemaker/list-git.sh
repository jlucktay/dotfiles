#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# shellcheck disable=SC1090
. "$(realpath "$script_dir/func.processList.sh")"

git_list_cmd="find \"$HOME\" -type d -name \".git\" \
    -not -path \"*/.cache/*\" \
    -not -path \"*/.glide/cache/*\" \
    -not -path \"*/.terraform/*\" \
    -not -path \"*/go/pkg/dep/sources/*\" \
    -execdir pwd \\; 2>/dev/null"
git_list=$(realpath "$script_dir/../../list.git.txt")

processList "$git_list_cmd" "$git_list"
