#!/usr/bin/env bash
set -euo pipefail

background_white="$(tput setab 7)"
foreground_black="$(tput setaf 0)"
reset_colours="$(tput sgr0)"

echo "$background_white$foreground_black\$PATH unsorted:$reset_colours"

tr ':' '\n' <<< "$PATH"

echo
echo "$background_white$foreground_black\$PATH sorted:$reset_colours"

tr ':' '\n' <<< "$PATH" | sort -f
