## Prompt setup
# Git info in the prompt
if ! test -f "$HOME/posh-git-prompt.sh"; then
  echo "'$HOME/posh-git-prompt.sh' is not available: https://github.com/lyze/posh-git-sh"
  return 0
fi

# shellcheck disable=SC1091
source "$HOME/posh-git-prompt.sh"

# Thanks to:
# https://github.com/demure/dotfiles/blob/master/subbash/prompt
# https://brettterpstra.com/2009/11/17/my-new-favorite-bash-prompt/

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

  # Git status
  pge=$(__posh_git_echo)
  if [[ $pge != "" ]]; then
    PS1+="$pge"
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
