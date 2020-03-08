#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

curl --fail --location --silent https://git.io/chezmoi | BINDIR="$HOME/bin" sh
sudo mv "$HOME"/bin/chezmoi /usr/local/bin
chezmoi init --apply --verbose https://github.com/jlucktay/dotfiles.git
