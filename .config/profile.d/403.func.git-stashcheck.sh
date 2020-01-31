function stashcheck() {
  while IFS= read -d '' -r git; do
    mapfile -t stash < <(GIT_DIR="$git" git stash list)

    if ((${#stash[@]} > 0)); then
      realpath "$git/.."
    fi
    for stash_line in "${stash[@]}"; do
      printf "\t%s\n" "$stash_line"
    done
  done < <(find "$HOME/go/src" "$HOME/git" -type d -name ".git" -print0)
}
