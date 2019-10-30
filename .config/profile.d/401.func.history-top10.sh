# http://linux.byexamples.com/archives/332/what-is-your-10-common-linux-commands/
function top10(){
    HISTTIMEFORMAT="" history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n10
}
