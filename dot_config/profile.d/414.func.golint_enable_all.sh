# https://github.com/golangci/golangci-lint
if command -v golangci-lint &> /dev/null; then
	function golint_enable_all() {
		local -
		set -o pipefail

		local -a do_not_enable

		for arg in "$@"; do
			if [[ $arg =~ "--disable="* ]]; then
				do_not_enable+=("${arg/--disable=/}")
				shift
			fi
		done

		local golangci_lint_linters
		golangci_lint_linters=$(golangci-lint linters \
			| awk '$0 ~ /:/ && $1 !~ /^((En|Dis)abled)$/ { gsub(/:/, "", $1); print $1 }')

		local -a enable_linter

		while IFS=$'\n' read -r linter; do
			if [[ ! " ${do_not_enable[*]} " =~ \ $linter\  ]]; then
				enable_linter+=("$linter")
			fi
		done <<< "$golangci_lint_linters"

		IFS=',' linters_joined="${enable_linter[*]}"

		golangci-lint run --disable-all --enable="$linters_joined" "$@"
	}

	export -f golint_enable_all
fi
