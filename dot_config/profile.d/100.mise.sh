# Activate mise with shims so that 'command -v <binary>' checks work in this and subsequent scripts.
if [[ -x "$HOME/.cargo/bin/mise" ]]; then
  mabs="$("$HOME/.cargo/bin/mise" activate bash --shims)"
  eval "$mabs"
  unset mabs
fi
