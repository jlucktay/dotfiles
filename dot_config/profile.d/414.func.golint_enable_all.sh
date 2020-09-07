# https://github.com/golangci/golangci-lint
if hash golangci-lint &> /dev/null; then
  function golint_enable_all() {
    golangci-lint linters \
      | awk 'BEGIN { FS = "[ :]" } ; $1 != "Enabled" && $1 != "Disabled" && length($1) > 0 { print $1 }' \
      | {
        local -a enable

        while IFS=$'\n' read -r linter; do
          enable+=("$linter")
        done

        linters_joined="$(
          IFS=','
          echo "${enable[*]}"
        )"

        golangci-lint run --disable-all --enable="$linters_joined" "$@"
      }
  }

  export -f golint_enable_all
fi
