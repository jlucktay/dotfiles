# Kubernetes
if command -v kubectl &> /dev/null; then
  function k8sgetall() {
    for resource_type in $(kubectl api-resources --namespaced --output=name --verbs=list \
      | grep --invert-match "events" | sort --ignore-case --unique); do
      echo "Resource type: $resource_type"
      kubectl -n "${1:?}" get --ignore-not-found "$resource_type"
      echo
    done
  }

  function k8staints() {
    kubectl get nodes --output=go-template-file="$HOME/etc/k8staints.gotmpl"
  }
fi
