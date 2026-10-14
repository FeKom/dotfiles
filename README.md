# dotfiles

My personal development environment — zsh, Neovim (LazyVim), Ghostty, tmux, Zed.

## What's included

| Config | Path |
|---|---|
| zsh (Oh My Zsh + Oh My Posh) | `~/.zshrc` |
| tmux | `~/.tmux.conf` |
| Ghostty terminal | `~/.config/ghostty/config` |
| Oh My Posh theme | `~/.config/ohmyposh/emodipt-extend.omp.json` |
| Neovim (LazyVim) | `~/.config/nvim/` |
| Zed editor | `~/.config/zed/settings.json` |

## Quick install

```bash
git clone https://github.com/fekom/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Ubuntu

Terminal-only setup using `apt` and `git clone` (no `curl | sh`):

- zsh, Oh My Zsh, autosuggestions, syntax highlighting
- native prompt (`.config/zsh/prompt.zsh`), mirroring the Oh My Posh theme
- eza, zoxide, fzf, direnv, tmux, JetBrains Mono font
- nvm (git clone), Node LTS with npm, yarn
- Neovim via `snap install nvim --classic` (LazyVim needs >= 0.11), ripgrep, fd

Ghostty and Zed configs are not linked on Ubuntu.

Day-to-day flow after install:

```bash
gh auth login               # once; install.sh runs `gh auth setup-git` if already logged in
gh repo clone org/project
cd project                  # .nvmrc present → nvm switches (and installs) Node
npm install && npm run dev
```

### Windows

Use **WSL2** (Ubuntu 22.04+) and run the script inside the WSL terminal. Native Windows (PowerShell) is not supported.

## What the installer does

1. **Detects OS** — macOS, Debian/Ubuntu, Fedora, WSL
2. **Installs packages**
   - macOS: via Homebrew (`brew bundle` or inline)
   - Linux/WSL: apt/dnf + direct installers for tools not in repos
3. **Installs Oh My Zsh** (if not present)
4. **Creates symlinks** — all configs point back to this repo
5. **Sets zsh as default shell**

## macOS — Homebrew bundle

If you prefer to install all packages at once:

```bash
brew bundle --file=~/dotfiles/Brewfile
```

## Neovim

Based on [LazyVim](https://lazyvim.org). After first launch, `:Lazy` will install all plugins automatically.

Languages enabled: TypeScript/JS, Python, Go, Rust, Java, Elixir, Zig, JSON, YAML, TOML, Docker, Markdown, SQL, Tailwind.

### Font

The prompt and Neovim icons require a **Nerd Font**.

```bash
# macOS
brew install --cask font-jetbrains-mono-nerd-font

# Linux
# Download from https://www.nerdfonts.com/ → JetBrainsMono
# Then set your terminal to use "JetBrainsMono Nerd Font"
```

## After install

```bash
exec zsh          # reload shell
nvim              # opens nvim, Lazy installs plugins on first run
```

## Syncing changes

After editing any config:

```bash
cd ~/dotfiles
git add -p
git commit -m "update: <what changed>"
git push
```

Since configs are symlinked, changes take effect immediately.
