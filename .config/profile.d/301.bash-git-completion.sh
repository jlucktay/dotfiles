# Bash completion
if test -r "/usr/local/etc/profile.d/bash_completion.sh"; then
  export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
  source "/usr/local/etc/profile.d/bash_completion.sh"
fi

# Git completion
if test -r "$HOME/git-completion.bash"; then
  # shellcheck disable=SC1090
  source "$HOME/git-completion.bash"
fi
