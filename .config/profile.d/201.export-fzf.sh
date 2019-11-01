# https://github.com/junegunn/fzf

export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(code {})+abort'"

# shellcheck disable=SC1090
[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"
