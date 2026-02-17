# Cheat sheet
if { [[ -r /etc/hostname ]] && [[ "$(< /etc/hostname)" =~ ^rpi[28]-[1-3]$ ]]; } \
	|| (command -v hostname &> /dev/null && [[ $(hostname || true) =~ ^rpi[28]-[1-3]$ ]]); then
	# No-op on my home Pi cluster
	:
elif test -r "$HOME/bash-cheat-sheet.txt"; then
	\cat "$HOME/bash-cheat-sheet.txt"
else
	echo "'$HOME/bash-cheat-sheet.txt' not available"
fi
