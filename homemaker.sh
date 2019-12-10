#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

homemaker_task=${1:-"default"}

reset_colour='\e[0m' # Text Reset
foreground_black='\e[0;30m'
background_white='\e[47m'

if [ "$homemaker_task" = "gitconfig" ]; then
  echo -e "${background_white}${foreground_black}Preserve any changes that may have been made in the interim, before clobbering '~/.gitconfig'!${reset_colour}"
fi

"$HOME/go/bin/homemaker" --task="$homemaker_task" --verbose config.toml "$script_dir"
