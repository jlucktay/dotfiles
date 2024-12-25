declare eval_brew=""

# If Homebrew/Linuxbrew is installed, do the thing.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval_brew="$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval_brew="$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Even when neither of the 'if's come true, 'eval'ing an empty string has no effect.
eval "$eval_brew"
unset eval_brew

# If we start using other package managers on other non-macOS systems, we will have a way in available here.
export package_manager_prefix="${HOMEBREW_PREFIX:-"/usr/local"}"
