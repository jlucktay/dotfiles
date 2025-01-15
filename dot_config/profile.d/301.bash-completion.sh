# Bash completion
if [[ -r "${package_manager_prefix:?}/etc/profile.d/bash_completion.sh" ]]; then
  # export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"

  # shellcheck disable=SC1091
  source "${package_manager_prefix:?}/etc/profile.d/bash_completion.sh"
fi

# Git completion
if command -v git &> /dev/null && [[ -r "$HOME/git-completion.bash" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/git-completion.bash"
fi

# Jira CLI
if command -v jira &> /dev/null; then
  jira_completion_bash=$(jira completion bash)

  # shellcheck source=/dev/null
  source <(echo "$jira_completion_bash")

  unset jira_completion_bash
fi

# Kubernetes CLI, via mise.
# This is a kludge around Rancher Desktop still being in front (PATH-wise) of mise at this stage of shell initialisation.
# There is a 'touch' command to bump the mise global config file and trigger the aggressive PATH-first behaviour.
# However, that won't take effect until a prompt appears and the mise hook is fired.
if mwk=$(mise which kubectl); then
  kubectl_completion_bash=$($mwk completion bash)

  # shellcheck source=/dev/null
  source <(echo "$kubectl_completion_bash")

  unset kubectl_completion_bash

  alias k=kubectl
  complete -o default -F __start_kubectl k
fi

# Nomad CLI
if [[ -x "${package_manager_prefix:?}/bin/nomad" ]]; then
  complete -C "${package_manager_prefix:?}/bin/nomad" nomad
fi

# SeaweedFS
if [[ -x "${package_manager_prefix:?}/bin/weed" ]]; then
  complete -C "${package_manager_prefix:?}/bin/weed" weed
fi

# tabtab
if [[ -r "$HOME/.config/tabtab/bash/__tabtab.bash" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.config/tabtab/bash/__tabtab.bash"
fi

# Terraform
if [[ -x "${package_manager_prefix:?}/bin/terraform" ]]; then
  complete -C "${package_manager_prefix:?}/bin/terraform" terraform
fi

# Timoni
if command -v timoni > /dev/null; then
  timoni_completion_bash=$(timoni completion bash)

  # shellcheck source=/dev/null
  source <(echo "$timoni_completion_bash")

  unset timoni_completion_bash
fi

# Warp CLI - Cloudflare
if command -v warp-cli > /dev/null; then
  warp_cli_generate_completions_bash=$(warp-cli generate-completions bash)

  # shellcheck source=/dev/null
  source <(echo "$warp_cli_generate_completions_bash")

  unset warp_cli_generate_completions_bash
fi
