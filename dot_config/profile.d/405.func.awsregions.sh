if command -v aws &> /dev/null; then
  function awsregions() {
    local -
    set -o pipefail

    aws --profile awsregions ec2 describe-regions \
      | jq --raw-output '.Regions[].RegionName' \
      | gsort --ignore-case
  }

  export -f awsregions
fi
