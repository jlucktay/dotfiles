if command -v chezmoi &> /dev/null; then
	function cdl() {
		local -
		set -o pipefail

		local wc_output
		wc_output=$(chezmoi diff --exclude=scripts | wc -l)

		if [[ $wc_output -gt 255 ]]; then
			wc_output=255
		fi

		return "$wc_output"
	}

	export -f cdl
fi
