#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Illegal number of parameters; please provide an AWS account name prefix, e.g.: 'cr-'"
  exit 1
fi

if ! command -v aws &> /dev/null; then
  echo >&2 "'aws' not found! Please install: https://aws.amazon.com/cli/"
  exit 1
fi

if ! command -v awsume &> /dev/null; then
  echo >&2 "'awsume' not found! Please install: https://github.com/trek10inc/awsume"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo >&2 "'jq' not found! Please install: https://stedolan.github.io/jq/download/"
  exit 1
fi

echo "Account,Region,EC2Count"

mapfile -t awsume_output < <(awsume --list | grep "^$1")

for ao_line in "${awsume_output[@]}"; do
  IFS=$' \t' read -ra account_line <<< "$ao_line"
  eval "$(awsume -s "${account_line[0]}" 2> /dev/null)"

  mapfile -t aws_regions < <(awsregions)

  for region in "${aws_regions[@]}"; do
    jq_result="$(aws ec2 describe-instances --region "$region" --filter "Name=instance-state-name,Values=running" \
      | jq '.Reservations[].Instances[].InstanceId' | wc -l)"

    if ((jq_result > 0)); then
      echo "${account_line[0]},$region,$jq_result"
    fi
  done
done
