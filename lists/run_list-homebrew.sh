#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"

# shellcheck disable=SC1090
source "$script_dir/func.process_list.sh"

homebrew_tap_list=$(realpath "$script_dir/list.brew.tap.txt")
homebrew_list=$(realpath "$script_dir/list.brew.txt")
homebrew_cask_list=$(realpath "$script_dir/list.brew.cask.txt")

# Make sure we're current before kicking off the lists
brew update

process_list "brew tap" "$homebrew_tap_list"
process_list "brew list -1" "$homebrew_list"
process_list "brew cask list -1" "$homebrew_cask_list"
