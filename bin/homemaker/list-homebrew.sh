#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# shellcheck source=/dev/null
. "$(realpath "$ScriptDirectory/func.processList.sh")"

HomebrewTapList=$(realpath "$ScriptDirectory/../../list.brew.tap.txt")
HomebrewList=$(realpath "$ScriptDirectory/../../list.brew.txt")
HomebrewCaskList=$(realpath "$ScriptDirectory/../../list.brew.cask.txt")

# Make sure we're current before kicking off the lists
brew update

processList "brew tap" "$HomebrewTapList"
processList "brew list -1" "$HomebrewList"
processList "brew cask list -1" "$HomebrewCaskList"
