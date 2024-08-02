if command -v mise &> /dev/null; then
  mab="$(mise activate bash)"
  eval "$mab"
fi
