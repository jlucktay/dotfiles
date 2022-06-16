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

  if command -v bat &> /dev/null; then
    function cdes() {
      # If there are multiple different files, show the diff of the first file only.
      local first_split=0
      local -a cat_input
      local chezmoi_diff
      chezmoi_diff=$(chezmoi diff --exclude=scripts)

      while IFS= read -r line; do
        IFS=$'\n' cat_input+=("$line")

        if [[ $line =~ ^diff[[:space:]]--git[[:space:]]a/ ]]; then
          if [[ $first_split -eq 0 ]]; then
            local file_name=${line##diff --git a/}
            file_name=${file_name% b/*}

            ((first_split++))
            continue
          fi

          break
        fi
      done <<< "$chezmoi_diff"

      if [[ ${#cat_input[@]} -le 2 ]]; then
        return 0
      fi

      bat --file-name "$file_name" --language=diff <<< "${cat_input[*]}"
    }

    export -f cdes
  fi
fi
