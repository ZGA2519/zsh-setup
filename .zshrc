# Start things up
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Shortcut
alias c="code"
alias vim="nvim"
alias l="exa"
alias ll="exa -a"
alias lll="exa -al"
alias cls="clear"
alias cat="bat"
alias catp="bat -p"
alias qq="exit"
alias mtp="multipass"
## git 
alias gi="git init"
alias gl="git log"
alias gsts="git status"
alias gr="git remote -v"
alias gra="git remote add"
alias gch="git checkout"
alias gpll="git pull"
alias gpsh="git push"
alias ga="git add"
alias gc="git commit -m"
alias gb="git branch"

# Export
export PATH=/usr/local/mysql/bin:$PATH
export PATH=/opt/homebrew/bin:$PATH

# Addional software & paths setup
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

[ -f "/Users/organ/.ghcup/env" ] && source "/Users/organ/.ghcup/env" # ghcup-env
# bun completions
[ -s "/Users/organ/.bun/_bun" ] && source "/Users/organ/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# Python and pip config 
alias python="/opt/homebrew/bin/python3"
if [ -x "./bin/python3" ]; then
    # If it exists, create an alias for python3
    alias python3='./bin/python3'
fi
if [ -x "./bin/pip3" ]; then
    # If it exists, create an alias for pip
    alias pip3='./bin/pip3'
fi

