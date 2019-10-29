### Useful aliases/functions
alias cp='gcp -iv'
alias mv='gmv -iv'
alias rm='grm -iv'

# Alternative commands (thank you: https://remysharp.com/2018/08/23/cli-improved)
alias cat=bat
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias ping='prettyping --nolegend'

# Bash ls
alias ls='gls --color --human-readable'
alias ll='gls -l --color --almost-all --classify --human-readable'

# Miscellaneous
alias did='vim +"normal Go" +"r!date" +"normal Go" $HOME/did.txt'
alias gdn="gdate '+%Y%m%d.%H%M%S.%N%z'"
alias gofmtsw='find . -type f -iname "*.go" -exec gofmt -s -w "{}" +'
alias hlh='find $HOME -type f -name Dockerfile -path "*/jlucktay/*" -not -path "*/.terraform/*" -exec hadolint "{}" + 2>/dev/null'
alias jq='jq --sort-keys'
alias sauron='sudo ncdu --color dark -rr -x --exclude .git --exclude node_modules /'
alias tb="nc termbin.com 9999"
alias tfmt='find . -type f -iname "*.tf" -execdir terraform fmt --check=false --diff=false --list=true --write=true \;'
