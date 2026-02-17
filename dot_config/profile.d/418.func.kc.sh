if ! command -v kc &> /dev/null; then
	return 0
fi

function _kubecm_context() {
	local -
	set -o pipefail

	# Get valid values for the context name from kubeconfig.
	context_names=$(kubectl config view | yq --exit-status '.contexts[].name')

	# Generate possible completions with the context names.
	compgen_context_names=$(compgen -W "$context_names" -- "$2")

	# Store possible completions for 'complete' to make use of.
	mapfile -t COMPREPLY <<< "$compgen_context_names"
}

complete -F _kubecm_context kc
