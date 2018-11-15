#!/usr/bin/env bash
set +e -u
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# shellcheck source=/dev/null
. "$(realpath "$ScriptDirectory/func.processList.sh")"

Now=$(date +%Y%m%d.%H%M%S.%N%z)

HomebrewList=$(realpath "$ScriptDirectory/../../list.brew.txt")
HomebrewListArchive=$(realpath "$ScriptDirectory/../../list.brew.$Now.txt")
HomebrewCaskList=$(realpath "$ScriptDirectory/../../list.brew.cask.txt")
HomebrewCaskListArchive=$(realpath "$ScriptDirectory/../../list.brew.cask.$Now.txt")

processList "$Now" "brew list -1" "$HomebrewList" "$HomebrewListArchive"
processList "$Now" "brew cask list -1" "$HomebrewCaskList" "$HomebrewCaskListArchive"
