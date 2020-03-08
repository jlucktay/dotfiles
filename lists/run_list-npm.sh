#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"

# shellcheck disable=SC1090
source "$script_dir/func.process_list.sh"

npm_list_cmd="npm list --depth=0 --global --parseable"
npm_list=$(realpath "$script_dir/list.npm.txt")

process_list "$npm_list_cmd" "$npm_list"
