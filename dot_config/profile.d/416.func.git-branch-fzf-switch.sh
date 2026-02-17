if command -v fzf &> /dev/null && command -v git &> /dev/null; then
	# gbfs: git branch fzf switch
	# Gives an interactive list of local and remote branches that can be (1) searched and (2) selected to be checked out.
	function gbfs() {
		local -
		set -o pipefail

		git_branch_all_format=$(git branch --all --format='%(refname)' | grep --invert-match HEAD)
		mapfile -t git_branches <<< "$git_branch_all_format"

		declare -A unique_branches

		# Trim a prefix from each array element with '${parameter#word}' expansion.
		for branch in "${git_branches[@]#refs/@(heads|remotes)/}"; do
			unique_branches[$branch]=0
		done

		branch_keys="${!unique_branches[*]}"

		declare -a fzf_flags=(
			--cycle
			--exit-0
			--preview 'git show --color=always {}'
			--select-1
			--tac
		)

		if [[ -z ${1:+is_set} ]]; then
			# $1 is nil -> no-op
			:
		elif [[ $1 == "-" ]]; then
			# If switching to the previous branch by calling 'gbfs -', just go ahead and do it without spinning up fzf.
			git switch -
			return $?
		else
			# For the 'fzf' call below, if $1 is not nil nor '-', set '--query' to $1
			fzf_flags+=(
				--query="$1"
			)
		fi

		# Convert spaces into newlines with the '-e' flag of 'echo', then send the keys to 'fzf' to get a choice.
		branch_choice=$(echo -e "${branch_keys// /\\n}" \
			| sort --ignore-case \
			| fzf "${fzf_flags[@]}")

		# If no branch choice was made, e.g. ESC was pressed during the 'fzf' call, we're done here.
		if [[ -z $branch_choice ]]; then
			return 0
		fi

		# If the branch choice starts with a '<remote>/' prefix, trim it.
		git_remote=$(git remote)
		mapfile -t git_remotes <<< "$git_remote"

		for remote in "${git_remotes[@]}"; do
			if [[ $branch_choice == ${remote}/* ]]; then
				# Trim the prefix (if present) from the ref, with '${parameter#word}' expansion.
				branch_choice="${branch_choice#"${remote}"/}"
				break
			fi
		done

		git switch "$branch_choice"
	}
fi
