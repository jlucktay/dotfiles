#!/usr/bin/env bash
set -euo pipefail

background_white="$(tput setab 7)"
foreground_black="$(tput setaf 0)"
reset_colours="$(tput sgr0)"

echo "$background_white${foreground_black}PATH unsorted:$reset_colours"

while IFS=':' read -ra split_path; do
  # Split off sorted $PATH array for later output
  IFS=$'\n' mapfile -t sorted_path < <(sort -f <<< "${split_path[*]}")

  # Show unsorted $PATH now
  for i in "${split_path[@]}"; do
    echo "$i"
  done
done <<< "$PATH"

echo
echo "$background_white${foreground_black}PATH sorted:$reset_colours"

for i in "${sorted_path[@]}"; do
  echo "$i"
done
