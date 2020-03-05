if hash go &> /dev/null && hash goimports &> /dev/null; then
  function goimplvw() {
    local git_root
    git_root=$(get_git_root)

    if [ -z "$git_root" ]; then
      return 0
    fi

    # Trim last three directories (site/owner/repo) from git root directory
    loc=$(echo "$git_root" | rev | cut -d'/' -f1-3 | rev)

    find . -type f -iname "*.go" -not -path "*/vendor/*" \
      -execdir goimports -l -local "$loc" -w {} \;
  }

  export -f goimplvw
fi
