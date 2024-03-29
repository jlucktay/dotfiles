if command -v git &> /dev/null && command -v rg &> /dev/null && command -v awk &> /dev/null \
  && command -v xargs &> /dev/null; then
  function gp() {
    local -
    set -o pipefail

    git_wip=$(git log --oneline origin/HEAD.. | rg '(WIP:|fixup!) ' | awk '{ print $1 }' | xargs git show)

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
