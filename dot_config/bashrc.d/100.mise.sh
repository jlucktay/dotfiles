# Activate mise so that 'command -v <binary>' checks work in this and subsequent scripts.
if [[ -x "$HOME/.cargo/bin/mise" ]]; then
  mab="$("$HOME/.cargo/bin/mise" activate bash)"
  eval "$mab"
  unset mab
fi
