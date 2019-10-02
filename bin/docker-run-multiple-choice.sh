#!/usr/bin/env bash

# Thank you: https://github.com/anordal/shellharden/blob/master/how_to_do_things_safely_in_bash.md#how-to-begin-a-bash-script
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
shopt -s nullglob globstar
IFS=$'\n\t'

ScriptName=$(basename "$0")

### Check for presence of other tools

# Azure CLI
hash az 2>/dev/null || {
    echo >&2 "$ScriptName requires 'az' but it's not installed: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
}

# JQ
hash jq 2>/dev/null || {
    echo >&2 "$ScriptName requires 'jq' but it's not installed: https://github.com/stedolan/jq/wiki/Installation"
    exit 1
}

### Set up usage/help output
function usage() {
    cat << HEREDOC

    Usage: $ScriptName [--help] [--interactive] [--local|--remote]

    Optional arguments:
        -h, --help          show this help message and exit
        -i, --interactive   run the container interactively, rather than following the entrypoint

    Mutually exclusive options to select Docker image:
        -l, --local         run from a local image (default behaviour)
        -r, --remote        run from the image in the Azure container registry

HEREDOC
}

### Get flags ready to parse given arguments
INTERACTIVE=0
LOCAL=0
REMOTE=0

for i in "$@"; do
    case $i in
        -h|--help)
            usage;          exit 0;;
        -i|--interactive)
            INTERACTIVE=1;  shift;;
        -l|--local)
            LOCAL=1;        shift;;
        -r|--remote)
            REMOTE=1;       shift;;
        *) # unknown option
            usage;          exit 1;;
    esac
done

if [ $LOCAL == 1 ] && [ $REMOTE == 1 ]; then
    echo "'--local' and '--remote' are mutually exclusive!"
    exit 1
fi

# $LOCAL is default behaviour
IMAGE="jlucktay/hello-world:local-dev"

if [ $REMOTE == 1 ]; then
    IMAGE="jlucktay/hello-world:latest"
    echo "Running image with 'latest' tag: $IMAGE"
else
    echo "Running local dev image: $IMAGE"
fi

### Secrets
echo -n "Fetching a secret ... "
MY_SECRET=$(az keyvault secret show \
    --id="https://secrets-store.vault.azure.net/secrets/my-secret" \
    | jq -r '.value')
echo "Done."
export MY_SECRET

echo "Exported secret(s) to environment. (MY_SECRET)."

### Build arguments list for Docker
DockerArgs=(run --env MY_SECRET)

if [ $INTERACTIVE == 1 ]; then
    DockerArgs+=(--entrypoint /bin/sh --interactive --tty)
fi

DockerArgs+=(--rm --volume "$(pwd):/gitrepo" "$IMAGE")

### Show arguments and execute with them
echo "Running Docker with following arguments:"
echo "${DockerArgs[@]}"

docker "${DockerArgs[@]}"
