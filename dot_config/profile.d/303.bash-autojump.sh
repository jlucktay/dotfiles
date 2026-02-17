# Autojump!
if test -r "${package_manager_prefix:?}/etc/profile.d/autojump.sh"; then
	# shellcheck disable=SC1091
	source "${package_manager_prefix:?}/etc/profile.d/autojump.sh"
fi
