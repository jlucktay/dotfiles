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

go_bin_list_cmd="find ${GOPATH:?}/bin -type f"
go_bin_list=$(realpath "$chezmoi_source/lists/list.go.bin.txt")

process_list "$go_bin_list_cmd" "$go_bin_list"
