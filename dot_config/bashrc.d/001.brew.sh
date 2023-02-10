# If Homebrew is installed, do the thing.
if test -x /opt/homebrew/bin/brew; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# If we start using other package managers on other non-macOS systems, we will have a way in available here.
export package_manager_prefix="${HOMEBREW_PREFIX:-"/usr/local"}"
