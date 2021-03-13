# Profile-specific exports
function prefix_path() {
  # if [[ ! ":${PATH}:" = *":${1}:"* ]]; then
  # fi
  if test -d "$1"; then
    export PATH="${1}${PATH:+:${PATH}}"
  fi
}

# Build up PATH
prefix_path "/usr/local/sbin"
prefix_path "/usr/local/opt/curl/bin"
prefix_path "/usr/local/opt/make/libexec/gnubin"
prefix_path "/usr/local/opt/openssl@1.1/bin" # https://formulae.brew.sh/formula/openssl@1.1
prefix_path "$HOME/.cargo/bin"

if [[ -v GOPATH ]]; then
  prefix_path "$GOPATH/bin"
fi

prefix_path "$HOME/bin"

# Keep this last to have highest priority
prefix_path "/usr/local/opt/go@1.15/bin"

# Set up Go environment around v1.15
if hash go 2> /dev/null; then
  GOPATH=$(go env GOPATH)
  export GOPATH
  GOROOT=$(go env GOROOT)
  export GOROOT

  # All modules all the time
  export GO111MODULE=on
fi

# https://swarm.cs.pub.ro/~razvan/blog/some-bash-tricks-cdpath-and-inputrc/
export CDPATH="."
