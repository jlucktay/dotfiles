# Kubernetes
if command -v kubectl &> /dev/null; then
	function k8sgetall() {
		# https://stackoverflow.com/questions/46480686/how-to-restrict-shell-options-to-a-function-using-local
		local -
		set -o pipefail

		local kubectl_output
		local -a kubectl_arr
		kubectl_output=$(kubectl api-resources --namespaced --output=name --verbs=list)
		mapfile -t kubectl_arr <<< "$kubectl_output"

		local grep_output
		local -a grep_arr
		grep_output=$(grep --extended-regexp --invert-match "^events(\.events\.k8s\.io){0,1}$" <<< "${kubectl_arr[*]}")
		mapfile -t grep_arr <<< "$grep_output"

		local sort_result
		local -a sort_arr
		sort_result=$(printf '%s\n' "${grep_arr[@]}" | sort | xargs -n 1)
		mapfile -t sort_arr <<< "$sort_result"

		for resource_type in "${sort_arr[@]}"; do
			local headline="Resource type '$resource_type'"
			local -a kubectl_flags=(
				"get"
				"$resource_type"
			)

			# If a namespace was given as the optional first argument, filter by that.
			if [[ -n $1 ]]; then
				kubectl_flags+=("--namespace=$1")
				headline+=" in namespace '$1'."
			else
				kubectl_flags+=("--all-namespaces")
				headline+=" in all namespaces."
			fi

			kubectl_flags+=(
				"--ignore-not-found"
				"--show-kind"
			)

			local kubectl_get_output
			local -a kubectl_get_output_arr
			kubectl_get_output=$(kubectl "${kubectl_flags[@]}")
			mapfile -t kubectl_get_output_arr <<< "$kubectl_get_output"

			if [[ ${#kubectl_get_output_arr[@]} -gt 0 ]] && [[ ${#kubectl_get_output_arr[0]} -gt 0 ]]; then
				printf "%s\n%s\n\n" "$headline" "$kubectl_get_output"
			else
				echo -n .
			fi

		done
	}

	function k8staints() {
		kubectl get nodes --output=go-template-file="$HOME/etc/k8staints.gotmpl"
	}
fi
