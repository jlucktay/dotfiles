#!/usr/bin/env bash
set -euo pipefail

if ! command -v aws &> /dev/null; then
	echo >&2 "'aws' not found! Please install: https://aws.amazon.com/cli/"
	exit 1
fi

if ! command -v jq &> /dev/null; then
	echo >&2 "'jq' not found! Please install: https://stedolan.github.io/jq/download/"
	exit 1
fi

awsregions_output=$(awsregions)
mapfile -t aws_regions <<< "$awsregions_output"

for region in "${aws_regions[@]}"; do
	echo "Region: $region"

	aws ec2 describe-instances --region "$region" \
		| jq '.Reservations[].Instances[] |
      {
          n: (.Tags[] | select(.Key == "Name") | .Value),
          id: .InstanceId,
          az: .Placement.AvailabilityZone,
          ip: .PublicIpAddress,
          up: .State.Name
      }'
done
