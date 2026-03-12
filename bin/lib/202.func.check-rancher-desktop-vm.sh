#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
	echo >&2 "${BASH_SOURCE[0]} is not being sourced."
	exit 1
fi

# Every time Rancher Desktop stops the VM, it frees up unused space.
# Plenty more interesting discussion here: https://github.com/rancher-sandbox/rancher-desktop/issues/1521
# If the actual usage of the VM's disk is over 80%, sound the alarm.
check_rd_vm() {
	tool_check rdctl gawk

	local df_raw df_pct pct_compare

	if ! df_raw=$(rdctl shell df /var/lib); then
		err "Rancher Desktop does not seem to be running"
	fi

	# Iterate across columns looking for one that has at least one digit followed by a percentage sign as its last character.
	df_pct=$(gawk '{ for (i=1; i<=NF; i++) { if ($i ~ /[0-9]%$/) { pct = $i; sub(/%/, "", pct); print pct; } } }' <<< "$df_raw")
	pct_compare=$(bc --mathlib <<< "$df_pct >= 80")

	if ((pct_compare)); then
		# Actual usage is 80% or higher.
		return 1
	fi
}
