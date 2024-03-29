### Environment variables

# If I have to edit something in a terminal window, I like using Nano. The up-to-date version from Homebrew if present.
if test -x "${package_manager_prefix:?}/bin/nano"; then
  export EDITOR="${package_manager_prefix:?}/bin/nano"
else
  export EDITOR=/usr/bin/nano
fi

# GPG things
GPG_TTY=$(tty)
export GPG_TTY

# Colourful terminal
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# AWS SDK for Go
export AWS_SDK_LOAD_CONFIG=true

# Homebrew - show off timings
if command -v brew &> /dev/null; then
  export HOMEBREW_DISPLAY_INSTALL_TIMES=1
fi
