# Profile-specific exports
function prefix_path() {
  # If argument is not a directory which exists, return non-zero early
  if ! test -d "${1:?}"; then
    return 1
  fi

  # Populate "$split_path" array with $PATH
  while IFS=':' read -ra split_path; do
    : # no-op
  done <<< "$PATH"

  # Check if argument exists in the "$split_path" array
  if ! [[ ${split_path[*]} =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    # Prefix PATH (if set) with argument, and export
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

# Clean up the function and don't leave it lying around
unset -f prefix_path

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
