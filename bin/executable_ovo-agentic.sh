#!/usr/bin/env bash
set -euo pipefail

agentic_gits_raw=$(fd --hidden --type directory --no-ignore-vcs '^\.git$' "$HOME"/git/github.com/ovotech/evergreen-agentic)

mapfile -t agentic_gits <<< "$agentic_gits_raw"

for ag in "${agentic_gits[@]}"; do
	(
		set -x

		cd "${ag%"/.git/"}"

		git rs
		git worktree prune
		gh poi
	)

	current="$(git branch --show-current)"

	if [[ -z $current ]]; then
		echo >&2 "❌ Detached HEAD — refusing to guess a branch."
	elif [[ $current == "main" ]]; then
		(
			set -x
			git pull --ff-only origin main
		)
	else
		(
			set -x
			git fetch origin main:main
		)
	fi
done
