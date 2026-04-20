if ! command -v fzf &> /dev/null; then
	return 0
fi

# gitops_diff_tags: show me the diff of a Helm chart in the gitops repo between version release tags.
function gitops_diff_tags() {
	local -
	set -o pipefail

	if [[ $# -ne 1 ]]; then
		echo >&2 "error: must specify exactly one argument, ideally the name of a Helm chart in the gitops repo"

		return 1
	fi

	if ! [[ $1 =~ ^[a-z0-9-]+$ ]]; then
		echo >&2 "error: '$1' is not an alphanumeric string"

		return 2
	fi

	if ! [[ -d "$HOME"/git/github.com/ovotech/bedrock-platform-gitops/_bedrock-platform-gitops/helm/"$1" ]]; then
		echo >&2 "error: Helm chart '$1' not found in the gitops repo"

		return 3
	fi

	current_directory=$(pwd)
	trap 'cd $current_directory' RETURN

	cd "$HOME"/git/github.com/ovotech/bedrock-platform-gitops/_bedrock-platform-gitops || return

	old_tag="$(git tag --list | fzf --query="helm/$1")"
	new_tag="$(git tag --list | fzf --query="helm/$1")"

	git diff "$old_tag".."$new_tag" -- helm/"$1"
}

# Completion helper.
if ! command -v fd &> /dev/null; then
	return 0
fi

function _gitops_diff_tags() {
	local -
	set -o pipefail

	# Get valid Helm chart names from the gitops repo.
	chart_names=$(fd --base-directory="$HOME"/git/github.com/ovotech/bedrock-platform-gitops/_bedrock-platform-gitops/helm/ --exact-depth=1 --path-separator='' --type=directory .)

	# Generate possible completions with the chart names.
	compgen_chart_names=$(compgen -W "$chart_names" -- "$2")

	# Store possible completions for 'complete' to make use of.
	mapfile -t COMPREPLY <<< "$compgen_chart_names"
}

complete -F _gitops_diff_tags gitops_diff_tags
