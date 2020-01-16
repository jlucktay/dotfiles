### Environment variables

# Go
if hash go 2> /dev/null; then
  GOPATH=$(go env GOPATH)
  export GOPATH
  GOROOT=$(go env GOROOT)
  export GOROOT

  # All modules all the time
  export GO111MODULE=on
fi

# If I have to edit something in a terminal window, I like using Nano. The up-to-date version from Homebrew if present.
if test -x /usr/local/bin/nano; then
  export EDITOR=/usr/local/bin/nano
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
if hash brew 2> /dev/null; then
  export HOMEBREW_DISPLAY_INSTALL_TIMES=1
fi
