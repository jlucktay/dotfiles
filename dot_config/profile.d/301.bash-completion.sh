# Before making changes:
# - if it's a mise tool, then usage-cli will (probably) have it covered
# - check presence/absence of completions with 'complete -p <tool>'
#   - force usage-cli to invoke by entering the command and hitting TAB before checking with 'complete -p'
# - does Homebrew have completions covered for <tool>?
#   - is there a completions script in one of the applicable directories?
#   - see also: https://github.com/orgs/Homebrew/discussions/4202
#
# Directories with bash-completion things:
# - /opt/homebrew/Cellar/bash-completion@2/2.16.0/share/bash-completion/completions/
# - /opt/homebrew/etc/bash_completion.d/
# - /opt/homebrew/Library/Homebrew/completions/
# - $BASH_COMPLETION_COMPAT_DIR
# - $HOME/.bash_completion
# - $HOME/.local/share/bash-completion/completions/

# Bash completion
if [[ -r "${package_manager_prefix:?}/etc/profile.d/bash_completion.sh" ]]; then
  # export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"

  # shellcheck disable=SC1091
  source "$package_manager_prefix/etc/profile.d/bash_completion.sh"
fi

# Kubernetes CLI, via mise.
# This is a kludge around Rancher Desktop still being in front (PATH-wise) of mise at this stage of shell initialisation.
# There is a 'touch' command to bump the mise global config file and trigger mise's 'activate_aggressive' PATH-first behaviour.
# However, that won't take effect until a prompt appears and the mise hook is fired.
if _mwk=$(mise which kubectl); then
  _kubectl_completion_bash=$($_mwk completion bash)

  # shellcheck source=/dev/null
  source <(echo "$_kubectl_completion_bash")

  unset _kubectl_completion_bash

  alias k=kubectl
  complete -o default -F __start_kubectl k
fi

unset _mwk

declare -a _tools_completion_bash=(
  "cobra-cli completion bash 2> /dev/null"
  "docker completion bash"
  "gup completion bash"
  "helm completion bash"
  "jira completion bash"
  "kondo --completions bash 2> /dev/null"
  "miniserve --print-completions bash"
  # "mise completion bash" # 'mise' is a function
  "nerdctl completion bash"
  "octocov completion bash"
  "op completion bash"
  "rclone completion bash -"
  "rdctl completion bash"
  "rustup completions bash cargo"
  "rustup completions bash rustup"
  "starship completions bash"
  "warp-cli generate-completions bash"
)

declare _bash_completion_dir="$HOME/.local/share/bash-completion/completions"

for _tcb in "${_tools_completion_bash[@]}"; do
  # Split the command up into an array with 'read' and the internal field separator set to a space.
  IFS=' ' read -ra arrTCB <<< "$_tcb"

  # The first element/word is the command generating the completion.
  if ! _tool_path=$(command -v "${arrTCB[0]}"); then
    printf >&2 "%80s: could not find command '%s'\n" "${BASH_SOURCE[0]}:$LINENO" "${arrTCB[0]}"

    continue
  fi

  if complete -p "${arrTCB[0]}" 2> /dev/null; then
    printf >&2 "%80s: bash completions are already in place for the '%s' command\n" "${BASH_SOURCE[0]}:$LINENO" "${arrTCB[0]}"

    continue
  fi

  # If the tool is installed by and being run through mise, then usage-cli should take care of generating its completions in a just-in-time fashion.
  if [[ $_tool_path == "$HOME/.local/share/mise/installs/"* ]]; then
    printf >&2 "%80s: bash completions for '${arrTCB[0]}' should already be handled through usage-cli\n" "${BASH_SOURCE[0]}:$LINENO" "${arrTCB[0]}"

    continue
  fi

  declare -i _tool_completion_regenerate=0
  declare _tool_completion_file="$_bash_completion_dir/${arrTCB[0]}"
  _tool_type=$(type -t "${arrTCB[0]}")

  if [[ $_tool_type != "file" ]]; then
    printf >&2 "%s:%s: tool type of '%s' is not a file, it is a %s\n" "${BASH_SOURCE[0]}" "$LINENO" "${arrTCB[0]}" "$_tool_type"

    continue
  fi

  # Check if the completion file exists, and whether it is older than the tool itself and needs to be regenerated.
  if _tool_completion_file_stat=$(gstat --printf='%Y' "$_tool_completion_file" 2> /dev/null); then
    _tool_stat=$(gstat --printf='%Y' "$_tool_path")

    if ((_tool_stat > _tool_completion_file_stat)); then
      printf >&2 "%80s: tool '%s' is newer than its completions; need to regenerate\n" "${BASH_SOURCE[0]}:$LINENO" "${arrTCB[0]}"

      _tool_completion_regenerate=1
    fi

    unset _tool_stat
  else
    _tool_completion_regenerate=1
  fi

  if ((_tool_completion_regenerate == 0)); then
    # Completions for the tool appear to be present and up to date.
    continue
  fi

  _epoch_regen_start=$EPOCHREALTIME

  # Attempt to capture the tool's Bash completion script.
  if ! _tool_completion_bash=$(eval "$_tcb"); then
    printf >&2 "%80s: could not capture completion script for command '%s'\n" "${BASH_SOURCE[0]}:$LINENO" "${arrTCB[0]}"

    continue
  fi

  # Write the tool's completion script out to our directory, so that the 'bash_completion.sh' line at the top of this file will catch it next time.
  echo "$_tool_completion_bash" > "$_tool_completion_file"

  # Source the file from the directory.
  # shellcheck source=/dev/null
  source "$_tool_completion_file"

  _epoch_regen_diff_ms=$(bc --expression="($EPOCHREALTIME - $_epoch_regen_start) * 1000" --mathlib)

  printf >&2 "%80s: regenerated completions for command '%s' in %.0fms\n" "${BASH_SOURCE[0]}:$LINENO" "${arrTCB[0]}" "$_epoch_regen_diff_ms"

  unset _epoch_regen_diff_ms _epoch_regen_start _tcb _tool_completion_bash _tool_completion_file _tool_completion_file_stat _tool_completion_regenerate _tool_path _tool_type
done

unset _bash_completion_dir _tools_completion_bash
