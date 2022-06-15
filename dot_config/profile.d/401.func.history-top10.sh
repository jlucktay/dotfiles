# http://linux.byexamples.com/archives/332/what-is-your-10-common-linux-commands/
function top10() {
  local history_output
  history_output=$(HISTTIMEFORMAT="" history)

  local awk_output
  awk_output=$(awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' \
    <<< "$history_output")

  local grep_output
  grep_output=$(grep --invert-match "./" <<< "$awk_output")

  local column_output
  column_output=$(column -c 3 -s " " -t <<< "$grep_output")

  local sort_output
  sort_output=$(sort --numeric-sort --reverse <<< "$column_output")

  local nl_output
  nl_output=$(nl <<< "$sort_output")

  head -n 10 <<< "$nl_output"
}
