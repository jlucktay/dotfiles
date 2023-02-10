# Setup fzf
if [[ $PATH != *${package_manager_prefix:?}/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}${package_manager_prefix:?}/opt/fzf/bin"
fi

# Auto-completion
# shellcheck disable=SC1091
[[ $- == *i* ]] && source "${package_manager_prefix:?}/opt/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# shellcheck disable=SC1091
[[ -r ${package_manager_prefix:?}/opt/fzf/shell/key-bindings.bash ]] \
  && source "${package_manager_prefix:?}/opt/fzf/shell/key-bindings.bash"
