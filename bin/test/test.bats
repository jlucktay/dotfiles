setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  source_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")" &> /dev/null && pwd)"

  tmp_dir=$(mktemp -d)

  cp "$source_dir/../executable_rsync-git-restore.sh" "$tmp_dir/rsync-git-restore.sh"

  gchmod u+x "$tmp_dir/rsync-git-restore.sh"

  PATH="$tmp_dir:$PATH"
}

teardown() {
  rm -rf "$tmp_dir"
}

@test "run without arguments gives error" {
  run rsync-git-restore.sh
  assert_output 'Please provide a source directory as the first argument!'
  assert [ "$status" -ne 0 ]
}
