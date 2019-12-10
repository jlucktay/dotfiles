#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# shellcheck disable=SC1090
. "$(realpath "$script_dir/func.processList.sh")"

homebrew_tap_list=$(realpath "$script_dir/../../list.brew.tap.txt")
homebrew_list=$(realpath "$script_dir/../../list.brew.txt")
homebrew_cask_list=$(realpath "$script_dir/../../list.brew.cask.txt")

# Make sure we're current before kicking off the lists
brew update

processList "brew tap" "$homebrew_tap_list"
processList "brew list -1" "$homebrew_list"
processList "brew cask list -1" "$homebrew_cask_list"
