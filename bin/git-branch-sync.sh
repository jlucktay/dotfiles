#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

currentBranch="$(git branch 2>/dev/null | grep "\\*" | cut -d ' ' -f2)"

if [[ "$currentBranch" = "" ]]; then exit 0; fi

# Background = white, foreground = black
coloursHighlight="$(tput setab 7 ; tput setaf 0)"
coloursReset="$(tput sgr0)"

for branch in $(git for-each-ref --format='%(refname)' refs/heads/ | cut -d"/" -f3-); do
    echo "Start  - $coloursHighlight$branch$coloursReset"

    git checkout "$branch"
    git fetch
    git status

    echo "Finish - $coloursHighlight$branch$coloursReset"
done

git checkout "$currentBranch"
