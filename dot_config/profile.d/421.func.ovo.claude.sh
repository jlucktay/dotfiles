# OVO Claude Code OTel collector wrapper
claude-ovo() {
	local -
	set -euo pipefail

	local collector_bin="$HOME/.claude/otel/otelcol-contrib"
	local collector_pid="$HOME/.claude/otel/collector.pid"
	local collector_cfg="$HOME/.claude/otel/collector-config.yaml"
	local collector_log="$HOME/.claude/otel/collector.log"
	local adc_file="$HOME/.config/gcloud/application_default_credentials.json"
	local repo username

	repo=$(git remote get-url origin 2> /dev/null | sed 's/.*github\.com[:/]\(.*\)$/\1/' | sed 's/\.git$//')
	repo="${repo:-$(basename "$PWD")}"

	username=$(git config user.name 2> /dev/null || echo "unknown")
	username=$(printf '%s' "$username" | sed 's/ /_/g')

	OTEL_RESOURCE_ATTRIBUTES="gcp.project_id=agentic-engineering-prod,repo=${repo},org=ovo,service.instance.id=$(hostname),user.name=${username}"
	export OTEL_RESOURCE_ATTRIBUTES

	if [[ -x $collector_bin ]] && [[ -f $collector_cfg ]]; then
		if ! [[ -f $adc_file ]] && ! curl -sf -m 1 -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email" &> /dev/null; then
			echo >&2 "[OTel] No Application Default Credentials found. Run: gcloud auth application-default login && gcloud auth application-default set-quota-project agentic-engineering-prod"
		elif ! kill -0 "$(< "$collector_pid")" 2> /dev/null; then
			"$collector_bin" --config "$collector_cfg" &>> "$collector_log" &
			echo $! > "$collector_pid"
		fi
	fi

	command claude "$@"
}
