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

homebrew_tap_list=$(realpath "$chezmoi_source/lists/list.brew.tap.txt")
homebrew_list=$(realpath "$chezmoi_source/lists/list.brew.txt")
homebrew_cask_list=$(realpath "$chezmoi_source/lists/list.brew.cask.txt")

process_list "brew tap" "$homebrew_tap_list"
process_list "brew list -1" "$homebrew_list"
process_list "brew cask list -1" "$homebrew_cask_list"
