if command -v nc &> /dev/null; then
	function tb() {
		echo "Sending '$*' to termbin..."
		nc termbin.com 9999 < "$*"
	}

	export -f tb
fi
