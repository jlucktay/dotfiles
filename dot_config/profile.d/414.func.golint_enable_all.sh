# https://github.com/golangci/golangci-lint
if hash golangci-lint &> /dev/null; then
  function golint_enable_all() {
    golangci-lint linters \
      | grep -A999 "^Disabled" \
      | tail -n +2 \
      | cut -d':' -f1 \
      | cut -d' ' -f1 \
      | {
        local -a enable

        while IFS= read -r disabled; do
          enable+=("--enable=$disabled")
        done

        golangci-lint run "${enable[@]}" "$@"
      }
  }

  export -f golint_enable_all
fi
