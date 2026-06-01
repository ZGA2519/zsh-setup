stty -echo

# ─── Environment ──────────────────────────────────────────────
export HOMEBREW_NO_ENV_HINTS=true
export PATH="$HOME/.local/bin:$PATH"

# ─── Setup ────────────────────────────────────────────────────
# Install all tools used by this config
brew-install-all() {
    brew install starship zoxide neovim eza bat git fzf
    brew install --cask visual-studio-code
}

# ─── Tool initialization ──────────────────────────────────────
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# ─── Aliases ──────────────────────────────────────────────────
alias cls="clear"
alias qq="exit"

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

# git
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

# ─── Completion ───────────────────────────────────────────────
# Auto completion ignore case
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ─── fzf ──────────────────────────────────────────────────────
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)

    # Make fuzzyfind with history
    HISTFILE=~/.zsh_history
    HISTSIZE=10000
    SAVEHIST=10000
    setopt appendhistory

    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

stty echo
