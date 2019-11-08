# https://github.com/junegunn/fzf
if test -f "$HOME/.fzf.bash"; then
    # shellcheck disable=SC1090
    source "$HOME/.fzf.bash"
    export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(code {})+abort'"
fi
