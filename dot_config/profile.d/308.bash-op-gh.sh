# https://developer.1password.com/docs/cli/shell-plugins/github/
if test -r "$HOME/.config/op/plugins.sh"; then
	# shellcheck disable=SC1091
	source "$HOME/.config/op/plugins.sh"
fi
