# Kubernetes
if command -v kubectl &> /dev/null; then
  function k8sgetall() {
    local kubectl_output
    kubectl_output=$(kubectl api-resources --namespaced --output=name --verbs=list)

    local grep_output
    grep_output=$(grep --invert-match "events" <<< "$kubectl_output")

    local sort_output
    sort_output=$(sort --ignore-case --unique <<< "$grep_output")

    for resource_type in "${sort_output[@]}"; do
      echo "Resource type: $resource_type"
      kubectl -n "${1:?}" get --ignore-not-found "$resource_type"
      echo
    done
  }

  function k8staints() {
    kubectl get nodes --output=go-template-file="$HOME/etc/k8staints.gotmpl"
  }
fi
