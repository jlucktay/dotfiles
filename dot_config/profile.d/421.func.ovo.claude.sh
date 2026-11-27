if ! chezmoi_profile=$(yq --exit-status ".profile" "$HOME"/.local/share/chezmoi/.chezmoidata.yaml); then
	return 0
fi

if [[ $chezmoi_profile != "ovo" ]]; then
	unset chezmoi_profile

	return 0
fi

# OVO Claude Code wrapper: tags telemetry with resource attributes; the exporter endpoint comes from managed settings
claude-ovo() {
	local -
	set -o pipefail

	local repo username

	repo=$(git remote get-url origin 2> /dev/null | sed 's/.*github\.com[:/]\(.*\)$/\1/' | sed 's/\.git$//')
	repo="${repo:-$(basename "$PWD")}"

	username=$(git config user.name 2> /dev/null || echo "unknown")
	username=$(printf '%s' "$username" | sed 's/ /_/g')

	OTEL_RESOURCE_ATTRIBUTES="gcp.project_id=agentic-engineering-prod,repo=${repo},org=ovo,service.instance.id=$(hostname),user.name=${username}"
	export OTEL_RESOURCE_ATTRIBUTES

	command claude "$@"
}

unset chezmoi_profile
