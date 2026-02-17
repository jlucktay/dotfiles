# Set options for 'less'
export LESS="\
--HILITE-UNREAD \
--ignore-case \
--LONG-PROMPT \
--no-init \
--quit-if-one-screen \
--RAW-CONTROL-CHARS \
--tabs=2 \
--window=-4"

# Set colors for less. Borrowed from https://wiki.archlinux.org/index.php/Color_output_in_console#less .
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline

if command -v brew &> /dev/null; then
	lesspipe_path="$(brew --prefix)/bin/lesspipe.sh"

	if test -x "$lesspipe_path"; then
		export LESSOPEN="|$lesspipe_path %s"
		export LESS_ADVANCED_PREPROCESSOR=1
	fi
fi
