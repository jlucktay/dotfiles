#   mans:    Search manpage given in argument 1 for term given in argument 2 (case insensitive).
#            Displays paginated result with colored search terms and two lines surrounding each hit.
#   Example: mans mplayer codec
#   --------------------------------------------------------------------
function mans() {
  man "$1" | grep -iC2 "$2" | less
}
