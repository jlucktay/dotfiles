#!/usr/bin/env bash

function processList(){
    # Parameter #1 is the command to generate the list
    # Parameter #2 is the filename of the old archived list

    TempList="$2.tmp"

    # Need this so that when 'find' hits directories with permission errors, or
    # 'diff' finds changes, they don't cause a stop on the non-zero exit code
    set +e
    eval "$1" | sort -f > "$TempList"

    if [ -f "$2" ]; then
        # Compare the old archive file with the newly-created file
        DiffResult=$(diff --brief <(tail -n +2 "$2") <(tail -n +2 "$TempList") | wc -l)

        if ! ((DiffResult)); then
            # No difference, so delete the new file
            rm -f "$TempList"
        else
            rm -f "$2"
            mv -iv "$TempList" "$2"
        fi
    else
        mv -iv "$TempList" "$2"
    fi
}
