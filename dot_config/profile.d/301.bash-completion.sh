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

# Kubernetes CLI, via mise.
# This is a kludge around Rancher Desktop still being in front (PATH-wise) of mise at this stage of shell initialisation.
# There is a 'touch' command to bump the mise global config file and trigger mise's 'activate_aggressive' PATH-first behaviour.
# However, that won't take effect until a prompt appears and the mise hook is fired.
if mwk=$(mise which kubectl); then
  kubectl_completion_bash=$($mwk completion bash)

  # shellcheck source=/dev/null
  source <(echo "$kubectl_completion_bash")

  unset kubectl_completion_bash

  alias k=kubectl
  complete -o default -F __start_kubectl k
fi

# Terraform
if cmd_terraform=$(command -v terraform); then
  complete -C "$cmd_terraform" terraform
fi

declare -a tools_completion_bash=(
  "cobra-cli completion bash 2> /dev/null"
  "docker completion bash"
  "gup completion bash"
  "helm completion bash"
  "jira completion bash"
  "jj util completion bash"
  "kondo --completions bash 2> /dev/null"
  "miniserve --print-completions bash"
  "mise completion bash"
  "nerdctl completion bash"
  "octocov completion bash"
  "op completion bash"
  "pnpm completion bash"
  "rclone completion bash -"
  "rdctl completion bash"
  "rustup completions bash cargo"
  "rustup completions bash rustup"
  "starship completions bash"
  "terraform-docs completion bash"
  "warp-cli generate-completions bash"
)

for tcb in "${tools_completion_bash[@]}"; do
  # Split the command up into an array with 'read' and the internal field separator set to a space.
  IFS=' ' read -ra arrTCB <<< "$tcb"

  # The first element/word is the command generating the completion.
  if ! command -v "${arrTCB[0]}" > /dev/null; then
    echo >&2 "${BASH_SOURCE[0]}:$LINENO: could not find command '${arrTCB[0]}'"

    continue
  fi

  # Attempt to capture the tool's Bash completion script.
  if ! tool_completion_bash=$(eval "$tcb"); then
    echo >&2 "${BASH_SOURCE[0]}:$LINENO: could not capture completion script for command '${arrTCB[0]}'"

    continue
  fi

  # Execute the tool's captured completion script.
  # Note that 'source' must see the script variable as a file using '<(echo ...)' process substitution.
  # We cannot use a '<<<' here string to supply the value of the variable directly.
  # shellcheck source=/dev/null
  source <(echo "$tool_completion_bash")

  # Clear the captured completion script.
  unset tool_completion_bash
done

unset tools_completion_bash
