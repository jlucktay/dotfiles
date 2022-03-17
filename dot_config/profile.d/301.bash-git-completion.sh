# Bash completion
if test -r "/usr/local/etc/profile.d/bash_completion.sh"; then
  export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
  source "/usr/local/etc/profile.d/bash_completion.sh"
fi

# Git completion
if test -r "$HOME/git-completion.bash"; then
  # shellcheck disable=SC1091
  source "$HOME/git-completion.bash"
fi

# Kubernetes CLI
if command -v kubectl &> /dev/null; then
  complete -F __start_kubectl k
fi

# tfenv and Terraform
tfenv_prefix=$(brew --prefix tfenv)

tfenv_list_exit=0
tfenv list &> /dev/null || tfenv_list_exit=$?

if [[ -d $tfenv_prefix ]] && [[ $tfenv_list_exit -eq 0 ]] && [[ -r "$tfenv_prefix"/version ]] \
  && command -v terraform &> /dev/null; then

  complete -C "$tfenv_prefix"/versions/"$(< "$tfenv_prefix"/version)"/terraform terraform
fi
