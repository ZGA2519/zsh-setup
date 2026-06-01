stty -echo

export HOMEBREW_NO_ENV_HINTS=true

# Uncomment the following line if you want to use additional configuration

# Start things up
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# Shortcut
if command -v code &> /dev/null; then
    alias c="code"
fi

if command -v nvim &> /dev/null; then
    alias vim="nvim"
fi

if command -v eza &> /dev/null; then
    alias l="eza"
    alias ll="eza -a"
    alias lll="eza -al"
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


# Auto completion ignore case
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

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

stty echo
