if hash aws &> /dev/null; then
  function awsregions() {
    aws ec2 describe-regions --region=eu-west-1 | jq --raw-output '.Regions[].RegionName' | gsort --ignore-case
  }

  export -f awsregions
fi
