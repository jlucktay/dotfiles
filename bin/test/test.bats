#!/usr/bin/env bats

setup() {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-file/load'
  load 'test_helper/bats-mock/load'
  load 'test_helper/bats-support/load'

  source_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")" &> /dev/null && pwd)"

  test_temp_dir="$(temp_make)"

  cp "$source_dir/../executable_rsync-tmbackup-git-restore.sh" "$test_temp_dir/rsync-tmbackup-git-restore.sh"

  chmod u+x "$test_temp_dir/rsync-tmbackup-git-restore.sh"

  PATH="$test_temp_dir:$PATH"
}

teardown() {
  temp_del "$test_temp_dir"
}

@test "run without arguments gives error" {
  run rsync-tmbackup-git-restore.sh
  assert_not_equal "$status" 0
  assert_output 'Please provide a source directory as the first argument!'
}

@test "run with valid directory argument calls (mocked) 'find' against said directory" {
  # Arrange
  mock_find=$(mock_create)
  mock_set_output "$mock_find" "mock find called"

  ln -s "$mock_find" $BATS_RUN_TMPDIR/find
  PATH="$BATS_RUN_TMPDIR:$PATH"

  # Act
  run rsync-tmbackup-git-restore.sh "$HOME/git"

  # Assert
  assert_equal "$status" 0
  assert_equal "$(mock_get_call_num "$mock_find")" 1
  assert_regex "$(mock_get_call_args "$mock_find")" "$HOME/git *"
}
