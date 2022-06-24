if command -v git &> /dev/null; then
  function stashcheck() {
    local -
    set -o pipefail

    find "$HOME/git" -type d -name ".git" -print0 | while IFS= read -d '' -r git; do
      git_stash_list=$(GIT_DIR="$git" git stash list)
      mapfile -t stash <<< "$git_stash_list"

      if ((${#stash[@]} > 0)); then
        realpath "$git/.."
      fi
      for stash_line in "${stash[@]}"; do
        printf "\t%s\n" "$stash_line"
      done
    done
  }
fi
