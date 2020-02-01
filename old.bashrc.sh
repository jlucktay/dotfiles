function git-outdated-sync() {
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

# Thank you: https://wiki-dev.bash-hackers.org/syntax/pe
function danchangelog() {
  for Repo in "$HOME"/git/github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-*; do
    (
      cd "$(realpath "$Repo")" || return
      git --no-pager \
        log --color \
        --after="$(date --iso-8601=date --date='last Monday')T00:00:00+00:00" \
        --before="$(date --iso-8601=date)T18:00:00+00:00" \
        --format=format:"%Cgreen[${Repo##*/}] %C(bold blue)%h%C(reset) - %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" \
        master \
        | sed '/^$/d'
    )
  done
}

function danmodver() {
  for Repo in "$HOME"/git/github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-*; do
    (
      cd "$(realpath "$Repo")" || return
      printf "%s?ref=%s\n" "$(echo "$Repo" | cut -d'/' -f5-)" "$(git tag --list | sort --version-sort | tail -n 1)"
    )
  done
}

function gocover() {
  local t
  t=$(mktemp -t gocover)
  go test "${COVERFLAGS:?}" -coverprofile="$t" "$@" \
    && go tool cover -func="$t" \
    && unlink "$t"
}

# Azure things, also lab-esque
function azregions() {
  az account list-locations | jq -r '.[].name' | sort -f
}
export -f azregions

# Virtual MFA token, just give it the secret
function mmfa() {
  oathtool --base32 --totp "$1"
}

# Auto-Complete function for AWSume
function _awsume() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  #shellcheck disable=SC2034
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  opts=$(awsumepy --rolesusers)
  COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
  return 0
}
complete -F _awsume awsume

# AWSume alias to source the AWSume script
alias awsume=". awsume"

# GCP SDK integration
. /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc
. /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc
