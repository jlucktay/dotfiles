# Profile-specific exports

function prefix_path() {
    # if [[ ! ":${PATH}:" == *":${1}:"* ]]; then
        export PATH="${1}${PATH:+:${PATH}}"
    # fi
}

# Build up PATH
prefix_path "/usr/local/opt/curl/bin"
prefix_path "${GOPATH:-}/bin"
prefix_path "$HOME/bin"

# https://swarm.cs.pub.ro/~razvan/blog/some-bash-tricks-cdpath-and-inputrc/
CDPATH="."
export CDPATH
