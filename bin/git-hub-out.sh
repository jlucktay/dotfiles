#!/usr/local/bin/bash

# set -euo pipefail

IFS=$'\n\t'

cd /Users/jameslucktaylor/git || return

Base="$PWD"
Gits="$(find . -type d -depth 2)"

for Git in $Gits; do
    echo "Git: $Base/$Git"
    cd "$Base/$Git" || return

    # git remote -v | grep -i "github\\.com" >/dev/null

    if [[ -d ".git" ]]; then
        git remote -v
    #     # echo "Git repo!"
    #     echo "pwd: $(pwd)"
    #     # echo "basename: $(basename "$(pwd)")"
    #     Repo=$(basename "$(pwd)")
    #     cd ../.. || return
    #     gmv -iv "${Repo}" "${Repo}.1"
    #     gmv -iv "${Repo}.1/${Repo}" "${Repo}"
    #     grmdir -v "${Repo}.1"

    #     # gmkdir --parents --verbose "${Base}/github.com/${Git}"

    #     # strip one /section/ back from $Git before running 'gmv'
    #     # gmv -iv "${Base}/${Git}" "${Base}/github.com/${Git}"
    # # else
    #     # echo "NOT a repo :("
    fi

    echo
done

# currentBranch=$(git branch 2>/dev/null | grep "\\*" | cut -d ' ' -f2)

# if [[ "${currentBranch}" = "" ]]; then exit 0; fi

# # Background = white, foreground = black
# coloursHighlight=$(tput setab 7 ; tput setaf 0)
# coloursReset=$(tput sgr0)

# for branch in $(git for-each-ref --format='%(refname)' refs/heads/ | cut -d"/" -f3); do
# 	echo "Start  - ${coloursHighlight}${branch}${coloursReset}"

# 	git checkout "${branch}"
# 	git fetch
# 	git status

# 	echo "Finish - ${coloursHighlight}${branch}${coloursReset}"
# done

# git checkout "${currentBranch}"
