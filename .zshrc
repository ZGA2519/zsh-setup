export HOMEBREW_NO_ENV_HINTS=true

# Uncomment the following line if you want to use additional configuration
ADDITIONAL_CONFIG=true

# Start things up
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi
if command -v neofetch &> /dev/null; then
    neofetch
fi

# Greeting
echo '\033[0;32mHello' $USER! ', welcome back!!!' #\033[0m'

# Shortcut
if command -v code &> /dev/null; then
    alias c="code"
fi

if command -v nvim &> /dev/null; then
    alias vim="nvim"
fi
if command -v exa &> /dev/null; then
    alias l="exa"
    alias ll="exa -a"
    alias lll="exa -al"
fi
if command -v bat &> /dev/null; then
    alias cat="bat"
    alias catp="bat -p"
fi
alias cls="clear"
alias qq="exit"

## git 
if command -v git &> /dev/null; then
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
fi

# Check if ADDITIONAL_CONFIG=true do this
if [[ $ADDITIONAL_CONFIG == true ]]; then
    echo "ADDITIONAL_CONFIG is true"
    
    # Export
    if command -v mysql &> /dev/null; then
        export PATH=/usr/local/mysql/bin:$PATH
    fi
    if command -v brew &> /dev/null; then
        export PATH=/opt/homebrew/bin:$PATH
    fi
    if command -v java &> /dev/null; then
        export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
    fi
    if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
        export PATH=/opt/homebrew/opt/ruby/bin:$PATH
        export PATH=$(gem environment gemdir)/bin:$PATH
    fi

    if [ -f "/Users/organ/.ghcup/env" ]; then
        source "/Users/organ/.ghcup/env" # ghcup-env
    fi
    if [ -s "/Users/organ/.bun/_bun" ]; then
        source "/Users/organ/.bun/_bun" # bun completions
    fi

    if command -v bun &> /dev/null; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    fi

    # Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
    export PATH="$PATH:$HOME/.rvm/bin"
    if command -v ruby &> /dev/null; then
        export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    fi
    if command -v curl &> /dev/null; then
        export PATH="/opt/homebrew/opt/curl/bin:$PATH"
    fi

    # Python and pip config 
    if command -v python &> /dev/null; then
        if [ -x "./bin/python3" ]; then
            alias python='./bin/python3'
            #echo "Setting python alias to ./bin/python3"
        else
            alias python="/opt/homebrew/bin/python3"
            #echo "Setting python alias to /opt/homebrew/bin/python3"
        fi
    fi
    if command -v pip &> /dev/null; then
        if [ -x "./bin/pip3" ]; then
            alias pip='./bin/pip3'
            #echo "Setting pip alias to ./bin/pip3"
        elif [ -x "./bin/pip" ]; then
            alias pip='./bin/pip'
            #echo "Setting pip alias to ./bin/pip"
        else
            alias pip="/opt/homebrew/bin/pip3"
            #echo "Setting pip alias to /opt/homebrew/bin/pip3"
        fi
    fi
else
    echo "ADDITIONAL_CONFIG is false"
fi

# Auto completion ignore case
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Test
export PATH="/usr/local/opt/bash/bin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Integrate fzf with shell
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)

    # Make fuzzyfind with history
    HISTFILE=~/.zsh_history
    HISTSIZE=10000
    SAVEHIST=10000
    setopt appendhistory

    echo '\033[0;32muse \033[0;33m`COMMAND [DIRECTORY/][FUZZY_PATTERN]**<TAB>`\033[0;32m for Fuzzy completion\033[0m'

    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi