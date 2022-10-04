# Setup fzf
if [[ $PATH != *${HOMEBREW_PREFIX:?}/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}${HOMEBREW_PREFIX:?}/opt/fzf/bin"
fi

# Auto-completion
# shellcheck disable=SC1091
[[ $- == *i* ]] && source "${HOMEBREW_PREFIX:?}/opt/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# shellcheck disable=SC1091
[[ -r ${HOMEBREW_PREFIX:?}/opt/fzf/shell/key-bindings.bash ]] \
  && source "${HOMEBREW_PREFIX:?}/opt/fzf/shell/key-bindings.bash"
