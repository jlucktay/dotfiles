if command -v git &> /dev/null; then
	function stashcheck() {
		local -
		set -o pipefail

		echo "[$(gdn || true)] ${FUNCNAME[0]}: finding git repos..."

		git_repos=$(find "$HOME/git" -type d -name ".git")
		mapfile -t repos <<< "$git_repos"

		echo "[$(gdn || true)] ${FUNCNAME[0]}: found ${#repos[@]} git repo(s)."

		for ((i = 0; i < ${#repos[@]}; i++)); do
			git_stash_list=$(GIT_DIR="${repos[$i]}" git stash list)
			mapfile -t stash <<< "$git_stash_list"

			if ((${#stash[@]} >= 1)) && [[ -n ${stash[0]} ]]; then
				realpath "${repos[$i]}/.."

				for stash_line in "${stash[@]}"; do
					printf "\t%s\n" "$stash_line"
				done
			fi
		done
	}
fi
