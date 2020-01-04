function get_git_root() {
  if git rev-parse --show-toplevel &> /dev/null; then
    git rev-parse --show-toplevel
  fi
}
