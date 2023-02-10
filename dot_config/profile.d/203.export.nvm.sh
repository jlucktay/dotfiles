export NVM_DIR="$HOME/.nvm"

# This loads nvm, if nvm is installed.
if [[ -r "${package_manager_prefix:?}/opt/nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1091
  source "${package_manager_prefix:?}/opt/nvm/nvm.sh"
fi

# This loads nvm bash_completion, if nvm is installed.
if [[ -r "${package_manager_prefix:?}/opt/nvm/etc/bash_completion.d/nvm" ]]; then
  # shellcheck disable=SC1091
  source "${package_manager_prefix:?}/opt/nvm/etc/bash_completion.d/nvm"
fi
