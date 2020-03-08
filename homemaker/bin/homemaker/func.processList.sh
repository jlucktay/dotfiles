#!/usr/bin/env bash

function processList() {
  # Parameter #1 is the command to generate the list
  # Parameter #2 is the filename of the old archived list

  temp_list="$2.tmp"

  # Need this so that when 'find' hits directories with permission errors, or
  # 'diff' finds changes, they don't cause a stop on the non-zero exit code
  set +e
  eval "$1" | sort -f > "$temp_list"

  if [ -f "$2" ]; then
    # Compare the old archive file with the newly-created file
    diff_result=$(diff --brief <(tail -n +2 "$2") <(tail -n +2 "$temp_list") | wc -l)

    if ! ((diff_result)); then
      # No difference, so delete the new file
      rm -f "$temp_list"
    else
      rm -f "$2"
      mv -iv "$temp_list" "$2"
    fi
  else
    mv -iv "$temp_list" "$2"
  fi
}
