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

# Kubernetes/K8s
function k8staints(){
    # shellcheck disable=SC2016
    kubectl get nodes -o go-template='{{printf "%-47s %-12s\n" "Node" "Taint"}}{{- range .items}}{{- if $taint := (index .spec "taints") }}{{- .metadata.name }}{{ "\t" }}{{- range $taint }}{{- .key }}={{ .value }}:{{ .effect }}{{ "\t" }}{{- end }}{{- "\n" }}{{- end}}{{- end}}'
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
                --before="$(date --iso-8601=date)T18:00:00+00:00" \
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

# AWSume alias to source the AWSume script
alias awsume=". awsume"

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
