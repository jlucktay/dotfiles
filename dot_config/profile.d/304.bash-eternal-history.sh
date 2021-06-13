# Eternal bash history
# --------------------
# Set the size to unlimited by preventing truncation.
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=-1
export HISTSIZE=-1

export HISTTIMEFORMAT="[%F %T] "

# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE="$HOME"/.bash_eternal_history

# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
#
# Important to append rather than prepend, as the __prompt_command func checks $?
PROMPT_COMMAND+="; history -a"

# https://ss64.com/bash/history.html
## Setting the following makes Bash erase duplicate commands in your history.
export HISTCONTROL=erasedups:ignoreboth

## You definitely want to set histappend.
## Otherwise, Bash overwrites your history when you exit.
shopt -s histappend
