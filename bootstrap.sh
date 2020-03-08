#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

cd "$HOME"
curl -sfL https://git.io/chezmoi | sh
"$HOME"/bin/chezmoi init --apply --verbose https://github.com/jlucktay/dotfiles.git
