# Kubernetes
if hash kubectl 2> /dev/null; then
  function k8sgetall() {
    for resource_type in $(kubectl api-resources --namespaced --output=name --verbs=list \
      | grep --invert-match "events" | sort --ignore-case --unique); do
      echo "Resource type: $resource_type"
      kubectl -n "${1:?}" get --ignore-not-found "$resource_type"
      echo
    done
  }

  function k8staints() {
    # shellcheck disable=SC2016
    kubectl get nodes -o go-template='{{printf "%-47s %-12s\n" "Node" "Taint"}}{{- range .items}}{{- if $taint := (index .spec "taints") }}{{- .metadata.name }}{{ "\t" }}{{- range $taint }}{{- .key }}={{ .value }}:{{ .effect }}{{ "\t" }}{{- end }}{{- "\n" }}{{- end}}{{- end}}'
  }
fi
