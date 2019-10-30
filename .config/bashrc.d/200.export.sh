### Environment variables

# Go
GOPATH=$(go env GOPATH)
export GOPATH
GOROOT=$(go env GOROOT)
export GOROOT

# Build up PATH
PATH="$HOME/bin:$GOPATH/bin:$PATH"
export PATH

# If I have to edit something in a terminal window, I like using Nano. The up-to-date version, from Homebrew.
export EDITOR=/usr/local/bin/nano

# GPG things
GPG_TTY=$(tty)
export GPG_TTY

# Colourful terminal
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# AWS SDK for Go
export AWS_SDK_LOAD_CONFIG=true

# Homebrew - show off timings
export HOMEBREW_DISPLAY_INSTALL_TIMES=1

# https://swarm.cs.pub.ro/~razvan/blog/some-bash-tricks-cdpath-and-inputrc/
CDPATH="."
export CDPATH
