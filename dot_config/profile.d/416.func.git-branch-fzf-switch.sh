if command -v fzf &> /dev/null && command -v git &> /dev/null; then
  # gbfs: git branch fzf switch
  # Gives an interactive list of local and remote branches that can be (1) searched and (2) selected to be checked out.
  function gbfs() {
    local -
    set -o pipefail

    git_branch_all_format=$(git branch --all --format='%(refname)' | grep --invert-match HEAD)
    mapfile -t git_branches <<< "$git_branch_all_format"

    declare -A unique_branches

    # Trim a prefix from each array element with '${parameter#word}' expansion.
    for branch in "${git_branches[@]#refs/@(heads|remotes)/}"; do
      unique_branches[$branch]=0
    done

    branch_keys="${!unique_branches[*]}"

    declare -a fzf_flags=(
      --cycle
      --exit-0
      --preview 'git show --color=always {}'
      --select-1
      --tac
    )

    # For the 'fzf' call below:
    # - if $1 is nil or '-', default the '--query' flag to the previous branch (if any)
    # - otherwise, set '--query' to $1
    declare default_query

    if [[ -z ${1:+is_set} ]] || [[ $1 == "-" ]]; then
      if previous_branch=$(git rev-parse --symbolic-full-name '@{-1}'); then
        # Trim the prefix (if present) from the ref, with '${parameter#word}' expansion.
        default_query=${previous_branch#refs/@(heads|remotes)/}
      fi
    else
      default_query=$1
    fi

    if current_branch=$(git rev-parse --symbolic-full-name HEAD); then
      if [[ $current_branch == "$previous_branch" ]]; then
        return 0
      fi
    fi

    # Always use the variable declared above, even if it's empty, because empty is still a valid query for fzf.
    fzf_flags+=(
      --query="$default_query"
    )

    # Convert spaces into newlines with the '-e' flag of 'echo', then send the keys to 'fzf' to get a choice.
    branch_choice=$(echo -e "${branch_keys// /\\n}" \
      | sort --ignore-case \
      | fzf "${fzf_flags[@]}")

    # If the branch choice starts with a '<remote>/' prefix, trim it.
    git_remote=$(git remote)
    mapfile -t git_remotes <<< "$git_remote"

    for remote in "${git_remotes[@]}"; do
      if [[ $branch_choice == ${remote}/* ]]; then
        branch_choice="${branch_choice#"${remote}"/}"
        break
      fi
    done

    # If no branch choice was made, e.g. ESC was pressed during the 'fzf' call, we're done here.
    if [[ -z $branch_choice ]]; then
      return 0
    fi

    git switch "$branch_choice"
  }
fi
