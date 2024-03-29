# Bash completion
if [[ -r "${package_manager_prefix:?}/etc/profile.d/bash_completion.sh" ]]; then
  # export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"

  # shellcheck disable=SC1091
  source "${package_manager_prefix:?}/etc/profile.d/bash_completion.sh"
fi

# Completion via tabtab
if [[ -r "$HOME/.config/tabtab/bash/__tabtab.bash" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.config/tabtab/bash/__tabtab.bash"
fi

# Git completion
if command -v git &> /dev/null && [[ -r "$HOME/git-completion.bash" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/git-completion.bash"
fi

# Kubernetes CLI
if command -v kubectl &> /dev/null; then
  complete -F __start_kubectl k
fi

# Nomad CLI
if [[ -x "${package_manager_prefix:?}/bin/nomad" ]]; then
  complete -C "${package_manager_prefix:?}/bin/nomad" nomad
fi

# SeaweedFS
if [[ -x "${package_manager_prefix:?}/bin/weed" ]]; then
  complete -C "${package_manager_prefix:?}/bin/weed" weed
fi

# Terraform
if [[ -x "${package_manager_prefix:?}/bin/terraform" ]]; then
  complete -C "${package_manager_prefix:?}/bin/terraform" terraform
fi
