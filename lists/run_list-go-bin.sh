#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"

# shellcheck disable=SC1090
source "$script_dir/func.process_list.sh"

go_bin_list_cmd="find ${GOPATH:?}/bin -type f"
go_bin_list=$(realpath "$script_dir/list.go.bin.txt")

process_list "$go_bin_list_cmd" "$go_bin_list"
