# Prompt setup
if command -v starship &> /dev/null; then
  sib=$(starship init bash)
  eval "$sib"
elif command -v git &> /dev/null && test -r "$HOME/posh-git-prompt.sh"; then
  ## Git info in the prompt
  # shellcheck disable=SC1091
  source "$HOME/posh-git-prompt.sh"
fi

if ! command -v starship &> /dev/null; then
  # Thanks to:
  # https://github.com/demure/dotfiles/blob/master/subbash/prompt
  # https://brettterpstra.com/2009/11/17/my-new-favorite-bash-prompt/
  # https://github.com/jonmosco/kube-ps1

  # Func to generate prompt after each command
  __prompt_command() {
    local last_exit_code=$? # This needs to be first

    local Reset='\[\e[0m\]'
    local IRed='\[\e[0;91m\]'
    local IGre='\[\e[0;92m\]'
    local IYel='\[\e[0;93m\]'
    # local IBlu='\[\e[0;94m\]'
    local IPur='\[\e[0;95m\]'
    local ICya='\[\e[0;96m\]'
    local IWhi='\[\e[0;97m\]'

    PS1="$ICya\u$IWhi@$IPur\h $IGre\t"    # Username at host, time (24h)
    PS1+=" $IWhi"'['"$IYel\W$IWhi]$Reset" # Working directory, trimmed
    # The '[' on the line above gets special treatment to avoid shellharden's zealotry

    # Kubernetes status
    if type kube_ps1 &> /dev/null; then
      # Assume enabled by default
      if [[ ${KUBE_PS1_ENABLED:-on} != "off" ]]; then
        PS1+=' $(kube_ps1)'
      fi
    fi

    # Git status
    if type __posh_git_echo &> /dev/null; then
      PS1+="$(__posh_git_echo)"
    fi

    # Optional exit code
    if [[ $last_exit_code -eq 0 ]]; then
      PS1+=" ✅"
    else
      PS1+=" ❌ $IRed$last_exit_code$Reset"
    fi

    PS1+="\n$IWhi\$$Reset "
  }

  PROMPT_COMMAND=__prompt_command

  ### https://github.com/lyze/posh-git-sh/issues/42
  ### -> https://github.com/lyze/posh-git-sh/pull/61

  if test -r "${package_manager_prefix:?}/opt/kube-ps1/share/kube-ps1.sh"; then
    # shellcheck disable=SC1091
    source "${package_manager_prefix:?}/opt/kube-ps1/share/kube-ps1.sh"
  fi

  # I'm pretty sure kube-ps1 refers to this as 'cluster' when it should say 'context'.
  __kp_get_cluster() {
    local output=$1

    # Trim prefix/suffix, if present.
    output=${output#"gke_"}
    output=${output%"_europe-west1_trading-gke-cluster"}

    echo "$output"
  }

  export KUBE_PS1_CLUSTER_FUNCTION=__kp_get_cluster
  export KUBE_PS1_CTX_COLOR='214'
  export KUBE_PS1_NS_COLOR=white
  export KUBE_PS1_PREFIX_COLOR='255'
  export KUBE_PS1_SUFFIX_COLOR='255'
  export KUBE_PS1_SYMBOL_ENABLE=false
fi
