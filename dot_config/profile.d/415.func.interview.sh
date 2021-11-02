function interview() {
  local stat_binary=stat
  local tr_binary=tr

  if command -v gstat &> /dev/null; then stat_binary=gstat; fi
  if command -v gtr &> /dev/null; then tr_binary=gtr; fi

  # Equivalent of macOS "open" for all the other modern *nixes.
  if ! command -v open &> /dev/null; then
    function open() {
      for arg in "$@"; do
        setsid nohup xdg-open "$arg" &> /dev/null
      done
    }
  fi

  # Stat the '_template.txt' file first, to make sure we can duplicate it later if necessary.
  template_file=$HOME/Documents/Notes/Candidates/_template.txt

  if ! $stat_binary "$template_file" &> /dev/null; then
    return 1
  fi

  declare -a filtered=()

  # Take the '$@' array of arguments, and 'tr' each arg to filter down to lowercase alphanumeric characters only.
  for arg in "$@"; do
    local tr_alnum tr_lower
    tr_alnum=$($tr_binary -cd "[:alnum:]" <<< "$arg")
    tr_lower=$($tr_binary '[:upper:]' '[:lower:]' <<< "$tr_alnum")
    filtered+=("$tr_lower")
  done

  # Set up a temporary function.
  function join_by {
    local IFS="$1"
    shift
    echo "$*"
  }

  # Join the filtered down list with hyphens, to derive the target filename.
  local target_filename
  target_filename=$HOME/Documents/Notes/Candidates/$(join_by - "${filtered[@]}").txt

  # Clear out the temporary function.
  unset join_by

  # Stat the target filename;  if it does not exist, use 'touch' to create.
  if ! $stat_binary "$target_filename" &> /dev/null; then
    cp "$template_file" "$target_filename"
  fi

  # Open the target file.
  open "$target_filename"
}
