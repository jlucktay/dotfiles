#!/usr/bin/env bash
set -euo pipefail
# set +e -u
IFS=$'\n\t'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
Now=$(date +%Y%m%d.%H%M%S.%N%z)

HomebrewList=$(realpath "$DIR/../../brew.list.txt")
HomebrewListArchive=$(realpath "$DIR/../../brew.list.$Now.txt")
HomebrewCaskList=$(realpath "$DIR/../../brew.cask.list.txt")
HomebrewCaskListArchive=$(realpath "$DIR/../../brew.cask.list.$Now.txt")

function processHomebrewLists () {
    echo "Parameter #1 is the command to generate the list: '$1'"
    echo "Parameter #2 is the filename to put the new list in: '$2'"
    echo "Parameter #3 is the filename to archive the old list to: '$3'"

    if [ -f "$2" ]; then
        mv -iv "$2" "$3"
    fi

    echo "# $Now" > "$2"
    eval "$1" >> "$2"

    if [ -f "$3" ]; then
        # Compare the old archive file with the newly-created file
        DiffResult=$(diff --brief <(tail -n +2 "$2") <(tail -n +2 "$3") | wc -l)

        if ! ((DiffResult)); then
            # No difference, so remove the archive
            rm -fv "$3"
        fi
    fi
}

processHomebrewLists "brew list -1" "$HomebrewList" "$HomebrewListArchive"
processHomebrewLists "brew cask list -1" "$HomebrewCaskList" "$HomebrewCaskListArchive"
