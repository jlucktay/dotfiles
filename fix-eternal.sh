#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

declare -A cmd_history

while IFS= read -r line; do
  timestamp=$(echo "$line" | gcut --characters=9-27)
  command=$(echo "$line" | gcut --characters=30-)
  epoch=$(gdate -d"$timestamp" +%s)

  cmd_history["$epoch"]="$command"
done < eternal.main.txt

# https://www.reddit.com/r/bash/comments/5wma5k/is_there_a_way_to_sort_an_associative_array_by/debbjsp/
mapfile -d '' sorted_keys < <(printf '%s\0' "${!cmd_history[@]}" | sort -z)

output_file=bash_eternal_history.$(gdate '+%Y%m%d.%H%M%S.%N%z')

for key in "${sorted_keys[@]}"; do
  printf '#%s\n%s\n' "$key" "${cmd_history[$key]}" >> "$output_file"
done
