function gocover() {
  local t
  t=$(mktemp -t gocover)
  go test -coverprofile="$t" "$@" \
    && go tool cover -html="$t" \
    && rm -f "$t"
}