#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# shellcheck disable=SC1090
. "$(realpath "$script_dir/func.processList.sh")"

go_bin_list_cmd="find ${GOPATH:?}/bin -type f"
go_bin_list=$(realpath "$script_dir/../../list.go.bin.txt")

processList "$go_bin_list_cmd" "$go_bin_list"
