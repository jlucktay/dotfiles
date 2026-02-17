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

# eza
if command -v eza &> /dev/null; then
	alias ll='eza --all --classify --colour-scale --colour=always --git --group-directories-first --icons --long'
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

# Better process view with 'btop' than macOS 'top'
if command -v btop &> /dev/null; then
	alias top=btop
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

if command -v git &> /dev/null; then
	# Change working directory up to the top level of the current git repo.
	alias cdt='cd "$(git rev-parse --show-toplevel)"'

	if command -v terraform &> /dev/null; then
		# Run 'terraform fmt' across all files in the current git repo.
		alias tfmt='terraform fmt --check=false --diff=false --list --recursive --write "$(git rev-parse --show-toplevel)"'
	fi
fi

# https://docs.commonfate.io/granted/usage/assuming-roles
if command -v assume &> /dev/null; then
	alias assume=". assume"
fi

if command -v chezmoi &> /dev/null; then
	alias cdes='chezmoi diff --exclude=scripts'
fi

# https://kubecm.cloud
if command -v kubecm &> /dev/null; then
	alias kubecm='kubecm --silence-table'
	alias kc='kubecm switch'
	alias kn='kubecm namespace'
fi
