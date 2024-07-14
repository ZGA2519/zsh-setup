export HOMEBREW_NO_ENV_HINTS=true
ADDITIONAL_CONFIG=true # uncomment the following line if you want to use additional configuration

# Start things up
if [[ $(command -v starship) ]]; then
    eval "$(starship init zsh)"
fi
if [[ $(command -v zoxide) ]]; then
    eval "$(zoxide init zsh)"
fi
if [[ $(command -v neofetch) ]]; then
    neofetch
fi



# Shortcut
if [[ $(command -v code) ]]; then
    alias c="code"
fi

if [[ $(command -v nvim) ]]; then
    alias vim="nvim"
fi
if [[ $(command -v exa) ]]; then
    alias l="exa"
    alias ll="exa -a"
    alias lll="exa -al"
fi
if [[ $(command -v bat) ]]; then
    alias cat="bat"
    alias catp="bat -p"
fi
alias cls="clear"
alias qq="exit"


## git 
if [[ $(command -v git) ]]; then
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
    # Export
    if [[ $(command -v mysql) ]]; then
        export PATH=/usr/local/mysql/bin:$PATH
    fi
    if [[ $(command -v brew) ]]; then
        export PATH=/opt/homebrew/bin:$PATH
    fi
    if [[ $(command -v java) ]]; then
        export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
    fi
    if [[ -d "/opt/homebrew/opt/ruby/bin" ]]; then
        export PATH=/opt/homebrew/opt/ruby/bin:$PATH
        export PATH=$(gem environment gemdir)/bin:$PATH
    fi

    if [ -f "/Users/organ/.ghcup/env" ]; then
        source "/Users/organ/.ghcup/env" # ghcup-env
    fi
    if [ -s "/Users/organ/.bun/_bun" ]; then
        source "/Users/organ/.bun/_bun" # bun completions
    fi

    if [[ $(command -v bun) ]]; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    fi

    # Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
    export PATH="$PATH:$HOME/.rvm/bin"
    if [[ $(command -v ruby) ]]; then
        export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    fi
    if [[ $(command -v curl) ]]; then
        export PATH="/opt/homebrew/opt/curl/bin:$PATH"
    fi

    # Python and pip config 
    if [[ $(command -v python3) ]]; then
        alias python="/opt/homebrew/bin/python3"
        if [ -x "./bin/python3" ]; then
            alias python3='./bin/python3'
        fi
    fi
    if [[ $(command -v pip3) ]]; then
        if [ -x "./bin/pip3" ]; then
            alias pip3='./bin/pip3'
        fi
    fi
fi

# Auto completion ignore case
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'


# Test
export PATH="/usr/local/opt/bash/bin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Integrate fzf with shell
if [[ $(command -v fzf) ]]; then
    source <(fzf --zsh)

    # Make fuzyfind with history
    HISTFILE=~/.zsh_history
    HISTSIZE=10000
    SAVEHIST=10000
    setopt appendhistory

    echo '\033[0;32muse \033[0;33mCOMMAND [DIRECTORY/][FUZZY_PATTERN]**<TAB>\033[0;32m for Fuzzy completion\033[0m'
fi
