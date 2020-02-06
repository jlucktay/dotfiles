#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

homemaker_task=${1:-"default"}

reset_colour='\e[0m' # Text Reset
highlight='\e[0;30m''\e[47m'

if [ "$homemaker_task" = "gitconfig" ]; then
  echo -e "${highlight}Preserve any changes that may have been made in the interim, before clobbering '~/.gitconfig'!$reset_colour"
fi

"$HOME/go/bin/homemaker" --task="$homemaker_task" --verbose config.toml "$script_dir"
