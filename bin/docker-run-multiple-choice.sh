#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

script_name=$(basename "${BASH_SOURCE[-1]}")

### Check for presence of other tools

# Azure CLI
hash az 2> /dev/null || {
  echo >&2 "$script_name requires 'az' but it's not installed: https://docs.microsoft.com/cli/azure/install-azure-cli"
  exit 1
}

# JQ
hash jq 2> /dev/null || {
  echo >&2 "$script_name requires 'jq' but it's not installed: https://github.com/stedolan/jq/wiki/Installation"
  exit 1
}

### Set up usage/help output
function usage() {
  cat << HEREDOC

    Usage: $script_name [--help] [--interactive] [--local|--remote]

    Optional arguments:
        -h, --help          show this help message and exit
        -i, --interactive   run the container interactively, rather than following the entrypoint

    Mutually exclusive options to select Docker image:
        -l, --local         run from a local image (default behaviour)
        -r, --remote        run from the image in the Azure container registry

HEREDOC
}

### Get flags ready to parse given arguments
interactive=0
local=0
remote=0

for i in "$@"; do
  case $i in
    -h | --help)
      usage
      exit 0
      ;;
    -i | --interactive)
      interactive=1
      shift
      ;;
    -l | --local)
      local=1
      shift
      ;;
    -r | --remote)
      remote=1
      shift
      ;;
    *) # unknown option
      usage
      exit 1
      ;;
  esac
done

if [ "$local" -eq 1 ] && [ "$remote" -eq 1 ]; then
  echo "'--local' and '--remote' are mutually exclusive!"
  exit 1
fi

# $local is default behaviour
image="jlucktay/hello-world:local-dev"

if [ "$remote" -eq 1 ]; then
  image="jlucktay/hello-world:latest"
  echo "Running image with 'latest' tag: $image"
else
  echo "Running local dev image: $image"
fi

### Secrets
echo -n "Fetching a secret... "
MY_SECRET=$(az keyvault secret show \
  --id="https://secrets-store.vault.azure.net/secrets/my-secret" \
  | jq -r '.value')
echo "Done."
export MY_SECRET

echo "Exported secret(s) to environment. (MY_SECRET)."

### Build arguments list for Docker
docker_args=(run --env MY_SECRET)

if [ "$interactive" -eq 1 ]; then
  docker_args+=(--entrypoint /bin/sh --interactive --tty)
fi

docker_args+=(--rm --volume "$(pwd):/gitrepo" "$image")

### Show arguments and execute with them
echo "Running Docker with following arguments:"
echo "${docker_args[@]}"

docker "${docker_args[@]}"
