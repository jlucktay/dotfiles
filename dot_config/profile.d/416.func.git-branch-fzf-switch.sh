if command -v fzf &> /dev/null && command -v git &> /dev/null; then
  function gbfs() {
    local -
    set -o pipefail

    git branch | cut -c 3- | fzf --cycle --query="" --select-1 --exit-0 | xargs git switch
  }
fi
