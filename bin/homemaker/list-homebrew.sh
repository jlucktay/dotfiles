#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# shellcheck source=/dev/null
. "$(realpath "$ScriptDirectory/func.processList.sh")"

Now=$(date +%Y%m%d.%H%M%S.%N%z)

HomebrewTapList=$(realpath "$ScriptDirectory/../../list.brew.tap.txt")
HomebrewTapListArchive=$(realpath "$ScriptDirectory/../../list.brew.tap.$Now.txt")
HomebrewList=$(realpath "$ScriptDirectory/../../list.brew.txt")
HomebrewListArchive=$(realpath "$ScriptDirectory/../../list.brew.$Now.txt")
HomebrewCaskList=$(realpath "$ScriptDirectory/../../list.brew.cask.txt")
HomebrewCaskListArchive=$(realpath "$ScriptDirectory/../../list.brew.cask.$Now.txt")

processList "$Now" "brew tap" "$HomebrewTapList" "$HomebrewTapListArchive"
processList "$Now" "brew list -1" "$HomebrewList" "$HomebrewListArchive"
processList "$Now" "brew cask list -1" "$HomebrewCaskList" "$HomebrewCaskListArchive"
