#!/usr/bin/env bash

function processList(){
    # Parameter #1 is the timestamp to use in the header
    # Parameter #2 is the command to generate the list
    # Parameter #3 is the filename to put the new list in
    # Parameter #4 is the filename to archive the old list to

    echo "# $1" > "$4"
    eval "$2" >> "$4"

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
