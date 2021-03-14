# Profile-specific exports

# prefix_path takes 1 argument that is a directory.
# If the given directory is already a part of PATH, it will be removed from its current position(s).
# It is then set at the front of PATH, to take highest priority in the search order.
function prefix_path() {
  # If argument is not a directory which exists, return non-zero early
  if ! test -d "${1:?}"; then
    return 1
  fi

  # Populate array with PATH
  IFS=':' read -ra split_path <<< "$PATH"

  # If argument already present, remove from its current index(es)
  for i in "${!split_path[@]}"; do
    if [[ ${split_path[i]} == "$1" ]]; then
      unset 'split_path[i]'
    fi
  done

  # Prepend argument; this will also remove any gaps created by 'unset' above
  split_path=("$1" "${split_path[@]}")

  # Generate a variable from array contents which contains the updated PATH
  set_path=$(
    IFS=':'
    echo "${split_path[*]}"
  )

  # Export updated PATH
  export PATH="$set_path"
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
