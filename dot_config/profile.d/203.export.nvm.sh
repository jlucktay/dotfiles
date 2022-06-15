export NVM_DIR="$HOME/.nvm"

# This loads nvm, if nvm is installed.
if [[ -s "/usr/local/opt/nvm/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  source "/usr/local/opt/nvm/nvm.sh"
fi

# This loads nvm bash_completion, if nvm is installed.
if [[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ]]; then
  # shellcheck source=/dev/null
  source "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
fi
