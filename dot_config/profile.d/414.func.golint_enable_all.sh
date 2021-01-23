# https://github.com/golangci/golangci-lint
if hash golangci-lint &> /dev/null; then
  function golint_enable_all() {
    local -a do_not_enable

    for arg in "$@"; do
      if [[ $arg =~ "--disable="* ]]; then
        do_not_enable+=("${arg/--disable=/}")
        shift
      fi
    done

    # TODO: remove 'effected' once this PR merges/releases: https://github.com/golangci/golangci-lint/pull/1663
    golangci-lint linters \
      | awk '$0 ~ /:/ && $1 !~ /^((En|Dis)abled|effected)$/ { gsub(/:/, "", $1); print $1 }' \
      | {
        local -a enable

        while IFS=$'\n' read -r linter; do
          if [[ ! " ${do_not_enable[*]} " =~ \ ${linter}\  ]]; then
            enable+=("$linter")
          fi
        done

        IFS=',' linters_joined="${enable[*]}"

        golangci-lint run --disable-all --enable="$linters_joined" "$@"
      }
  }

  export -f golint_enable_all
fi
