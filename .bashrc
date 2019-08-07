#!/usr/bin/env bash

# Start the clock - check this at the end, to see how long .bashrc takes to run through
TimeStart=$(gdate +%s%N)

# Don't run this for every single terminal because it's pretty slow
if (( RANDOM < 6553 )); then
    screenfetch
fi

# Wire up my Go, Bash (+coreutils), and Python scripts directories
GOPATH=$(go env GOPATH)
export GOPATH
GOROOT=$(go env GOROOT)
export GOROOT

PATH="$HOME/bin:$GOPATH/bin:/usr/local/opt/go/libexec/bin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/make/libexec/gnubin:$HOME/Library/Python/3.7/bin:$PATH"
export PATH

# https://swarm.cs.pub.ro/~razvan/blog/some-bash-tricks-cdpath-and-inputrc/
CDPATH=".:$HOME/git/github.com/Dentsu-Aegis-Network-Global-Technology"
export CDPATH

MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
export MANPATH

### Environment variables
# If I have to edit something in a terminal window, I like using Nano
export EDITOR=/usr/bin/nano

# GPG things
GPG_TTY=$(tty)
export GPG_TTY

# Colourful terminal
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Terraform
export TF_VAR_region="eu-west-2" # London
export TF_VAR_aws_region=$TF_VAR_region
export TF_VAR_state_dynamodb="jlucktay.tfstate"
export TF_VAR_state_bucket="$TF_VAR_state_dynamodb.london"

# AWS SDK for Go
export AWS_SDK_LOAD_CONFIG=true

# Homebrew should clean up after itself
export HOMEBREW_INSTALL_CLEANUP=1

### Bash setup
# Fix for searching forward through command history
stty -ixon

### Prompt setup
# Git info in the prompt
if [ -f "$HOME/git-prompt.sh" ]; then
    # shellcheck source=/Users/jameslucktaylor/git-prompt.sh
    source "$HOME/git-prompt.sh"
else
    echo "'$HOME/git-prompt.sh' not available"
fi

# Fancy colourful prompt, including git info
PROMPT_COMMAND='__posh_git_ps1 "\[\033[38;5;14m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\]@\[$(tput sgr0)\]\[\033[38;5;13m\]\H\[$(tput sgr0)\]\[\033[38;5;15m\] [\[$(tput sgr0)\]\[\033[38;5;11m\]\W\[$(tput sgr0)\]\[\033[38;5;15m\]] \$? " "\n\[$(tput sgr0)\]\[\033[38;5;10m\]\t\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;9m\]\\$\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"'

# Bash completion
export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

## Git tab completion
# shellcheck source=/Users/jameslucktaylor/git-completion.bash
source "$HOME/git-completion.bash"

# Sceptre autocomplete
# shellcheck source=/Users/jameslucktaylor/git/cloudreach/sceptre-bash-autocomplete/sceptre_completion.sh
# source ~/git/cloudreach/sceptre-bash-autocomplete/sceptre_completion.sh

### Useful aliases/functions
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

# Alternative commands (thank you: https://remysharp.com/2018/08/23/cli-improved)
alias cat=bat
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias ping='prettyping --nolegend'

export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(code {})+abort'"

# shellcheck source=/Users/jameslucktaylor/.fzf.bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

function git-outdated-sync(){
    find . -type d -name .git -not -path "*/.terraform/*" -execdir bash -c "pwd ; git pull --all ; git push --all ; echo" \;
}

function lb() {
    LogbooksDir="$HOME/logbooks"
    if ! [[ -d "$LogbooksDir" ]]; then
        mkdir -pv "$LogbooksDir"
    fi
    if ! [[ -f "$LogbooksDir/bin/loop.rsync.sh" ]]; then
        gsutil cp -J gs://jlucktay-logbooks-eu/bin/loop.rsync.sh "$LogbooksDir/bin/loop.rsync.sh"
    fi
    code "$LogbooksDir/logbook.$(gdate '+%Y%m%d').md"
}

# Bash ls
alias ls='gls --color --human-readable'
alias ll='gls -l --color --almost-all --classify --human-readable'

# Miscellaneous
alias acsjl="awsume celab --session-name james.lucktaylor"
alias did='vim +"normal Go" +"r!date" +"normal Go" $HOME/did.txt'
alias gdn="gdate '+%Y%m%d.%H%M%S.%N%z'"
alias gofmtsw='find . -type f -iname "*.go" -exec gofmt -s -w "{}" +'
alias hlh='find $HOME -type f -name Dockerfile -path "*/jlucktay/*" -not -path "*/.terraform/*" -exec hadolint "{}" + 2>/dev/null'
alias jq='jq --sort-keys'
alias sauron='sudo ncdu --color dark -rr -x --exclude .git --exclude node_modules /'
alias tb="nc termbin.com 9999"
alias tfmt='find . -type f -iname "*.tf" -execdir terraform fmt --check=false --diff=false --list=true --write=true \;'

# Kubernetes/K8s
function k8staints(){
    # shellcheck disable=SC2016
    kubectl get nodes -o go-template='{{printf "%-47s %-12s\n" "Node" "Taint"}}{{- range .items}}{{- if $taint := (index .spec "taints") }}{{- .metadata.name }}{{ "\t" }}{{- range $taint }}{{- .key }}={{ .value }}:{{ .effect }}{{ "\t" }}{{- end }}{{- "\n" }}{{- end}}{{- end}}'
}

# DAN
DANADGuid="defecd80-a314-44a2-9427-cea2732d22af"

alias dantfclean="find \$HOME/go/src/github.com/Dentsu-Aegis-Network-Global-Technology \$HOME/git/github.com/Dentsu-Aegis-Network-Global-Technology \( \( -type d -name \".terraform\" \) -o \( -type f -iname \"terraform*.*tfstate*\" \) \) -exec rm -rfv -- \"{}\" + | grep -vE \"\/[0-9a-f]{32}\" | grep -E \"^removed directory '\""

function dankvperms(){
    for Subscription in $(jq -r '.[] | select( .name | startswith("VDC") )' \
    "$HOME/go/src/github.com/Dentsu-Aegis-Network-Global-Technology/dan-migration-factory/subscriptions.json" \
    | jq -r '(.name[0:9] + "/" + .id)')
    do
        (
            echo "$(gdn) - CLZID ${Subscription:0:9} - GUID ${Subscription:10}"
            az account set --subscription="${Subscription:10}"
            az keyvault set-policy --name "${Subscription:0:9}-kv-euw1-vm" \
                --object-id $DANADGuid \
                --secret-permissions delete get list set \
                --key-permissions create delete get list \
                | jq ".properties.accessPolicies[] | select(.objectId == \"$DANADGuid\") | .permissions"
            az keyvault set-policy --name "${Subscription:0:9}-kv-euw1-disks" \
                --object-id $DANADGuid \
                --secret-permissions delete get list set \
                --key-permissions create delete get list \
                | jq ".properties.accessPolicies[] | select(.objectId == \"$DANADGuid\") | .permissions"
        )
    done
}

# Thank you: https://wiki-dev.bash-hackers.org/syntax/pe
function danchangelog(){
    for Repo in "$HOME"/git/github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-*
    do
        (
            cd "$(realpath "$Repo")" || return
            git --no-pager \
                log --color \
                --after="$(date --iso-8601=date --date='last Monday')T00:00:00+00:00" \
                --before="$(date --iso-8601=date)T00:00:00+00:00" \
                --format=format:"%Cgreen[${Repo##*/}] %C(bold blue)%h%C(reset) - %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" \
                master \
                | sed  '/^$/d'
        )
    done
}

function danmodver(){
    for Repo in "$HOME"/git/github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-*
    do
        (
            cd "$(realpath "$Repo")" || return
            printf "%s?ref=%s\n" "$(echo "$Repo" | cut -d'/' -f5-)" "$(git tag --list | sort --version-sort | tail -n 1)"
        )
    done
}

function gocover (){
    local t
    t=$(mktemp -t gocover)
    go test "$COVERFLAGS" -coverprofile="$t" "$@" \
        && go tool cover -func="$t" \
        && unlink "$t"
}

function stashcheck(){
    while IFS= read -r -d '' Git; do
        mapfile -t Stash < <(GIT_DIR=$Git git stash list)

        if (( ${#Stash[@]} > 0 )); then
            realpath "$Git/.."
        fi
        for StashLine in "${Stash[@]}"; do
            printf "\t%s\n" "$StashLine"
        done
    done < <(find "$HOME/go/src" "$HOME/git" -type d -name ".git" -print0)
}

# http://linux.byexamples.com/archives/332/what-is-your-10-common-linux-commands/
function top10(){
    HISTTIMEFORMAT="" history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n10
}

alias chrome_cloudreach='open --new -a "Google Chrome" --args --profile-directory=Default'
alias chrome_personal='open --new -a "Google Chrome" --args --profile-directory="Profile 1"'
alias chrome_dad='open --new -a "Google Chrome" --args --profile-directory="Profile 5"'

# AWS things, like labs
export AWS_DEFAULT_PROFILE=cr-labs-jlucktay

function awsregions(){
    aws ec2 describe-regions --region $TF_VAR_aws_region | jq -r '.Regions[].RegionName' | sort -f
}
export -f awsregions

# Azure things, also lab-esque
function azregions(){
    az account list-locations | jq -r '.[].name' | sort -f
}
export -f azregions

# Virtual MFA token, just give it the secret
function mmfa(){
    oathtool --base32 --totp "$1" ;
}

# AWSume alias to source the AWSume script
alias awsume=". awsume"

# Auto-Complete function for AWSume
function _awsume(){
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(awsumepy --rolesusers)
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
}
complete -F _awsume awsume

#   mans:    Search manpage given in agument '1' for term given in argument '2' (case insensitive).
#            Displays paginated result with colored search terms and two lines surrounding each hit.
#   Example: mans mplayer codec
#   --------------------------------------------------------------------
function mans(){
    man "$1" | grep -iC2 "$2" | less
}

# Set options for 'less'
export LESS='--quit-if-one-screen --ignore-case --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-4'

# Set colors for less. Borrowed from https://wiki.archlinux.org/index.php/Color_output_in_console#less .
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

export LESSOPEN="|/usr/local/bin/lesspipe.sh %s" LESS_ADVANCED_PREPROCESSOR=1

if type pygmentize >/dev/null 2>&1; then
    export LESSCOLORIZER='pygmentize'
fi

### iTerm2 shell integration
# shellcheck source=/Users/jameslucktaylor/.iterm2_shell_integration.bash
[[ -e "${HOME}/.iterm2_shell_integration.bash" ]] && source "${HOME}/.iterm2_shell_integration.bash"

# Used for the badge
function iterm2_print_user_vars(){
    iterm2_set_user_var currentDir "${PWD##*/}"
}

# GCP SDK integration
. /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc
. /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc

# Eternal bash history
# --------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "

# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=$HOME/.bash_eternal_history

# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# https://ss64.com/bash/history.html
export HISTCONTROL=erasedups:ignoreboth
shopt -s histappend

# https://www.linuxjournal.com/content/globstar-new-bash-globbing-option
shopt -s globstar

# Autojump!
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# Perl
eval "$(perl "-I$HOME/perl5/lib/perl5" "-Mlocal::lib=$HOME/perl5")"

# Android SDK/NDK things
export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"

# Cheat sheet - keep this second last
if [ -f "$HOME/bash-cheat-sheet.txt" ]; then
    \cat "$HOME/bash-cheat-sheet.txt"
else
    echo "'$HOME/bash-cheat-sheet.txt' not available"
fi

# Stop the clock - keep this last
TimeTaken=$((($(gdate +%s%N) - TimeStart)/1000000))
echo ".bashrc: ${TimeTaken}ms"
