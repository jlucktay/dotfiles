#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

# Background = white, foreground = black
colours_highlight="$(
  tput setab 7
  tput setaf 0
)"
colours_reset="$(tput sgr0)"

mapfile -t remote_lines < <(git remote -v 2> /dev/null)
if [[ ${#remote_lines[@]} -eq 0 ]]; then
  exit 0
fi

path="$(realpath . | cut -d'/' -f5-)"
repo="https://$path.git"

echo "Repo: '$colours_highlight$repo$colours_reset'"

echo "git remote set-url origin $repo"
git remote set-url origin "$repo"
echo "git remote set-url --push origin $repo"
git remote set-url --push origin "$repo"
