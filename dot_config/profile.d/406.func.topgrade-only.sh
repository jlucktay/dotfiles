if ! command -v topgrade &> /dev/null; then
	return 0
fi

function topgrade_only() {
	local -
	set -o pipefail

	yq_output=$(yq --output-format=yaml '.misc.only | ... comments=""' "$HOME"/.config/topgrade.toml)
	mapfile -t topgrade_misc_only <<< "$yq_output"

	if [[ $# -ne 1 ]]; then
		echo >&2 "Must pass exactly one argument for the 'only' Topgrade section to run."
		echo >&2 "Valid options:"
		echo >&2 "$yq_output"

		return 1
	fi

	declare only=$1

	# Strip '- ' prefix from every element.
	topgrade_misc_only=("${topgrade_misc_only[@]#'- '}")

	declare only_found_in_config=0

	for i in "${topgrade_misc_only[@]}"; do
		if [[ $i == "$only" ]]; then
			only_found_in_config=1
		fi
	done

	if [[ $only_found_in_config -eq 0 ]]; then
		echo >&2 "'$only' is not set in the '.misc.only' section of the Topgrade config file."
		echo >&2 "Valid options are:"
		echo >&2 "$yq_output"

		return 1
	fi

	declare -a topgrade_disable_flags=()

	for ((i = 0; i < ${#topgrade_misc_only[@]}; i++)); do
		if [[ ${topgrade_misc_only[i]} != "$only" ]]; then
			topgrade_disable_flags+=(--disable="${topgrade_misc_only[i]}")
		fi
	done

	set -x
	topgrade --only="$only" "${topgrade_disable_flags[@]}"
}

export -f topgrade_only

if ! command -v yq &> /dev/null; then
	return 0
fi

function _topgrade_only() {
	yq_misc_only=$(yq --output-format=yaml '.misc.only | ... comments=""' "$HOME"/.config/topgrade.toml)

	# Strip '- ' prefix from every element using '${parameter//pattern/string}' expansion.
	compgen_yq_misc_only=$(compgen -W "${yq_misc_only//'- '/''}" -- "$2")

	mapfile -t COMPREPLY <<< "$compgen_yq_misc_only"
}

complete -F _topgrade_only topgrade_only
