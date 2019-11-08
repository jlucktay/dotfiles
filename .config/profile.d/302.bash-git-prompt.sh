### Prompt setup
# Git info in the prompt
if [ -f "$HOME/posh-git-prompt.sh" ]; then
    # shellcheck disable=SC1090
    source "$HOME/posh-git-prompt.sh"

    PROMPT_COMMAND='__posh_git_ps1 "\[\033[38;5;14m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\]@\[$(tput sgr0)\]\[\033[38;5;13m\]\H\[$(tput sgr0)\]\[\033[38;5;15m\] [\[$(tput sgr0)\]\[\033[38;5;11m\]\W\[$(tput sgr0)\]\[\033[38;5;15m\]] \$? " "\n\[$(tput sgr0)\]\[\033[38;5;10m\]\t\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;9m\]\\$\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"'$PROMPT_COMMAND
else
    echo "'$HOME/posh-git-prompt.sh' is not available: https://github.com/lyze/posh-git-sh"
fi
