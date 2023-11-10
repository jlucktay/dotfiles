# As per the docs linked below, direnv needs to be hooked last.
# https://direnv.net/docs/hook.html

# If direnv is installed, hook it up.
if command -v direnv &> /dev/null; then
  dhb=$(direnv hook bash)
  eval "$dhb"
fi
