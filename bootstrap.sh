#!/usr/bin/env bash
set -euo pipefail

if ! command -v chezmoi &> /dev/null; then
  curl --fail --location --silent https://git.io/chezmoi | BINDIR="$HOME/bin" sh
  sudo mv "$HOME"/bin/chezmoi /usr/local/bin
else
  chezmoi upgrade --executable=/usr/local/bin/chezmoi
fi

chezmoi_args=(
  init
  jlucktay
  --apply
  --depth 1
  --force
)

if [[ ${CHEZMOI_PURGE:-0} == 1 ]]; then
  chezmoi_args+=(--purge)
fi

chezmoi "${chezmoi_args[@]}"
