#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 1 ]] || [[ -z ${1:-} ]] || [[ ! -d $1 ]]; then
  echo >&2 "Please provide a source directory as the first argument!"
  exit 1
fi

# Search the given directory for metadata subdirectories denoting git repositories, and save the results into an array
source="$1"
find_repos=$(find "${source}" -type d -name ".git")
mapfile -t mapped_repos <<< "${find_repos}"

# Iterate through found repos and create an array of sorted repos
sort_result=$(printf '%s\n' "${mapped_repos[@]}" | sort | xargs -n 1)
mapfile -t sorted_repos <<< "${sort_result}"

# If any element has a previous element (dropping the '.git' suffix from both to compare) in its entirety for a prefix
# then mark it as a submodule
for ((i = 0; i < ${#sorted_repos[@]}; i++)); do
  for ((j = i + 1; j < ${#sorted_repos[@]}; j++)); do
    trimmed_outer=${sorted_repos[i]%".git"}
    trimmed_inner=${sorted_repos[j]%".git"}
    result=${trimmed_inner##"${trimmed_outer}"}

    if [[ ${result} != "${trimmed_inner}" ]]; then
      submodule_repos+=("${trimmed_inner}.git")
    fi
  done
done

# Compare the full list of all repos with the discovered submodules, and keep the elements that only appear exclusively
# in the first of those two arrays, which are all of the repos that are not submodules of other repos
compare_arrays=$(comm -23 <(printf '%s\n' "${sorted_repos[@]}") <(printf '%s\n' "${submodule_repos[@]}"))
mapfile -t non_submodule_repos <<< "${compare_arrays}"

for repo in "${non_submodule_repos[@]}"; do
  # Print the non-submodule repository that we are going to operate on
  echo "found:  ${repo}"

  # Subtract the base search directory from the start of each repo's location, to get the true repo name/path
  trimmed_repo=${repo##"${source}/"}
  trimmed_repo=${trimmed_repo%%"/.git"}
  target="${HOME}/git/${trimmed_repo}"

  if [[ ! -d ${target} ]]; then
    # Print the target directory for this repository
    echo -n "create: "
    mkdir -pv "${target}"
  fi
done
