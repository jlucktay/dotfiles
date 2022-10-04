# https://formulae.brew.sh/cask/google-cloud-sdk
# $ brew info google-cloud-sdk
if test -r "${HOMEBREW_PREFIX:?}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"; then
  # shellcheck disable=SC1091
  source "${HOMEBREW_PREFIX:?}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
fi
