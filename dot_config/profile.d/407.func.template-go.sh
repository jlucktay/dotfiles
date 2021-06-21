if command -v git &> /dev/null; then
  function template_go() {
    local current_git_repo
    current_git_repo=$(get_git_root)
    local template_go_repo="$HOME/git/github.com/jlucktay/template-go/"

    if [ -z "$current_git_repo" ]; then
      echo "${FUNCNAME[0]}: the current working directory is not inside a git repository"
      return 1
    fi

    if [ ! -d "$template_go_repo" ]; then
      echo "${FUNCNAME[0]}: the 'template-go' repo has not been checked out to '$template_go_repo'; remedying..."
      gmkdir --parents --verbose "$template_go_repo"
      git clone https://github.com/jlucktay/template-go.git "$template_go_repo"
    fi

    if ! git --git-dir="$template_go_repo.git" --work-tree="$template_go_repo" diff-index --quiet HEAD --; then
      echo "${FUNCNAME[0]}: the 'template-go' repo at '$template_go_repo' is dirty"
      return 1
    fi

    function usage() {
      \cat << HEREDOC

    Usage: ${FUNCNAME[1]} [--help|--confirm]

    Will run 'rsync' on the git repo located at or above the current working directory, to bring in files from my
    template-go repository (located at '$template_go_repo').

    Optional arguments:
        -c, --confirm       actually perform the rsync; don't do a dry run
        -d, --diff          run a diff between the template and the current working directory
        -h, --help          show this help message and exit

HEREDOC
    }

    local confirmed=0
    local run_diff=0

    for arg in "$@"; do
      case $arg in
        -h | --help)
          usage
          return 0
          ;;
        -c | --confirm)
          confirmed=1
          shift
          ;;
        -d | --diff)
          run_diff=1
          shift
          ;;
        *) # unknown option
          echo "${FUNCNAME[0]}: argument '$arg' unknown"
          usage
          return 1
          ;;
      esac
    done

    local -a rsync_args
    rsync_args+=(--checksum)

    if ((confirmed != 1)); then
      rsync_args+=(--dry-run)
    fi

    rsync_args+=(
      --exclude=.git
      --exclude=go.mod
      --exclude=go.sum
      --itemize-changes
      --recursive
      "$template_go_repo"
      "$current_git_repo"/
    )

    echo "${FUNCNAME[0]}: running 'rsync' with the following arguments: ${rsync_args[*]}"

    rsync "${rsync_args[@]}"

    if ((run_diff == 1)); then
      fd --hidden --no-ignore --max-depth=1 --type=file --exclude "go.mod" --exclude "go.sum" . "$template_go_repo" \
        --exec git diff --color=always "{}" "$current_git_repo/{/}"
    fi

    if ((confirmed != 1)); then
      echo
      echo "Re-run '${FUNCNAME[0]}' with '--confirm' to execute previewed diff/rsync."
    fi
  }
fi
