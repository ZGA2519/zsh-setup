#!/usr/bin/env bash
#
# mac-setup — reinstall programs + configs on a Mac with one script.
#
# Captured from a macOS (Apple Silicon) machine. Contains NO personal data:
# your Git name/email are asked for interactively, and all home paths use $HOME.
# Safe to run on a brand-new Mac OR to re-apply on this one (idempotent).
#
# Usage:
#   bash setup.sh              # interactive: asks before the big steps
#   bash setup.sh --yes        # non-interactive: do everything
#   bash setup.sh --no-casks   # skip GUI apps (casks)
#   bash setup.sh --no-vscode  # skip VS Code extensions
#   bash setup.sh --no-mas     # skip Mac App Store apps
#   bash setup.sh --no-dotfiles
#   bash setup.sh --no-brew    # skip Homebrew formulae+casks entirely
#
# Existing dotfiles are backed up to ~/.mac-setup-backup-<timestamp>/ before
# being overwritten — nothing is deleted.
#
# NOTE: secrets were intentionally NOT captured. After running, sign in to:
#   gh auth login            (GitHub CLI)
#   git-xet / infisical / docker / etc.

set -uo pipefail   # not -e: keep going and report per-step failures

# ----------------------------------------------------------------------------
# flags + helpers
# ----------------------------------------------------------------------------
ASSUME_YES=0; DO_BREW=1; DO_CASKS=1; DO_VSCODE=1; DO_MAS=1; DO_DOTFILES=1
for arg in "$@"; do
  case "$arg" in
    --yes|-y)      ASSUME_YES=1 ;;
    --no-brew)     DO_BREW=0 ;;
    --no-casks)    DO_CASKS=0 ;;
    --no-vscode)   DO_VSCODE=0 ;;
    --no-mas)      DO_MAS=0 ;;
    --no-dotfiles) DO_DOTFILES=0 ;;
    -h|--help)     awk 'NR>1{ if(/^#/){sub(/^# ?/,"");print} else exit }' "$0"; exit 0 ;;
    *) echo "unknown flag: $arg (try --help)"; exit 2 ;;
  esac
done

c_bold=$'\033[1m'; c_grn=$'\033[0;32m'; c_yel=$'\033[0;33m'; c_red=$'\033[0;31m'; c_rst=$'\033[0m'
info() { printf "%s==>%s %s\n" "$c_grn" "$c_rst" "$*"; }
warn() { printf "%s[!]%s %s\n" "$c_yel" "$c_rst" "$*"; }
err()  { printf "%s[x]%s %s\n" "$c_red" "$c_rst" "$*" >&2; }
step() { printf "\n%s%s%s\n" "$c_bold" "== $* ==" "$c_rst"; }
confirm() {  # confirm "question"  -> 0 if yes
  [ "$ASSUME_YES" = 1 ] && return 0
  printf "%s? %s [y/N] " "$c_yel" "$*$c_rst"; read -r ans
  [[ "$ans" =~ ^[Yy]$ ]]
}
ask() {  # ask "question" [default]  -> echoes the answer (prompt goes to stderr)
  local q="$1" def="${2:-}" ans
  [ "$ASSUME_YES" = 1 ] && { echo "$def"; return; }
  printf "%s? %s%s%s " "$c_yel" "$q" "${def:+ [$def]}" "$c_rst" >&2
  read -r ans
  echo "${ans:-$def}"
}

BACKUP_DIR="$HOME/.mac-setup-backup-$(date +%Y%m%d-%H%M%S)"
backup() {  # backup <path> : move an existing file/dir into the backup dir
  local p="$1"
  if [ -e "$p" ] || [ -L "$p" ]; then
    mkdir -p "$BACKUP_DIR"
    local rel="${p#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    cp -R "$p" "$BACKUP_DIR/$rel" 2>/dev/null && info "backed up $p"
  fi
}

# ----------------------------------------------------------------------------
# 0. preflight
# ----------------------------------------------------------------------------
step "Preflight"
if [ "$(uname -s)" != "Darwin" ]; then err "This script is for macOS only."; exit 1; fi
info "macOS $(sw_vers -productVersion 2>/dev/null) on $(uname -m)"
if ! confirm "Proceed with setup"; then echo "Aborted."; exit 0; fi

# ----------------------------------------------------------------------------
# 1. Xcode Command Line Tools (git, compilers — needed by Homebrew)
# ----------------------------------------------------------------------------
step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  info "already installed"
else
  warn "installing — accept the GUI dialog that appears, then re-run this script if it pauses"
  xcode-select --install || true
fi

# ----------------------------------------------------------------------------
# 2. Homebrew
# ----------------------------------------------------------------------------
step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  info "installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Make brew available in this shell (Apple Silicon path)
if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"
fi
command -v brew >/dev/null 2>&1 && info "brew $(brew --version | head -1)" || { err "Homebrew not on PATH; aborting brew steps"; DO_BREW=0; }

# ----------------------------------------------------------------------------
# 3. Brewfile (taps + formulae + casks)
# ----------------------------------------------------------------------------
if [ "$DO_BREW" = 1 ]; then
  step "Homebrew packages"
  BREWFILE="$(mktemp -t Brewfile)"
  cat > "$BREWFILE" <<'BREWFILE_EOF'
# ---- taps ----
tap "clojure/tools"
tap "electrikmilk/cherri"
tap "infisical/get-cli"

# ---- CLI tools & libraries (formulae) ----
brew "act"
brew "clojure/tools/clojure"
brew "cocoapods"
brew "dotnet"
brew "electrikmilk/cherri/cherri"
brew "eza"
brew "fzf"
brew "gh"
brew "git-lfs"        # required by ~/.gitconfig lfs filter
brew "git-xet"
brew "helm"
brew "infisical/get-cli/infisical"
brew "libimobiledevice"
brew "mas"            # added: script Mac App Store installs (see checklist below)
brew "mole"
brew "mono"
brew "neovim"
brew "node"
brew "ollama"
brew "openjdk"
brew "pnpm"
brew "postgresql@18"
brew "python-tk@3.14"
brew "tesseract-lang"
brew "uv"
brew "watchman"
brew "zenity"
brew "zoxide"
BREWFILE_EOF

  if [ "$DO_CASKS" = 1 ]; then
    cat >> "$BREWFILE" <<'CASKFILE_EOF'

# ---- GUI apps (casks) you already had ----
cask "docker-desktop"
cask "gstreamer-runtime"
cask "mos"
cask "obs"
cask "ollama-app"
cask "postman"
cask "visual-studio-code"

# ---- apps found in /Applications, available as free casks ----
cask "ghostty"
cask "google-chrome"
cask "keka"
cask "utm"
cask "claude"
cask "crystalfetch"
CASKFILE_EOF
  else
    warn "--no-casks: skipping GUI apps"
  fi

  info "running 'brew bundle' (this can take a while)..."
  brew bundle --file="$BREWFILE" --no-lock || warn "some brew packages failed — see output above"
  rm -f "$BREWFILE"
fi

# ----------------------------------------------------------------------------
# 4. VS Code extensions
# ----------------------------------------------------------------------------
if [ "$DO_VSCODE" = 1 ]; then
  step "VS Code extensions"
  if command -v code >/dev/null 2>&1; then
    while IFS= read -r ext; do
      [ -z "$ext" ] && continue
      code --install-extension "$ext" --force >/dev/null 2>&1 \
        && info "ext $ext" || warn "ext failed: $ext"
    done <<'VSCODE_EOF'
actuallyzach.jelly-language-support
anthropic.claude-code
asvetliakov.vscode-neovim
atlassian.atlascode
burkeholland.simple-react-snippets
c3.vscode-c3
castwide.solargraph
catppuccin.catppuccin-vsc
chouzz.vscode-better-align
chrmarti.regex
coder.coder-remote
cweijan.dbclient-jdbc
cweijan.vscode-postgresql-client2
dbaeumer.vscode-eslint
docker.docker
dooez.alt-catppuccin-vsc
dotjoshjohnson.xml
dsznajder.es7-react-js-snippets
eamodio.gitlens
electrikmilk.cherri-vscode-extension
esbenp.prettier-vscode
formulahendry.auto-rename-tag
formulahendry.code-runner
foxundermoon.shell-format
github.codespaces
github.vscode-github-actions
golang.go
google.gemini-cli-vscode-ide-companion
gruntfuggly.todo-tree
haskell.haskell
hediet.debug-visualizer
hediet.vscode-drawio
humao.rest-client
janjoerke.align-by-regex
janjoerke.jenkins-pipeline-linter-connector
jnbt.vscode-rufo
justusadam.language-haskell
kenan-salar.calmppuccin-vscode
kevinrose.vsc-python-indent
llvm-vs-code-extensions.lldb-dap
maarti.jenkins-doc
mechatroner.rainbow-csv
mesonbuild.mesonbuild
mgesbert.python-path
moyu.snapcode
mrmomo.meson-build
ms-azuretools.vscode-containers
ms-python.debugpy
ms-python.python
ms-python.vscode-pylance
ms-python.vscode-python-envs
ms-toolsai.jupyter
ms-toolsai.jupyter-keymap
ms-toolsai.jupyter-renderers
ms-toolsai.vscode-jupyter-cell-tags
ms-toolsai.vscode-jupyter-slideshow
ms-vscode-remote.remote-containers
ms-vscode-remote.remote-ssh
ms-vscode-remote.remote-ssh-edit
ms-vscode.cmake-tools
ms-vscode.cpp-devtools
ms-vscode.cpptools
ms-vscode.cpptools-extension-pack
ms-vscode.cpptools-themes
ms-vscode.extension-test-runner
ms-vscode.live-server
ms-vscode.makefile-tools
ms-vscode.remote-explorer
ms-vscode.vscode-chat-customizations-evaluations
ms-vscode.vscode-speech
njpwerner.autodocstring
openai.chatgpt
photopea.photopea
pkief.material-icon-theme
pnp.polacode
pomdtr.excalidraw-editor
prisma.prisma
rebornix.scheme
redhat.java
redhat.vscode-xml
redhat.vscode-yaml
rickaym.manim-sideview
ritwickdey.liveserver
rust-lang.rust-analyzer
sanjulaganepola.github-local-actions
shopify.ruby-extensions-pack
shopify.ruby-lsp
sorbet.sorbet-vscode-extension
stivo.tailwind-fold
sumneko.lua
svelte.svelte-vscode
swiftlang.swift-vscode
tabnine.tabnine-vscode
tamasfe.even-better-toml
tomoki1207.pdf
twxs.cmake
vmware.vscode-boot-dev-pack
vmware.vscode-spring-boot
vscjava.vscode-gradle
vscjava.vscode-java-debug
vscjava.vscode-java-dependency
vscjava.vscode-java-pack
vscjava.vscode-java-test
vscjava.vscode-maven
vscjava.vscode-spring-boot-dashboard
vscjava.vscode-spring-initializr
vscodevim.vim
ziglang.vscode-zig
VSCODE_EOF
  else
    warn "'code' CLI not found — open VS Code and run 'Shell Command: Install code command in PATH', then re-run with --no-brew --no-dotfiles"
  fi
fi

# ----------------------------------------------------------------------------
# 5. Mac App Store apps (via mas)
# ----------------------------------------------------------------------------
if [ "$DO_MAS" = 1 ]; then
  step "Mac App Store apps"
  if command -v mas >/dev/null 2>&1; then
    # "<app-store-id>:<name>" — IDs verified against apps.apple.com
    mas_apps=(
      "937984704:Amphetamine"   # keep-awake utility (William Gustafson)
      "1429033973:RunCat"       # menu-bar CPU/resource monitor (Takuto Nakamura)
    )
    for entry in "${mas_apps[@]}"; do
      mid="${entry%%:*}"; mname="${entry#*:}"
      if mas list 2>/dev/null | grep -qE "^${mid}[[:space:]]"; then
        info "$mname already installed"
      else
        info "installing $mname ($mid)..."
        mas install "$mid" >/dev/null 2>&1 \
          && info "installed $mname" \
          || warn "could not install $mname — open App Store.app and sign in, then re-run"
      fi
    done
  else
    warn "'mas' not found — it installs in the Homebrew step; run without --no-brew first"
  fi
fi

# ----------------------------------------------------------------------------
# 6. Dotfiles & configs
# ----------------------------------------------------------------------------
if [ "$DO_DOTFILES" = 1 ]; then
  step "Dotfiles & configs"
  mkdir -p "$HOME/.config/git" "$HOME/.config/nvim/lua/config" "$HOME/.config/nvim/lua/plugins"

  # ---- ~/.zshrc ----
  backup "$HOME/.zshrc"
  cat > "$HOME/.zshrc" <<'ZSHRC_EOF'
stty -echo

export HOMEBREW_NO_ENV_HINTS=true

# Uncomment the following line if you want to use additional configuration
ADDITIONAL_CONFIG=true

# Start things up
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi
# if command -v neofetch &> /dev/null; then
#     neofetch
# fi

# Greeting
# echo '\033[0;32m\nHello' $USER! ', welcome back!!!' #\033[0m'

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
alias rr="source $HOME/.zshrc"

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
    # echo "ADDITIONAL_CONFIG is true"

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

    if [ -f "$HOME/.ghcup/env" ]; then
        source "$HOME/.ghcup/env" # ghcup-env
    fi
    if [ -s "$HOME/.bun/_bun" ]; then
        source "$HOME/.bun/_bun" # bun completions
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
    if command -v python3 &> /dev/null; then
        if [ -x "./bin/python3" ]; then
            alias python='./bin/python3'
            #echo "Setting python alias to ./bin/python3"
        else
            alias python="/opt/homebrew/bin/python3"
            #echo "Setting python alias to /opt/homebrew/bin/python3"
        fi
        alias py='python'
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
    # echo "ADDITIONAL_CONFIG is false"
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

    # echo '\033[0;32muse \033[0;33m`COMMAND [DIRECTORY/][FUZZY_PATTERN]**<TAB>`\033[0;32m for Fuzzy completion\033[0m'

    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

stty echo
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
ZSHRC_EOF
  info "wrote ~/.zshrc"

  # ---- ~/.zprofile ----
  backup "$HOME/.zprofile"
  cat > "$HOME/.zprofile" <<'ZPROFILE_EOF'

eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Added by swiftly
. "$HOME/.swiftly/env.sh"
ZPROFILE_EOF
  info "wrote ~/.zprofile"

  # ---- ~/.gitconfig (identity asked interactively — never hard-coded) ----
  backup "$HOME/.gitconfig"
  GIT_NAME="$(ask 'Git user.name (blank to skip)')"
  GIT_EMAIL="$(ask 'Git user.email (blank to skip)')"
  {
    if [ -n "$GIT_NAME$GIT_EMAIL" ]; then
      echo "[user]"
      [ -n "$GIT_NAME" ]  && printf '\tname = %s\n' "$GIT_NAME"
      [ -n "$GIT_EMAIL" ] && printf '\temail = %s\n' "$GIT_EMAIL"
    fi
    cat <<'GITCONFIG_EOF'
[lfs "customtransfer.xet"]
	path = git-xet
	args = transfer
	concurrent = true
[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
GITCONFIG_EOF
  } > "$HOME/.gitconfig"
  if [ -n "$GIT_NAME$GIT_EMAIL" ]; then
    info "wrote ~/.gitconfig (identity set)"
  else
    warn "wrote ~/.gitconfig without identity — set later: git config --global user.name '…'"
  fi

  # ---- ~/.config/git/ignore ----
  backup "$HOME/.config/git/ignore"
  cat > "$HOME/.config/git/ignore" <<'GITIGNORE_EOF'
**/.claude/settings.local.json
GITIGNORE_EOF
  info "wrote ~/.config/git/ignore"

  # ---- nvim (lazy.nvim) ----
  backup "$HOME/.config/nvim"
  : > "$HOME/.config/nvim/init.lua"   # init.lua is intentionally empty on source machine
  cat > "$HOME/.config/nvim/lua/config/lazy.lua" <<'LAZY_EOF'
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

vim.cmd.colorscheme "catppuccin-mocha"
LAZY_EOF
  cat > "$HOME/.config/nvim/lua/plugins/spec1.lua" <<'SPEC1_EOF'
return {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
        "junegunn/vim-easy-align",
        name = "vim-easy-align",
        config = function()
            vim.api.nvim_set_keymap("x", "ga", "<Plug>(EasyAlign)", {})
            vim.api.nvim_set_keymap("n", "ga", "<Plug>(EasyAlign)", {})
        end,
    },
}
SPEC1_EOF
  cat > "$HOME/.config/nvim/lazy-lock.json" <<'LOCK_EOF'
{
  "catppuccin": { "branch": "main", "commit": "0a5de4da015a175f416d6ef1eda84661623e0500" },
  "lazy.nvim": { "branch": "main", "commit": "306a05526ada86a7b30af95c5cc81ffba93fef97" },
  "vim-easy-align": { "branch": "master", "commit": "9815a55dbcd817784458df7a18acacc6f82b1241" }
}
LOCK_EOF
  info "wrote ~/.config/nvim (lazy.nvim)"

  [ -d "$BACKUP_DIR" ] && warn "previous dotfiles backed up to: $BACKUP_DIR"
fi

# ----------------------------------------------------------------------------
# 7. Remaining manual installs (no reliable cask / not yet automated)
# ----------------------------------------------------------------------------
step "Remaining manual installs"
cat <<'CHECKLIST_EOF'
Amphetamine and RunCat are installed automatically above (via mas). These
remaining App Store apps aren't automated — add them to the mas_apps list in
section 5 if you want them, or install manually:

  Mac App Store (find IDs with `mas search <name>`):
    - PreviewCode / PreviewJson / PreviewMarkdown / PreviewYaml  (QuickLook)

  Apple / developer:
    - Xcode            (App Store, or developer.apple.com)

Then sign in / authenticate:
  - gh auth login                 (GitHub CLI — token was NOT copied)
  - docker login, infisical login, git-xet config, etc.
  - Restart your terminal (or `source ~/.zshrc`) to load shell config.
CHECKLIST_EOF

step "Done"
info "Setup finished. Review any [!] warnings above."
