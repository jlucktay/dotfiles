### Useful aliases/functions

# Interactive and verbose
if hash gcp 2> /dev/null; then
  alias cp='gcp -iv'
else
  alias cp='cp -iv'
fi
if hash gmv 2> /dev/null; then
  alias mv='gmv -iv'
else
  alias mv='mv -iv'
fi
if hash grm 2> /dev/null; then
  alias rm='grm -iv'
else
  alias rm='rm -iv'
fi

# Alternative commands (thank you: https://remysharp.com/2018/08/23/cli-improved)
if hash bat 2> /dev/null; then
  alias cat=bat
fi
if hash ncdu 2> /dev/null; then
  alias du="ncdu -rr -x --color dark --exclude .git --exclude node_modules"
  alias sauron='sudo ncdu -rr -x --color dark --exclude .git --exclude node_modules /'
fi
if hash prettyping 2> /dev/null; then
  alias ping='prettyping --nolegend'
fi

# (GNU) ls
if hash gls 2> /dev/null; then
  alias ls='gls --color --human-readable'
  alias ll='gls -l --almost-all --color --classify --human-readable'
else
  alias ls='ls -Gh'
  alias ll='ls -AFGlh'
fi

# Miscellaneous
alias did='vim +"normal Go" +"r!date" +"normal Go" $HOME/did.txt'

if hash gdate 2> /dev/null; then
  alias gdn="gdate '+%Y%m%d.%H%M%S.%N%z'"
else
  alias gdn="date '+%Y%m%d.%H%M%S%z'"
fi

if hash gofmt 2> /dev/null; then
  alias gofmtsw='find . -type f -iname "*.go" -exec gofmt -s -w "{}" +'
fi

if hash hadolint 2> /dev/null; then
  alias hlh='find . -type f -name Dockerfile -not -path "*/.terraform/*" -exec hadolint "{}" + 2>/dev/null'
fi

if hash jq 2> /dev/null; then
  alias jq='jq --sort-keys'
fi

if hash terraform 2> /dev/null; then
  alias tfmt='find . -type f -iname "*.tf" -execdir terraform fmt --check=false --diff=false --list=true --write=true \;'
fi
