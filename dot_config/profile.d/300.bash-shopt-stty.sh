# Bash setup

## https://www.linuxjournal.com/content/globstar-new-bash-globbing-option
shopt -s globstar

## https://unix.stackexchange.com/questions/12107/how-to-unfreeze-after-accidentally-pressing-ctrl-s-in-a-terminal
stty -ixon -ixoff

## Bind keys to shell operations/functions

### Perform history expansion on the current line and insert a space
bind 'Space: magic-space'

### Replaces the word to be completed with a single match from the list of possible completions.
### Repeated execution of menu-complete steps through the list of possible completions, inserting each match in turn.
bind 'TAB: menu-complete'
bind '"\e[Z": menu-complete-backward'
