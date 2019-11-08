# Kubernetes/K8s
if hash kubectl 2>/dev/null; then
    function k8staints(){
        # shellcheck disable=SC2016
        kubectl get nodes -o go-template='{{printf "%-47s %-12s\n" "Node" "Taint"}}{{- range .items}}{{- if $taint := (index .spec "taints") }}{{- .metadata.name }}{{ "\t" }}{{- range $taint }}{{- .key }}={{ .value }}:{{ .effect }}{{ "\t" }}{{- end }}{{- "\n" }}{{- end}}{{- end}}'
    }
fi
