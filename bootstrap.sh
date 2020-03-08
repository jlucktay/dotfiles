#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

cd "$HOME"
curl -sfL https://git.io/chezmoi | sh
PATH=$HOME/bin:$PATH
chezmoi init --apply --verbose https://github.com/jlucktay/dotfiles.git
