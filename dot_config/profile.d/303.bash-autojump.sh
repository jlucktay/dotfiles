# Autojump!
if test -r "${HOMEBREW_PREFIX:?}/etc/profile.d/autojump.sh"; then
  # shellcheck disable=SC1091
  source "${HOMEBREW_PREFIX:?}/etc/profile.d/autojump.sh"
fi
