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

# Build up PATH in last->first order, on top of existing values inherited from:
# 1) the '/etc/paths' file, and
# 2) the files under the '/etc/paths.d/' directory

prefix_path "/usr/local/sbin"

# https://formulae.brew.sh/cask/google-cloud-sdk
if test -d /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk; then
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
fi

prefix_path "/usr/local/opt/curl/bin"
prefix_path "/usr/local/opt/make/libexec/gnubin"
prefix_path "/usr/local/opt/openssl@1.1/bin" # https://formulae.brew.sh/formula/openssl@1.1
prefix_path "$HOME/.cargo/bin"
prefix_path "$HOME/bin"

# Keep these Go paths last, to have highest priority
prefix_path "/usr/local/opt/go@1.17/bin" # pin to 1.17 until late 2022 when 1.19 drops, and then we will go up to 1.18

if command -v go &> /dev/null; then
  tmp_gopath=$(go env GOPATH)
  prefix_path "$tmp_gopath/bin"
  unset -v tmp_gopath
fi

# Clean up the function and don't leave it lying around
unset -f prefix_path

# For Go, always use modules 👍
export GO111MODULE=on

# https://swarm.cs.pub.ro/~razvan/blog/some-bash-tricks-cdpath-and-inputrc/
export CDPATH=":."

# https://github.com/stedolan/jq/issues/1972
if command -v jq &> /dev/null; then
  export JQ_COLORS='0;31:0;39:0;39:0;39:0;32:1;39:1;39'
fi
