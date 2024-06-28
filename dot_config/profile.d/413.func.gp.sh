if command -v git &> /dev/null && command -v rg &> /dev/null && command -v awk &> /dev/null \
  && command -v xargs &> /dev/null; then
  function gp() {
    local -
    set -o pipefail

    if ! git_log_head=$(git log --oneline origin/HEAD..); then
      echo "If 'origin/HEAD' is MIA, try running \`git remote set-head origin --auto\`."
      return 1
    fi

    git_wip=$(rg '(WIP:|fixup!) ' <<< "$git_log_head" | awk '{ print $1 }' | xargs git show)

    if [[ $git_wip != "" ]]; then
      echo "WIP!"
      echo
      echo "$git_wip"

      return 1
    fi

    git push "$@"
  }

  export -f gp
fi
