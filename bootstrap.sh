#!/usr/bin/env bash
set -euo pipefail

curl --fail --location --silent https://git.io/chezmoi | BINDIR="$HOME/bin" sh
sudo mv "$HOME"/bin/chezmoi /usr/local/bin
chezmoi init --apply https://github.com/jlucktay/dotfiles.git
