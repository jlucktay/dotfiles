#!/usr/bin/env bash
set -euo pipefail

curl --fail --location --silent https://git.io/chezmoi | BINDIR="$HOME/bin" sh
sudo mv "$HOME"/bin/chezmoi /usr/local/bin

chezmoi_args=(
  init
  jlucktay
  --apply
  --depth 1
  --force
)

if [ "${CHEZMOI_PURGE:-0}" == 1 ]; then
  chezmoi_args+=(--purge)
fi

chezmoi "${chezmoi_args[@]}"
