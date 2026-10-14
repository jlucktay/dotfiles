# Per the docs (https://mise.jdx.dev/installing-mise.html#mise-run) mise should be installed directly under '$HOME/bin/' like so:
# > curl -fsSL https://mise.run | MISE_INSTALL_PATH="$HOME/bin/mise" sh

# Activate mise so that 'command -v <binary>' checks work in this and subsequent scripts.
if [[ -x $HOME/bin/mise ]]; then
	mab="$("$HOME"/bin/mise activate bash)"
	eval "$mab"
	unset mab
fi
