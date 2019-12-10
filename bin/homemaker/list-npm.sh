#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# shellcheck disable=SC1090
. "$(realpath "$script_dir/func.processList.sh")"

npm_list_cmd="npm list --depth=0 --global --parseable"
npm_list=$(realpath "$script_dir/../../list.npm.txt")

processList "$npm_list_cmd" "$npm_list"
