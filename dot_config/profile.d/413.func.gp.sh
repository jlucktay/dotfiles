if hash git &> /dev/null && hash rg &> /dev/null && hash awk &> /dev/null && hash xargs &> /dev/null; then
  function gp() {
    git_wip=$(git log --oneline origin/HEAD.. | rg '(WIP:|fixup!) ' | awk '{ print $1 }' | xargs git show)

    if [ -n "$git_wip" ]; then
      echo "WIP!"
      echo
      echo "$git_wip"

      return 1
    fi

    git push "$@"
  }

  export -f gp

  function gpsu() {
    gp --set-upstream origin "$(git symbolic-ref --short HEAD)" "$@"
  }

  export -f gpsu
fi
