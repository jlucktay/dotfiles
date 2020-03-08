#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

cd "$HOME"
curl --fail --location --silent https://git.io/chezmoi | BINDIR=/usr/local/bin sudo --preserve-env=BINDIR sh
PATH=$HOME/bin:$PATH
chezmoi init --apply --verbose https://github.com/jlucktay/dotfiles.git
