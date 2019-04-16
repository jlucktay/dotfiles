#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Background = white, foreground = black
ColoursHighlight="$(tput setab 7 ; tput setaf 0)"
ColoursReset="$(tput sgr0)"

mapfile -t RemoteLines < <(git remote -v 2>/dev/null)
if (( ${#RemoteLines[@]} == 0 )); then
    exit 0
fi

Path="$(realpath . | cut -d'/' -f5-)"
Repo="https://${Path}.git"

echo "Repo: '${ColoursHighlight}${Repo}${ColoursReset}'"

echo "git remote set-url origin $Repo"
git remote set-url origin "$Repo"
echo "git remote set-url --push origin $Repo"
git remote set-url --push origin "$Repo"
