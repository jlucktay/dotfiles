if command -v fzf &> /dev/null && command -v git &> /dev/null; then
  function gbfs() {
    local -
    set -o pipefail

    git branch | cut -c 2- | fzf | xargs git switch
  }
fi
