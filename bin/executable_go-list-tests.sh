#!/usr/bin/env bash
set -euo pipefail

script_name=$(basename "${BASH_SOURCE[-1]}")

if ! command -v go &> /dev/null; then
	echo >&2 "$script_name: 'go' is required but is not installed: https://go.dev/doc/install"
	exit 1
fi

if ! command -v goawk &> /dev/null; then
	echo >&2 "$script_name: 'goawk' is required but is not installed: https://github.com/benhoyt/goawk"
	exit 1
fi

echo -n "Listing packages..."

go_list_packages=$(go list ./...)
mapfile -t go_packages <<< "$go_list_packages"

echo " done."

declare -a go_package_tests

for go_package in "${go_packages[@]}"; do
	echo -n "Listing tests in '$go_package'..."

	package_tests=$(go test -list=. "$go_package")

	# Don't match on any line that starts with '?' or 'ok' with a space afterwards.
	go_tests=$(goawk '!/^(\?|ok) / { print $1 }' <<< "$package_tests")

	# If no tests were found, go to the next package now.
	if [[ -z $go_tests ]]; then
		echo " no tests found in package."
		continue
	fi

	# Split each test up into its own element, in an array.
	mapfile -t go_test <<< "$go_tests"

	# Prefix each element with the package name, and append to the overall array of tests.
	go_package_tests+=("${go_test[@]/#/$go_package }")

	echo " found ${#go_package_tests[@]} test(s)."
done

fzf_multi_select=$(printf "%s\n" "${go_package_tests[@]}" | fzf --multi --tac)

mapfile -t choices <<< "$fzf_multi_select"

echo "Running ${#choices[@]} selection(s)..."

for choice in "${choices[@]}"; do
	package=$(cut -d ' ' -f 1 <<< "$choice")
	test=$(cut -d ' ' -f 2 <<< "$choice")

	(
		set -x
		go test "$package" --count=1 --run="^$test$" -v
	)
done
