if command -v git &> /dev/null && command -v rg &> /dev/null && command -v awk &> /dev/null \
  && command -v xargs &> /dev/null; then
  function gp() {
    local -
    set -o pipefail

    if ! git_wip=$(git log --oneline origin/HEAD.. | rg '(WIP:|fixup!) ' | awk '{ print $1 }' | xargs git show); then
      return
    fi

    if [[ $git_wip != "" ]]; then
      echo "WIP!"
      echo
      echo "$git_wip"

      return 1
    fi

    git push "$@"
  }

  export -f gp

  function gpsu() {
    local git_sr_head
    git_sr_head=$(git symbolic-ref --short HEAD)

    gp --set-upstream origin "$git_sr_head" "$@"
  }

  export -f gpsu
fi
