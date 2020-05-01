if hash git &> /dev/null && hash rg &> /dev/null && hash awk &> /dev/null && hash xargs &> /dev/null; then
  function gp() {
    git_wip=$(git log --oneline origin/master.. | rg --fixed-strings "WIP: " | awk '{ print $1 }' | xargs git show)

    if [ -n "$git_wip" ]; then
      echo "WIP!"
      echo
      echo "$git_wip"

      return 1
    fi

    git push "$@"
  }

  export -f gp
fi
