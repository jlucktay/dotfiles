#!/usr/bin/env bash
set -euo pipefail

for package in $(go list ./...); do
  test_name_pattern="^(Bench|Example|Test)"
  go_test_output=$(go test -list="$test_name_pattern" "$package")

  if [[ $go_test_output =~ ^\? ]]; then
    continue
  fi

  awk -v PKG="$package" -v TNP="$test_name_pattern" \
    '$1 ~ TNP {print PKG, ">", $0}' <<< "$go_test_output"
done
