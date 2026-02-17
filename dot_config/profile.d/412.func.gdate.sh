if command -v gdate &> /dev/null; then
	function gdn() {
		TZ=UTC gdate '+%Y%m%dT%H%M%SZ'
	}
else
	function gdn() {
		TZ=UTC date '+%Y%m%dT%H%M%SZ'
	}
fi

export -f gdn
