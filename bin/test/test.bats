setup() {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-file/load'
  load 'test_helper/bats-support/load'

  source_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")" &> /dev/null && pwd)"

  test_temp_dir="$(temp_make)"

  cp "$source_dir/../executable_rsync-git-restore.sh" "$test_temp_dir/rsync-git-restore.sh"

  chmod u+x "$test_temp_dir/rsync-git-restore.sh"

  PATH="$test_temp_dir:$PATH"
}

teardown() {
  temp_del "$test_temp_dir"
}

@test "run without arguments gives error" {
  run rsync-git-restore.sh
  assert [ "$status" -ne 0 ]
  assert_output 'Please provide a source directory as the first argument!'
}
