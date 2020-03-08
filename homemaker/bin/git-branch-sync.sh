#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

current_branch="$(git branch 2> /dev/null | grep '\*' | cut -d ' ' -f2)"

if [[ $current_branch == "" ]]; then exit 0; fi

# Background = white, foreground = black
colours_highlight="$(
  tput setab 7
  tput setaf 0
)"
colours_reset="$(tput sgr0)"

git fetch --all

mapfile -t branches < <(git for-each-ref --format='%(refname)' refs/heads/ | cut -d"/" -f3-)

for branch in "${branches[@]}"; do
  echo "Start  - $colours_highlight$branch$colours_reset"

  git checkout "$branch"
  git status

  echo "Finish - $colours_highlight$branch$colours_reset"
done

git checkout "$current_branch"
