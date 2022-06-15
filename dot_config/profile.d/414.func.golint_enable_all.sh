# https://github.com/golangci/golangci-lint
if command -v golangci-lint &> /dev/null; then
  function golint_enable_all() {
    local -a do_not_enable

    for arg in "$@"; do
      if [[ $arg =~ "--disable="* ]]; then
        do_not_enable+=("${arg/--disable=/}")
        shift
      fi
    done

    local golangci_lint_linters
    golangci_lint_linters=$(golangci-lint linters)

    local awk_output
    awk_output=$(awk '$0 ~ /:/ && $1 !~ /^((En|Dis)abled)$/ { gsub(/:/, "", $1); print $1 }' \
      <<< "$golangci_lint_linters")

    local -a enable

    while IFS=$'\n' read -r linter; do
      if [[ ! " ${do_not_enable[*]} " =~ \ $linter\  ]]; then
        enable+=("$linter")
      fi
    done <<< "$awk_output"

    IFS=',' linters_joined="${enable[*]}"

    golangci-lint run --disable-all --enable="$linters_joined" "$@"
  }

  export -f golint_enable_all
fi
