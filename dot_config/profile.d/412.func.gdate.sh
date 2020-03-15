if hash gdate &> /dev/null; then
  function gdn() {
    gdate '+%Y%m%d.%H%M%S.%N%z'
  }
else
  function gdn() {
    date '+%Y%m%d.%H%M%S%z'
  }
fi

export -f gdn
