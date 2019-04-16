#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CurrentBranch="$(git branch 2>/dev/null | grep "\\*" | cut -d ' ' -f2)"

if [[ "$CurrentBranch" = "" ]]; then exit 0; fi

# Background = white, foreground = black
ColoursHighlight="$(tput setab 7 ; tput setaf 0)"
ColoursReset="$(tput sgr0)"

git fetch --all

for Branch in $(git for-each-ref --format='%(refname)' refs/heads/ | cut -d"/" -f3-); do
    echo "Start  - $ColoursHighlight$Branch$ColoursReset"

    git checkout "$Branch"
    git status

    echo "Finish - $ColoursHighlight$Branch$ColoursReset"
done

git checkout "$CurrentBranch"
