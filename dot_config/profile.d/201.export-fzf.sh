# https://github.com/junegunn/fzf
if command -v fzf &> /dev/null; then
  export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(code {})+abort'"
  fzf_bash=$(fzf --bash)
  eval "$fzf_bash"
  unset fzf_bash
fi
