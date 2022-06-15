if command -v git &> /dev/null && command -v rg &> /dev/null && command -v awk &> /dev/null && command -v xargs &> /dev/null; then
  function gp() {
    local git_log_oneline
    git_log_oneline=$(git log --oneline origin/HEAD..)

    local rg_wip
    rg_wip=$(rg '(WIP:|fixup!) ' <<< "$git_log_oneline")

    local awk_output
    awk_output=$(awk '{ print $1 }' <<< "$rg_wip")

    local git_wip
    git_wip=$(xargs git show <<< "$awk_output")

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
