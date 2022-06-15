if command -v aws &> /dev/null; then
  function awsregions() {
    local aws_describe_regions
    aws_describe_regions=$(aws --profile awsregions ec2 describe-regions)

    local jq_regions
    jq_regions=$(jq --raw-output '.Regions[].RegionName' <<< "$aws_describe_regions")

    gsort --ignore-case <<< "$jq_regions"
  }

  export -f awsregions
fi
