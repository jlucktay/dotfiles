#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Background = white
coloursBackgroundWhite="$(tput setab 7)"
# Foreground = black
coloursForegroundBlack="$(tput setaf 0)"
# Reset colours
coloursReset="$(tput sgr0)"

echo "$coloursBackgroundWhite${coloursForegroundBlack}PATH unsorted:$coloursReset"

while IFS=':' read -ra SPLITPATH; do
    # Split off sorted $PATH array for later output
    IFS=$'\n' mapfile -t SORTEDPATH < <(sort -f <<< "${SPLITPATH[*]}")

    # Show unsorted $PATH now
    for i in "${SPLITPATH[@]}"; do
        echo "$i"
    done
done <<< "$PATH"

echo
echo "$coloursBackgroundWhite${coloursForegroundBlack}PATH sorted:$coloursReset"

for i in "${SORTEDPATH[@]}"; do
    echo "$i"
done
