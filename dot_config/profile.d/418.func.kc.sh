if ! command -v kc &> /dev/null || ! command -v kn &> /dev/null; then
	return 0
fi

function _kubecm_context() {
	local -
	set -o pipefail

	# Get valid values for the context name from kubeconfig.
	context_names=$(kubectl config view --output=jsonpath='{range .contexts[*]}{.name}{"\n"}{end}')

	# Generate possible completions with the context names.
	compgen_context_names=$(compgen -W "$context_names" -- "$2")

	# Store possible completions for 'complete' to make use of.
	mapfile -t COMPREPLY <<< "$compgen_context_names"
}

complete -F _kubecm_context kc

function _kubecm_namespace() {
	local -
	set -o pipefail

	# Get valid namespaces from the current cluster.
	if ! namespaces=$(kubectl get namespaces --output=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' --request-timeout=3s 2> /dev/null); then
		if ! kubectl config view --minify &> /dev/null; then
			mapfile -t COMPREPLY <<< "no-context-set"
		else
			mapfile -t COMPREPLY <<< "unknown-error"
		fi

		return
	fi

	# Generate possible completions with the namespaces.
	compgen_namespaces=$(compgen -W "$namespaces" -- "$2")

	# Store possible completions for 'complete' to make use of.
	mapfile -t COMPREPLY <<< "$compgen_namespaces"
}

complete -F _kubecm_namespace kn
