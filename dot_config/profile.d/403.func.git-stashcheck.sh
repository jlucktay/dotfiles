if command -v git &> /dev/null; then
	function stashcheck() {
		local -
		set -o pipefail

		echo "[$(gdn || true)] ${FUNCNAME[0]}: finding git repos..."

		local git_repos
		git_repos=$(find "$HOME/git" -type d -name ".git")

		local -a repos
		mapfile -t repos <<< "$git_repos"

		echo "[$(gdn || true)] ${FUNCNAME[0]}: found ${#repos[@]} git repo(s)."

		local -i i
		for ((i = 0; i < ${#repos[@]}; i++)); do
			local git_stash_list
			git_stash_list=$(GIT_DIR="${repos[$i]}" git stash list)

			local -a stash
			mapfile -t stash <<< "$git_stash_list"

			if ((${#stash[@]} >= 1)) && [[ -n ${stash[0]} ]]; then
				realpath "${repos[$i]}/.."

				local stash_line
				for stash_line in "${stash[@]}"; do
					printf "\t%s\n" "$stash_line"
				done
			fi
		done
	}
fi
