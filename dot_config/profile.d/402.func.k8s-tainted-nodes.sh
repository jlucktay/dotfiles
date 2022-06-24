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
      echo -n "Resource type '$resource_type'"

      local -a kubectl_flags=()

      if [[ -n $1 ]]; then
        kubectl_flags+=("--namespace=$1")
        echo " in namespace '$1'."
      fi

      kubectl_flags+=("get")

      if [[ -z $1 ]]; then
        kubectl_flags+=("--all-namespaces")
        echo " in all namespaces."
      fi

      kubectl_flags+=(
        "--output=wide"
        "$resource_type"
        "--ignore-not-found"
        "--show-kind"
        "--show-labels"
      )

      # If a namespace was given as the optional first argument, filter by that.
      kubectl "${kubectl_flags[@]}"
      echo
    done
  }

  function k8staints() {
    kubectl get nodes --output=go-template-file="$HOME/etc/k8staints.gotmpl"
  }
fi
