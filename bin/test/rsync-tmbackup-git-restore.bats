load "test_helper/bats-assert/load"
load "test_helper/bats-file/load"
load "test_helper/bats-mock/load"
load "test_helper/bats-support/load"

setup() {
  # Set up the SUT in its own per-test temporary directory
  source_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")" &> /dev/null && pwd)"
  test_temp_dir="$(temp_make)"
  cp "$source_dir/../executable_rsync-tmbackup-git-restore.sh" "$test_temp_dir/rsync-tmbackup-git-restore.sh"
  chmod u+x "$test_temp_dir/rsync-tmbackup-git-restore.sh"

  # Mock the 'find' command
  mock_find=$(mock_create)

  # Randomise the input order
  mock_set_output "$mock_find" "$(
    printf "%s\n%s\n%s\n%s\n%s\n%s\n" \
      "/mnt/backup/git/host/user/repo-one/submodule-one/.git" \
      "/mnt/backup/git/host/user/repo-one/.git" \
      "/mnt/backup/git/host/user/repo-two/.git" \
      "/mnt/backup/git/host/user/repo-two/submodule/.git" \
      "/mnt/backup/git/host/user/repo-one/submodule-two/.git" \
      "/mnt/backup/git/host/user/repo-three/.git"
  )"

  ln -s "$mock_find" "$test_temp_dir/find"

  # Add SUT and mock(s) to the front of PATH so they are all a) callable and b) take priority
  PATH="$test_temp_dir:$PATH"
}

teardown() {
  temp_del "$test_temp_dir"
}

@test "run without arguments gives error" {
  run rsync-tmbackup-git-restore.sh
  assert_not_equal "$status" 0
  assert_output "Please provide a source directory as the first argument!"
}

@test "run with valid directory argument calls (mocked) 'find' once against said directory" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$HOME/git"

  # Assert
  assert_equal "$status" 0
  assert_equal "$(mock_get_call_num "$mock_find")" 1
  assert_regex "$(mock_get_call_args "$mock_find")" "$HOME/git *"
}

@test "run against nested git repos only selects outermost non-submodule repos" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$HOME/git"

  # Assert
  assert_equal "$status" 0
  assert_equal "$(echo "$output" | grep --count '^')" 3
  assert_line --index 0 "/mnt/backup/git/host/user/repo-one/.git"
  assert_line --index 1 "/mnt/backup/git/host/user/repo-three/.git"
  assert_line --index 2 "/mnt/backup/git/host/user/repo-two/.git"
}
