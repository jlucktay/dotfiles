# https://formulae.brew.sh/cask/google-cloud-sdk
# $ brew info google-cloud-sdk
if test -r "${package_manager_prefix:?}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"; then
	# shellcheck disable=SC1091
	source "${package_manager_prefix:?}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
fi
