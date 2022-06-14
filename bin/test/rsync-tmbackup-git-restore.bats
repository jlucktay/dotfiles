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

  # Create some directories before we mock out 'mkdir'
  mkdir -p "$test_temp_dir/mnt/backup/git/host/user/repo-1/.git"
  mkdir -p "$test_temp_dir/mnt/backup/git/host/user/repo-1/submodule-one/.git"
  mkdir -p "$test_temp_dir/mnt/backup/git/host/user/repo-1/submodule-two/.git"
  mkdir -p "$test_temp_dir/mnt/backup/git/host/user/repo-2/.git"
  mkdir -p "$test_temp_dir/mnt/backup/git/host/user/repo-2/submodule/.git"
  mkdir -p "$test_temp_dir/mnt/backup/git/host/user/repo-3/.git"

  # Mock the 'mkdir' command
  mock_mkdir=$(mock_create)
  ln -s "$mock_mkdir" "$test_temp_dir/mkdir"
  mock_set_side_effect "$mock_mkdir" 'echo $2'

  # Add SUT and mocks to the front of PATH so they are all a) callable and b) take priority
  PATH="$test_temp_dir:$PATH"
}

teardown() {
  temp_del "$test_temp_dir"
}

@test "run without arguments gives non-zero exit status and an error" {
  run rsync-tmbackup-git-restore.sh
  assert_not_equal "$status" 0
  assert_output "Please provide a source directory as the first argument!"
}

@test "run with valid directory argument reports only outermost non-submodule repos" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$test_temp_dir/mnt/backup/git"

  # Assert
  assert_equal "$status" 0
  assert [ "$(echo "$output" | grep --count '^')" -ge 3 ]
  assert_output --partial "found:  $test_temp_dir/mnt/backup/git/host/user/repo-1/.git"
  assert_output --partial "found:  $test_temp_dir/mnt/backup/git/host/user/repo-2/.git"
  assert_output --partial "found:  $test_temp_dir/mnt/backup/git/host/user/repo-3/.git"
}

@test "run creates necessary target directories" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$test_temp_dir/mnt/backup/git"

  # Assert
  assert_equal "$status" 0
  assert [ "$(echo "$output" | grep --count '^')" -ge 3 ]
  assert_equal "$(mock_get_call_num "$mock_mkdir")" 3
  assert_equal "$(mock_get_call_args "$mock_mkdir" 1)" "-pv $HOME/git/host/user/repo-1"
  assert_equal "$(mock_get_call_args "$mock_mkdir" 2)" "-pv $HOME/git/host/user/repo-2"
  assert_equal "$(mock_get_call_args "$mock_mkdir" 3)" "-pv $HOME/git/host/user/repo-3"
  assert_output --partial "create: $HOME/git/host/user/repo-1"
  assert_output --partial "create: $HOME/git/host/user/repo-2"
  assert_output --partial "create: $HOME/git/host/user/repo-3"
}
