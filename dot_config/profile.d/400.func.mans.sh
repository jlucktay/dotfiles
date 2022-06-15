#   mans:    Search manpage given in argument 1 for term given in argument 2 (case insensitive).
#            Displays paginated result with colored search terms and two lines surrounding each hit.
#   Example: mans mplayer codec
#   --------------------------------------------------------------------
function mans() {
  local man_output
  man_output=$(man "$1")

  local grep_output
  grep_output=$(grep -iC2 "$2" <<< "$man_output")

  less <<< "$grep_output"
}
