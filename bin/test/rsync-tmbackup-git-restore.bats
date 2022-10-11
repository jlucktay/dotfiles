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
      "?? another.new.file" \
      " M different.modified.file"
  )

  git_mod_file_1_output=$(
    printf "%s\n%s\n%s\n" \
      "diff --git a/modified.file b/modified.file" \
      "old mode 100755" \
      "new mode 100644"
  )

  git_mod_file_2_output=$(
    printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n" \
      "diff --git a/different.modified.file b/different.modified.file" \
      "index c68a77c..1aadadb 100644" \
      "--- a/different.modified.file" \
      "+++ b/different.modified.file" \
      "@@ -1,2 +1,5 @@" \
      " # Directories" \
      " test/" \
      "+" \
      "+# Project-centric scripts" \
      "+lint-bash.sh"
  )

  mock_set_output "$mock_git" "$git_status_porcelain" 1
  mock_set_output "$mock_git" "$git_mod_file_1_output" 2
  mock_set_side_effect "$mock_git" 'echo "git restore: $5"' 3
  mock_set_output "$mock_git" "$git_mod_file_2_output" 4
  mock_set_side_effect "$mock_git" 'echo "git:  $8 $9"' 5
  mock_set_side_effect "$mock_git" 'echo "git:  $8 $9"' 6

  # Add SUT and mocks to the front of PATH so they are all a) callable and b) take priority
  PATH="$test_temp_dir:$PATH"
}

teardown() {
  temp_del "$test_temp_dir"
}

@test "run without arguments gives non-zero exit status and an error" {
  run rsync-tmbackup-git-restore.sh
  assert_failure
  assert_output "Please provide a source directory as the first argument!"
}

@test "run with valid directory argument reports only outermost non-submodule repos" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$test_temp_dir/mnt/backup/git"

  # Assert
  assert_success
  assert [ "$(echo "$output" | grep --count '^')" -ge 3 ]
  assert_output --partial "Discovering repos under '$test_temp_dir/mnt/backup/git'... found 6 of which 3 will be restored."
  assert_output --partial "Found:  $test_temp_dir/mnt/backup/git/host/user/repo-1/.git"
  assert_output --partial "Found:  $test_temp_dir/mnt/backup/git/host/user/repo-2/.git"
  assert_output --partial "Found:  $test_temp_dir/mnt/backup/git/host/user/repo-3/.git"
}

@test "run creates necessary target directories" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$test_temp_dir/mnt/backup/git"

  # Assert
  assert_success
  assert [ "$(echo "$output" | grep --count '^')" -ge 3 ]
  assert_equal "$(mock_get_call_num "$mock_mkdir")" 3
  assert_equal "$(mock_get_call_args "$mock_mkdir" 1)" "-pv $HOME/git/host/user/repo-1"
  assert_equal "$(mock_get_call_args "$mock_mkdir" 2)" "-pv $HOME/git/host/user/repo-2"
  assert_equal "$(mock_get_call_args "$mock_mkdir" 3)" "-pv $HOME/git/host/user/repo-3"
  assert_output --partial "Create: mkdir: $HOME/git/host/user/repo-1"
  assert_output --partial "Create: mkdir: $HOME/git/host/user/repo-2"
  assert_output --partial "Create: mkdir: $HOME/git/host/user/repo-3"
}

@test "rsync from source to target" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$test_temp_dir/mnt/backup/git"

  # Assert
  assert_success
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
  assert_success
  assert_regex "$(mock_get_call_args "$mock_rsync")" \
    "^--chmod=Fuga-x --human-readable --itemize-changes --progress --recursive --stats --verbose .*$"
}

@test "git checks status" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$test_temp_dir/mnt/backup/git"

  # Assert
  assert_success
  assert_equal "$(mock_get_call_args "$mock_git" 1)" "-C $HOME/git/host/user/repo-1 status --porcelain"
  assert_equal "$(mock_get_call_args "$mock_git" 5)" "-C $HOME/git/host/user/repo-2 status --porcelain"
  assert_equal "$(mock_get_call_args "$mock_git" 6)" "-C $HOME/git/host/user/repo-3 status --porcelain"
}

@test "in the git repo, the modified file with a different mode is the only one that is restored" {
  # Arrange
  # handled in setup()

  # Act
  run rsync-tmbackup-git-restore.sh "$test_temp_dir/mnt/backup/git"

  # Assert
  assert_success
  assert_equal "$(mock_get_call_args "$mock_git" 1)" "-C $HOME/git/host/user/repo-1 status --porcelain"
  assert_equal "$(mock_get_call_args "$mock_git" 2)" "-C $HOME/git/host/user/repo-1 diff -- modified.file"
  assert_equal "$(mock_get_call_args "$mock_git" 3)" "-C $HOME/git/host/user/repo-1 restore -- modified.file"
  assert_equal "$(mock_get_call_args "$mock_git" 4)" "-C $HOME/git/host/user/repo-1 diff -- different.modified.file"
  assert_equal "$(mock_get_call_args "$mock_git" 5)" "-C $HOME/git/host/user/repo-2 status --porcelain"
}
