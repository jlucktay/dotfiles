#!/usr/bin/env bash
set -euo pipefail

if ! command -v aws > /dev/null; then
  echo "'aws' not found! Please install: https://aws.amazon.com/cli/"
  exit 1
fi

if ! command -v jq > /dev/null; then
  echo "'jq' not found! Please install: https://stedolan.github.io/jq/download/"
  exit 1
fi

mapfile -t aws_regions < <(awsregions)

for region in "${aws_regions[@]}"; do
  echo -n "Region: $region... "

  # Attempt to create the Default VPC
  set +e
  aws_create_output="$(aws ec2 create-default-vpc --region "$region" 2>&1)"
  aws_result=$?
  set -e

  if [[ $aws_result -eq 0 ]]; then
    # Successfully created
    vpc_id=$(echo "$aws_create_output" | jq '.Vpc.VpcId')
    echo "$vpc_id"
  else
    aws_describe_output=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --region "$region")
    vpc_id=$(echo "$aws_describe_output" | jq -r '.Vpcs[].VpcId')
    echo "Default VPC '$vpc_id' already exists."
  fi

  # (Re)set the Name tag
  echo -n "Setting 'Name' tag on '$vpc_id'... "
  aws ec2 create-tags --region "$region" --resources "$vpc_id" --tags Key=Name,Value=Default
  echo "Done."
done
