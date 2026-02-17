# http://linux.byexamples.com/archives/332/what-is-your-10-common-linux-commands/
function top10() {
	local -
	set -o pipefail

	HISTTIMEFORMAT="" history \
		| awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' \
		| grep --invert-match "./" \
		| column -c 3 -s " " -t \
		| sort --numeric-sort --reverse \
		| nl \
		| head -n 10
}
