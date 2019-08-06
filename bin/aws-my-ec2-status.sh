#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if ! command -v aws > /dev/null; then
    echo "'aws' not found! Please install: https://aws.amazon.com/cli/"
    exit 1
fi

if ! command -v jq > /dev/null; then
    echo "'jq' not found! Please install: https://stedolan.github.io/jq/download/"
    exit 1
fi

for Region in $(awsregions); do
    echo "Region: $Region"

    aws ec2 describe-instances --region "$Region" |
        jq '.Reservations[].Instances[] |
            {
                n: (.Tags[] | select(.Key == "Name") | .Value),
                id: .InstanceId,
                az: .Placement.AvailabilityZone,
                ip: .PublicIpAddress,
                up: .State.Name
            }'
done
