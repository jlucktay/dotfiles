if command -v chezmoi &> /dev/null; then
  function cdl() {
    local chezmoi_diff
    chezmoi_diff=$(chezmoi diff --exclude=scripts)

    local wc_output
    wc_output=$(wc -l <<< "$chezmoi_diff")

    if [[ $wc_output -gt 255 ]]; then
      wc_output=255
    fi

    return "$wc_output"
  }

  export -f cdl

  function cdes() {
    local chezmoi_diff
    chezmoi_diff=$(chezmoi diff --exclude=scripts)

    echo "$chezmoi_diff"
  }

  export -f cdes
fi
