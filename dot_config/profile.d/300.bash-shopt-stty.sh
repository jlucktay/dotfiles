# Bash setup

## https://www.linuxjournal.com/content/globstar-new-bash-globbing-option
shopt -s globstar

## https://unix.stackexchange.com/questions/12107/how-to-unfreeze-after-accidentally-pressing-ctrl-s-in-a-terminal
stty -ixon -ixoff

## Bind keys to shell operations/functions

### Perform history expansion on the current line and insert a space
bind 'Space: magic-space'
