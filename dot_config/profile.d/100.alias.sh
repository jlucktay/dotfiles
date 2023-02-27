### Useful aliases/functions

# Interactive and verbose
if command -v gcp &> /dev/null; then
  alias cp='gcp -iv'
else
  alias cp='cp -iv'
fi
if command -v gmv &> /dev/null; then
  alias mv='gmv -iv'
else
  alias mv='mv -iv'
fi
if command -v grm &> /dev/null; then
  alias rm='grm -iv'
else
  alias rm='rm -iv'
fi

# Alternative commands (thank you: https://remysharp.com/2018/08/23/cli-improved)
if command -v bat &> /dev/null; then
  alias cat=bat
fi

# The Debian package for 'bat' has a clash so it names the same binary 'batcat'.
if command -v batcat &> /dev/null; then
  alias cat=batcat
fi

if command -v ncdu &> /dev/null; then
  alias du="ncdu -rr -x --color dark --exclude .git --exclude node_modules"
  alias sauron='sudo ncdu -rr -x --color dark --exclude .git --exclude node_modules --exclude /System/Volumes/Data /'
fi
if command -v prettyping &> /dev/null; then
  alias ping='prettyping --nolegend'
fi

# (GNU) ls
if command -v gls &> /dev/null; then
  alias ls='gls --color --human-readable'
else
  alias ls='ls --color --human-readable'
fi

# exa
if command -v exa &> /dev/null; then
  alias ll='exa --all --classify --colour-scale --colour=always --git --group-directories-first --icons --long'
  alias lll='ll --grid'
else
  alias ll='ls -l --almost-all --classify'
fi

# Visual Studio Code
if command -v code &> /dev/null; then
  alias killcode="ps -Af | grep 'Visual Studio Code' | grep -v grep | cut -d' ' -f4 | xargs kill -9"
fi

# Go
if command -v gofmt &> /dev/null; then
  alias gofmtsw='find . -type f -iname "*.go" -not -path "*/vendor/*" -exec gofmt -s -w "{}" +'
fi

# Chezmoi
if command -v chezmoi &> /dev/null; then
  alias cg='chezmoi git --'
fi

# Kubernetes CLI
if command -v kubectl &> /dev/null; then
  alias k=kubectl
fi

# Miscellaneous
alias did='vim +"normal Go" +"r!date" +"normal Go" $HOME/did.txt'

if command -v hadolint &> /dev/null; then
  alias hlh="find . -type f -name Dockerfile \
    -not -path \"*/.terraform/*\" \
    -not -path \"*/vendor/*\" \
    -exec hadolint \"{}\" + 2>/dev/null"
fi

if command -v jq &> /dev/null; then
  alias jq='jq --sort-keys'
fi

if command -v git &> /dev/null && command -v terraform &> /dev/null; then
  # Run 'terraform fmt' across all files in the current git repo.
  alias tfmt='terraform fmt --check=false --diff=false --list --recursive --write "$(git rev-parse --show-toplevel)"'
fi
