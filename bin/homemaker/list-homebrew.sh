#!/usr/bin/env bash
set +e -u
IFS=$'\n\t'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
Now=$(date +%Y%m%d.%H%M%S.%N%z)

HomebrewList=$(realpath "$DIR/../../brew.list.txt")
HomebrewListArchive=$(realpath "$DIR/../../brew.list.$Now.txt")
HomebrewCaskList=$(realpath "$DIR/../../brew.cask.list.txt")
HomebrewCaskListArchive=$(realpath "$DIR/../../brew.cask.list.$Now.txt")

function processHomebrewLists () {
    # echo "Parameter #1 is the command to generate the list: '$1'"
    # echo "Parameter #2 is the filename to put the new list in: '$2'"
    # echo "Parameter #3 is the filename to archive the old list to: '$3'"

    echo "# $Now" > "$3"
    eval "$1" >> "$3"

    if [ -f "$2" ]; then
        # Compare the old archive file with the newly-created file
        DiffResult=$(diff --brief <(tail -n +2 "$2") <(tail -n +2 "$3") | wc -l)

        if ! ((DiffResult)); then
            # No difference, so delete the new file
            rm -fv "$3"
        else
            rm -fv "$2"
            mv -iv "$3" "$2"
        fi
    else
        mv -iv "$3" "$2"
    fi
}

processHomebrewLists "brew list -1" "$HomebrewList" "$HomebrewListArchive"
processHomebrewLists "brew cask list -1" "$HomebrewCaskList" "$HomebrewCaskListArchive"
