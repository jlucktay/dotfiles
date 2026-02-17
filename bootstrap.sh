#!/usr/bin/env bash
set -euo pipefail

if ! command -v chezmoi &> /dev/null; then
	curl --fail --location --silent https://raw.githubusercontent.com/twpayne/chezmoi/master/assets/scripts/install.sh \
		| BINDIR="$HOME/bin" sh
	sudo mkdir -p /usr/local/bin
	sudo mv "$HOME"/bin/chezmoi /usr/local/bin/chezmoi
fi

chezmoi_args=(
	init
	jlucktay
	--apply
	--depth 1
	--force
	--keep-going
)

if [[ ${CHEZMOI_PURGE:-0} == 1 ]]; then
	chezmoi_args+=(--purge)
fi

chezmoi "${chezmoi_args[@]}"
