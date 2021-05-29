if hash chezmoi &> /dev/null; then
  function cdl() {
    local result
    result=$(chezmoi diff --exclude=scripts | wc -l)

    if [ "$result" -gt 255 ]; then
      result=255
    fi

    return "$result"
  }

  export -f cdl
fi
