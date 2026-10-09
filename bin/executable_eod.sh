#!/usr/bin/env bash
set -euo pipefail

# Boilerplate to bring in library script(s).
script_directory="$(cd "$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")" &> /dev/null && pwd)"
readonly script_directory

if ((BASH_VERSINFO[0] < 4)); then
	echo >&2 "$0 needs Bash 4 or later; this is $BASH_VERSION."

	exit 1
fi

for lib in "$script_directory"/lib/*.sh; do
	# shellcheck disable=SC1090
	source "$lib"
done

# The real Dark Souls starts here.
dslog "start"
trap 'dslog "finish"' 0

tool_check docker gum kind

if docker info &> /dev/null; then
	dslog "✅ Docker daemon is running."

	if ! dpfn=$(docker ps --format='{{.Names}}'); then
		err "could not get names of running containers from host"
	fi

	mapfile -t running_names < <(printf "%s" "$dpfn")

	if [[ ${#running_names[@]} -gt 0 ]]; then
		echo
		docker ps
		echo
		dslog "🔶 non-zero number of containers/clusters still running"
		echo

		if gum confirm "Remove all running containers/clusters?" --show-output; then
			echo

			# Create a map to track any kind clusters that are currently running.
			# Depending on how the cluster is configured, it may have multiple containers running.
			declare -A running_kind_clusters=()

			for running_name in "${running_names[@]}"; do
				# Are any of the containers kind cluster control planes? If so, use 'kind delete cluster' instead.
				if [[ $running_name =~ -control-plane$ ]]; then
					running_name=${running_name%"-control-plane"}

					# Use pre-increment — where ++ is before the reference to the map — and increase the number value stored against the key.
					# If the key does not already exist, it will be created with a value of 1.
					# Do not use post-increment — where ++ is after the reference to the map — as it will return non-zero for new keys, and halt the script.
					((++running_kind_clusters[$running_name]))
				else
					(
						set -x
						docker rm --force "$running_name"
					)
				fi
			done

			# Iterate through the running kind clusters and run the appropriate delete command just once per cluster, rather than once per container.
			for rkc in "${!running_kind_clusters[@]}"; do
				(
					set -x
					kind delete cluster --name="$rkc"
				)
			done

		fi

		echo
	fi
else
	dslog "🐳❌ Docker daemon is not running."
fi

# Unset the current contexts for kubectl and argocd.
tool_check yq

for ctx in "$HOME/.kube/config" "$HOME/.config/argocd/config"; do
	(
		set -x
		yq eval --inplace 'del(.current-context)' "$ctx"
	)
done

# Clear any ongoing AWS sessions.
tool_check assume

(
	set -x
	assume --unset
)

# Close down chat apps.
(
	set -x
	osascript -e 'quit app "Google Chat"'
	osascript -e 'quit app "Slack"'
)

# Back up Claude Code memories while caffeinate still holds the machine awake, since the backup waits for Google Drive to confirm each upload.
if "$script_directory/eod-backup.sh"; then
	dslog "✅ Claude Code memories backed up to Google Drive."
else
	dslog "❌ Claude Code memory backup failed; the reason is logged above."
fi

# check if the Claude Code CLI is currently running
#   - also maybe list/summarise any sessions still open

# Sync Obsidian using the headless client.
# Doesn't work if WARP is connected.
(
	set -x

	warp-cli disconnect
	ob sync --path "$HOME/jlucktay-obsidian"
)

# Put the coffee mug down.
(
	set -x
	killall -q -v caffeinate || true
)
