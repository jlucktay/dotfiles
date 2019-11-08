export XDG_CACHE_HOME="$HOME/Library/Caches/org.freedesktop"

if hash gmkdir 2>/dev/null; then
    gmkdir --parents "${XDG_CACHE_HOME}"
else
    mkdir -p "${XDG_CACHE_HOME}"
fi
