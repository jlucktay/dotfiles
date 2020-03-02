### Useful aliases/functions

# Interactive and verbose
if hash gcp &> /dev/null; then
  alias cp='gcp -iv'
else
  alias cp='cp -iv'
fi
if hash gmv &> /dev/null; then
  alias mv='gmv -iv'
else
  alias mv='mv -iv'
fi
if hash grm &> /dev/null; then
  alias rm='grm -iv'
else
  alias rm='rm -iv'
fi

# Alternative commands (thank you: https://remysharp.com/2018/08/23/cli-improved)
if hash bat &> /dev/null; then
  alias cat=bat
fi
if hash ncdu &> /dev/null; then
  alias du="ncdu -rr -x --color dark --exclude .git --exclude node_modules"
  alias sauron='sudo ncdu -rr -x --color dark --exclude .git --exclude node_modules /'
fi
if hash prettyping &> /dev/null; then
  alias ping='prettyping --nolegend'
fi

# (GNU) ls
if hash gls &> /dev/null; then
  alias ls='gls --color --human-readable'
  alias ll='gls -l --almost-all --color --classify --human-readable'
else
  alias ls='ls -Gh'
  alias ll='ls -AFGlh'
fi

# Visual Studio Code
if hash code &> /dev/null; then
  alias killcode="ps -Af | grep 'Visual Studio Code' | grep -v grep | cut -d' ' -f4 | xargs kill -9"
fi

# Go
if hash gofmt &> /dev/null; then
  alias gofmtsw='find . -type f -iname "*.go" -not -path "*/vendor/*" -exec gofmt -s -w "{}" +'
fi

# https://github.com/golangci/golangci-lint
if hash golangci-lint &> /dev/null; then
  function golint_enable_all() {
    local -a disabled enabled
    mapfile -t disabled < <(
      golangci-lint linters \
        | grep -A999 "^Disabled" \
        | tail -n +2 \
        | cut -d':' -f1 \
        | cut -d' ' -f1
    )

    for ((i = 0; i < ${#disabled[@]}; i += 1)); do
      enabled+=("--enable=${disabled[$i]}")
    done

    golangci-lint run "${enabled[@]}" "$@"
  }
fi

# Open specific Chrome profiles
alias chrome_personal='open -n -a "Google Chrome" --args --profile-directory="Profile 1"'
alias chrome_tyk='open -n -a "Google Chrome" --args --profile-directory="Default"'

# Miscellaneous
alias did='vim +"normal Go" +"r!date" +"normal Go" $HOME/did.txt'

if hash gdate &> /dev/null; then
  alias gdn="gdate '+%Y%m%d.%H%M%S.%N%z'"
else
  alias gdn="date '+%Y%m%d.%H%M%S%z'"
fi

if hash hadolint &> /dev/null; then
  alias hlh="find . -type f -name Dockerfile \
    -not -path \"*/.terraform/*\" \
    -not -path \"*/vendor/*\" \
    -exec hadolint \"{}\" + 2>/dev/null"
fi

if hash jq &> /dev/null; then
  alias jq='jq --sort-keys'
fi

if hash terraform &> /dev/null; then
  alias tfmt='find . -type f -iname "*.tf" -execdir terraform fmt --check=false --diff=false --list=true --write=true \;'
fi
