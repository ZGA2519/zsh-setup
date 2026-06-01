# mac-setup

One script to reinstall my programs and configs on a fresh macOS (Apple Silicon) machine.

## Usage

```bash
git clone <this-repo> mac-setup && cd mac-setup
bash setup.sh
```

It will:

1. Install **Xcode Command Line Tools** and **Homebrew** (if missing)
2. Install Homebrew **formulae + casks** (CLI tools and GUI apps)
3. Install **VS Code extensions**
4. Install **Mac App Store apps** via `mas` (Amphetamine, RunCat)
5. Write **dotfiles**: `.zshrc`, `.zprofile`, `.gitconfig`, git ignore, and a small nvim (lazy.nvim) config

Existing dotfiles are backed up to `~/.mac-setup-backup-<timestamp>/` first — nothing is deleted.

### Flags

| Flag | Effect |
|------|--------|
| `--yes`, `-y` | Non-interactive; accept all prompts (Git identity left blank) |
| `--no-brew` | Skip Homebrew formulae + casks |
| `--no-casks` | Install formulae but skip GUI apps |
| `--no-vscode` | Skip VS Code extensions |
| `--no-mas` | Skip Mac App Store apps |
| `--no-dotfiles` | Skip writing dotfiles |
| `--help`, `-h` | Show usage |

## Privacy

This repo contains **no personal data and no secrets**:

- Git **name/email are asked for interactively** at run time, never hard-coded.
- Home paths use `$HOME`, so it works for any username.
- Credentials were deliberately **not** captured (no `~/.config/gh` auth token, no SSH keys).

After running, finish auth manually:

```bash
gh auth login          # GitHub CLI
docker login           # Docker Hub
infisical login        # Infisical
# then: restart the terminal (or `source ~/.zshrc`)
```

## Scope

Curated for a **work machine**: games, entertainment, torrent clients, and
paid/licensed commercial apps are intentionally excluded. Only dev tools and
work-appropriate utilities are installed.

## Mac App Store

`setup.sh` installs **Amphetamine** and **RunCat** automatically with [`mas`](https://github.com/mas-cli/mas)
(requires being signed in to the App Store — open App Store.app and sign in first).
To add more apps, find their ID with `mas search <name>` and append to the
`mas_apps` list in section 5 of the script.

A few apps still need manual install (printed as a checklist at the end): the
Preview QuickLook plugins and Xcode.
