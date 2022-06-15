#!/usr/bin/env bash
set -euo pipefail

script_name=$(basename "${BASH_SOURCE[-1]}")

if ! command -v go; then
  echo >&2 "$script_name: 'go' is required but it's not installed: https://golang.org/dl/"
  exit 1
fi

go list ./... | while IFS= read -r package; do
  test_name_pattern="^(Bench|Example|Test)"
  go_test_output=$(go test -list="$test_name_pattern" "$package")

  if [[ $go_test_output =~ ^\? ]]; then
    continue
  fi

  awk -v PKG="$package" -v TNP="$test_name_pattern" \
    '$1 ~ TNP {print PKG, ">", $0}' <<< "$go_test_output"
done
