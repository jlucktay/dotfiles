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
  mock_set_side_effect "$mock_mkdir" 'echo "mkdir: $2"'

  # Mock the 'rsync' command
  mock_rsync=$(mock_create)
  ln -s "$mock_rsync" "$test_temp_dir/rsync"
  mock_set_side_effect "$mock_rsync" 'echo "rsync:  $8 $9"'

  # Mock the 'git' command
  mock_git=$(mock_create)
  ln -s "$mock_git" "$test_temp_dir/git"

  git_status_porcelain=$(
    printf "%s\n%s\n" \
      "?? new.file" \
      " M modified.file" \
      "?? another.new.file"
  )

  git_mod_file_output=$(
    printf "%s\n%s\n%s\n" \
      "diff --git a/modified.file b/modified.file" \
      "old mode 100755" \
      "new mode 100644"
  )

  mock_set_output "$mock_git" "$git_status_porcelain" 1
  mock_set_output "$mock_git" "$git_mod_file_output" 2
  mock_set_side_effect "$mock_git" 'echo "git:  $8 $9"' 3
  mock_set_side_effect "$mock_git" 'echo "git:  $8 $9"' 4

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
  assert_output --partial "create: mkdir: $HOME/git/host/user/repo-1"
  assert_output --partial "create: mkdir: $HOME/git/host/user/repo-2"
  assert_output --partial "create: mkdir: $HOME/git/host/user/repo-3"
}

@test "rsync from source to target" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$test_temp_dir/mnt/backup/git"

  # Assert
  assert_equal "$status" 0
  assert [ "$(echo "$output" | grep --count '^')" -ge 3 ]
  assert_equal "$(mock_get_call_num "$mock_rsync")" 3
  assert_regex "$(mock_get_call_args "$mock_rsync" 1)" \
    "^.* $test_temp_dir/mnt/backup/git/host/user/repo-1/ $HOME/git/host/user/repo-1$"
  assert_regex "$(mock_get_call_args "$mock_rsync" 2)" \
    "^.* $test_temp_dir/mnt/backup/git/host/user/repo-2/ $HOME/git/host/user/repo-2$"
  assert_regex "$(mock_get_call_args "$mock_rsync" 3)" \
    "^.* $test_temp_dir/mnt/backup/git/host/user/repo-3/ $HOME/git/host/user/repo-3$"
  assert_output --partial "rsync:  $test_temp_dir/mnt/backup/git/host/user/repo-1/ $HOME/git/host/user/repo-1"
  assert_output --partial "rsync:  $test_temp_dir/mnt/backup/git/host/user/repo-2/ $HOME/git/host/user/repo-2"
  assert_output --partial "rsync:  $test_temp_dir/mnt/backup/git/host/user/repo-3/ $HOME/git/host/user/repo-3"
}

@test "rsync flags" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$test_temp_dir/mnt/backup/git"

  # Assert
  assert_equal "$status" 0
  assert_regex "$(mock_get_call_args "$mock_rsync")" \
    "^--chmod=Fuga-x --human-readable --itemize-changes --progress --recursive --stats --verbose .*$"
}

@test "git checks status" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$test_temp_dir/mnt/backup/git"

  # Assert
  assert_equal "$status" 0
  assert_equal "$(mock_get_call_args "$mock_git" 1)" "-C $HOME/git/host/user/repo-1 status --porcelain"
  assert_equal "$(mock_get_call_args "$mock_git" 3)" "-C $HOME/git/host/user/repo-2 status --porcelain"
  assert_equal "$(mock_get_call_args "$mock_git" 4)" "-C $HOME/git/host/user/repo-3 status --porcelain"
}

@test "modified file in git repo is the only one that is diffed" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$test_temp_dir/mnt/backup/git"

  # Assert
  assert_equal "$status" 0
  assert_equal "$(mock_get_call_args "$mock_git" 1)" "-C $HOME/git/host/user/repo-1 status --porcelain"
  assert_equal "$(mock_get_call_args "$mock_git" 2)" "-C $HOME/git/host/user/repo-1 diff -- modified.file"
  assert_equal "$(mock_get_call_args "$mock_git" 3)" "-C $HOME/git/host/user/repo-2 status --porcelain"
}
