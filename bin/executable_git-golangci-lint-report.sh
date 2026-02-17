#!/usr/bin/env bash
set -euo pipefail

# If there is more than one initial commit, we take the first
first_commit_hash=$(git rev-list --max-parents=0 HEAD | tail -n 1)

declare -i slices=50

if [[ $# -gt 0 ]]; then
	re='^[0-9]+$'

	if [[ $1 =~ $re ]]; then
		slices=$1
	fi
fi

declare -i commit_count
commit_count=$(git rev-list --count "$first_commit_hash"...HEAD)

echo "commit_count: '$commit_count'"
echo "slices: '$slices'"

declare -i slice_size=$((commit_count / slices))

echo "slice_size: '$slice_size'"
echo

printf "%s / %s / %s\n" "commit reference" "number of commits" "number of linter issues"

while ((slices-- > 0)); do
	declare -i rewind_count=$((slices * slice_size))

	repo_commits=$((commit_count - rewind_count))

	if ! check_this_out="$(git rev-list "$first_commit_hash"..HEAD | tail -n "$rewind_count" | head -n 1)"; then
		: # no-op to dodge 141 exit status
	fi

	if [[ $check_this_out == "" ]]; then
		check_this_out=$(git rev-parse HEAD)
	fi

	git checkout "$check_this_out" &> /dev/null

	if ! linter_output="$(
		golint_enable_all \
			--issues-exit-code=0 \
			--max-issues-per-linter=0 \
			--max-same-issues=0 \
			--new-from-rev= \
			--out-format=json \
			2>&1
	)"; then
		issue_count="error"
	else
		if ! issue_count="$(jq --exit-status '.Issues | length' <<< "$linter_output")"; then
			echo "issue parsing with JQ; linter output: '$linter_output'"
			continue
		fi
	fi

	printf "%s / %s / %s\n" "$check_this_out" "$repo_commits" "$issue_count"
done
