# Profile-specific exports

# prefix_path takes 1 argument that is a directory.
# If the given directory is already a part of PATH, it will be removed from its current position(s).
# It is then set at the front of PATH, to take highest priority in the search order.
function prefix_path() {
  # If argument is not a directory which exists, return early.
  if ! test -d "${1:?}"; then
    return 0
  fi

  # Populate array with PATH.
  IFS=':' read -ra split_path <<< "$PATH"

  # If argument already present, remove from its current index(es).
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

# To be able to run kubectl plugins.
if command -v kubectl-krew &> /dev/null; then
  prefix_path "$HOME/.krew/bin"
fi

prefix_path "/usr/local/sbin"

# https://formulae.brew.sh/cask/google-cloud-sdk
if test -r "${package_manager_prefix:?}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"; then
  # shellcheck disable=SC1091
  source "$package_manager_prefix/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
fi

prefix_path "$package_manager_prefix/opt/curl/bin"
prefix_path "$package_manager_prefix/opt/libpq/bin"
prefix_path "$package_manager_prefix/opt/make/libexec/gnubin"
prefix_path "$package_manager_prefix/opt/openssl@1.1/bin" # https://formulae.brew.sh/formula/openssl@1.1
prefix_path "$HOME/.rd/bin"

# Homebrew.
prefix_path "$package_manager_prefix/bin"

# Python v3.12.
prefix_path "$package_manager_prefix/opt/python@3.12/libexec/bin"

# Ruby.
prefix_path "$package_manager_prefix/opt/ruby/bin"

# pnpm.
prefix_path "${PNPM_HOME:?}"

# Rust.
prefix_path "$package_manager_prefix/opt/rustup/bin"
prefix_path "$HOME/.cargo/bin"

# Scripts et al in my own '~/bin' directory.
prefix_path "$HOME/bin"

# Go.
if command -v go &> /dev/null; then
  tmp_gopath=$(go env GOPATH)
  prefix_path "$tmp_gopath/bin"
  unset -v tmp_gopath
fi

# Clean up the function and don't leave it lying around
unset -f prefix_path

# Touch the mise global config file to trigger aggressive behaviour and make sure its tools are at the front of PATH.
# https://github.com/jdx/mise/issues/3463
touch "$HOME/.config/mise/config.toml"

# https://swarm.cs.pub.ro/~razvan/blog/some-bash-tricks-cdpath-and-inputrc/
export CDPATH=":."

# https://github.com/stedolan/jq/issues/1972
if command -v jq &> /dev/null; then
  export JQ_COLORS='0;31:0;39:0;39:0;39:0;32:1;39:1;39'
fi

# Use cyan colour scaling for the dates column, as the default blue is difficult to read.
if command -v eza &> /dev/null; then
  export EZA_COLORS='da=36'
fi

# git-branchless
# https://github.com/arxanas/git-branchless/wiki/Installation
if command -v git &> /dev/null && command -v git-branchless &> /dev/null; then
  alias git='git-branchless wrap --'
fi

# cf. https://github.com/npryce/adr-tools/issues/68 https://github.com/npryce/adr-tools/issues/69
if command -v adr &> /dev/null; then
  export ADR_PAGER='less'
fi

# https://github.com/sharkdp/bat?tab=readme-ov-file#man
if command -v bat &> /dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# AWS CLI MITM
# https://ovotech.atlassian.net/wiki/spaces/OTKB/pages/4596302401/Certificate+Error+When+Connecting+to+Resources+via+ZTNA
if command -v aws &> /dev/null; then
  export AWS_CA_BUNDLE="$HOME/ztna-mitm/CA-Bundle-ZTNA.pem"
fi
