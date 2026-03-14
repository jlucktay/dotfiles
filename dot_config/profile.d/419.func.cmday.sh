if ! command -v gdate &> /dev/null; then
	return 0
fi

# cmday: command history from a whole day
# Searches through Bash eternal history for all commands run on a specific date.
# An optional argument can be given, which must be an integer.
# This argument will count back that many days before searching and displaying.
function cmday() {
	local -
	set -o pipefail

	if [[ $# -gt 0 ]] && ! [[ $1 =~ ^[0-9]+$ ]]; then
		echo >&2 "error: '$1' is not an integer"

		return 1
	fi

	# Dial in the target date, in ISO 8601 format.
	target_date=$(gdate --date="${1:-"0"} day ago" "+%Y-%m-%d")

	HISTTIMEFORMAT="%Y-%m-%d %A %T " history 10000 | awk -v today="$target_date" '{ if ($2 == today) print $0 }'
}

# This gave back about 2 months' worth:
# $ time history 10000
# It also ran in less than one tenth of a second, so that seems fine.
