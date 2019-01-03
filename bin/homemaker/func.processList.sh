#!/usr/bin/env bash

function processList(){
    # Parameter #1 is the timestamp to use in the header
    # Parameter #2 is the command to generate the list
    # Parameter #3 is the filename of the old archived list
    # Parameter #4 is the filename to put the new list in

    echo "# $1" > "$4"
    # Need this so that when 'find' hits directories with permission errors, or
    # 'diff' finds changes, they don't cause a stop on the non-zero exit code
    set +e
    eval "$2" | sort -f >> "$4"

    if [ -f "$3" ]; then
        # Compare the old archive file with the newly-created file
        DiffResult=$(diff --brief <(tail -n +2 "$3") <(tail -n +2 "$4") | wc -l)

        if ! ((DiffResult)); then
            # No difference, so delete the new file
            rm -f "$4"
        else
            rm -f "$3"
            mv -iv "$4" "$3"
        fi
    else
        mv -iv "$4" "$3"
    fi
}
