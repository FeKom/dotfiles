#!/usr/bin/env bash
# dotfiles install script — macOS, Linux (Debian/Ubuntu/Fedora), Windows WSL
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOLD='\033[1m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

log()  { echo -e "${GREEN}[dotfiles]${NC} $*"; }
warn() { echo -e "${YELLOW}[dotfiles]${NC} $*"; }
die()  { echo -e "${RED}[dotfiles] ERROR:${NC} $*" >&2; exit 1; }

# ─── OS detection ────────────────────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      grep -qi microsoft /proc/version 2>/dev/null && echo "wsl" || \
      { . /etc/os-release 2>/dev/null; \
        case "${ID:-linux}" in
          ubuntu|debian|pop|linuxmint) echo "debian" ;;
          fedora|rhel|centos|rocky|alma) echo "fedora" ;;
          arch|manjaro|endeavouros) echo "arch" ;;
          *) echo "linux" ;;
        esac; } ;;
    *) echo "unknown" ;;
  esac
}

OS=$(detect_os)
log "Detected OS: ${BOLD}$OS${NC}"

# ─── Package install helpers ─────────────────────────────────────────────────
install_homebrew() {
  if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for Apple Silicon
    [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

install_packages_macos() {
  install_homebrew
  log "Installing packages via Homebrew..."
  brew install \
    git neovim tmux zsh \
    eza zoxide direnv jq \
    oh-my-posh \
    zsh-syntax-highlighting zsh-autosuggestions \
    nvm bun colima docker docker-compose \
    mole gh || true

  if ! brew list --cask ghostty &>/dev/null 2>&1; then
    brew install --cask ghostty || warn "Ghostty cask not found, skip"
  fi
  if ! brew list --cask visual-studio-code &>/dev/null 2>&1; then
    brew install --cask visual-studio-code || warn "VS Code cask not found, skip"
  fi
}

# Ubuntu/Debian: apt + git clone only. No curl | sh.
install_packages_debian() {
  log "Updating apt..."
  sudo apt-get update -qq
  sudo apt-get install -y \
    git zsh tmux build-essential ca-certificates curl \
    zsh-syntax-highlighting zsh-autosuggestions \
    zoxide fzf direnv jq gh fonts-jetbrains-mono

  # eza is only in apt from Ubuntu 24.04 on; .zshrc falls back to plain ls.
  sudo apt-get install -y eza || warn "eza not available in apt, skipping"
}

# LazyVim needs Neovim >= 0.11; Ubuntu's own package is older and the
# stable PPA has no build for recent releases, so use the unstable PPA.
install_neovim_debian() {
  log "Installing Neovim from ppa:neovim-ppa/unstable..."
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  sudo apt-get update -qq
  # python3-venv: Mason installs Python tools (debugpy, black) in venvs.
  sudo apt-get install -y neovim ripgrep fd-find unzip xclip python3-venv
}

# nvm has no apt package; this is nvm's documented manual (git) install.
# curl is only used by nvm itself to download Node binaries.
install_node_stack() {
  export NVM_DIR="$HOME/.nvm"
  if [[ ! -d "$NVM_DIR" ]]; then
    log "Cloning nvm..."
    git clone --quiet https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    local tag
    tag="$(git -C "$NVM_DIR" describe --abbrev=0 --tags --match 'v[0-9]*' \
      "$(git -C "$NVM_DIR" rev-list --tags --max-count=1)")"
    git -C "$NVM_DIR" checkout --quiet "$tag"
  else
    log "nvm already installed, skipping clone."
  fi

  # nvm.sh is not compatible with `set -u`.
  set +u
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
  log "Installing Node LTS (comes with npm)..."
  nvm install --lts
  nvm alias default 'lts/*'
  log "Installing yarn and tree-sitter CLI..."
  # apt's tree-sitter-cli (0.20) is too old for nvim-treesitter. Its install
  # script fetches the binary, and npm >= 11 blocks scripts unless allowed.
  npm install -g --allow-scripts=tree-sitter-cli,yarn yarn tree-sitter-cli
  set -u
}

install_packages_fedora() {
  log "Installing packages via dnf..."
  sudo dnf install -y \
    git zsh tmux curl wget unzip \
    direnv jq neovim

  command -v eza    &>/dev/null || sudo dnf install -y eza || cargo install eza
  command -v zoxide &>/dev/null || curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  command -v oh-my-posh &>/dev/null || curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  [[ -d ~/.zsh/zsh-syntax-highlighting ]] || \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
  [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] || \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

  command -v bun &>/dev/null || curl -fsSL https://bun.sh/install | bash
  [[ -d ~/.nvm ]] || curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  [[ -d ~/.sdkman ]] || curl -s "https://get.sdkman.io" | bash || true
}

# ─── Oh My Zsh ───────────────────────────────────────────────────────────────
install_ohmyzsh() {
  if [[ ! -d ~/.oh-my-zsh ]]; then
    log "Installing Oh My Zsh..."
    git clone --quiet --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
  else
    log "Oh My Zsh already installed, skipping."
  fi
}

# ─── Symlinks ────────────────────────────────────────────────────────────────
link() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    warn "Backing up existing $dst → ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  log "  linked $dst"
}

create_symlinks() {
  log "Creating symlinks..."
  link "$DOTFILES_DIR/.zshrc"                          "$HOME/.zshrc"
  link "$DOTFILES_DIR/.gitconfig"                      "$HOME/.gitconfig"
  link "$DOTFILES_DIR/.tmux.conf"                      "$HOME/.tmux.conf"
  link "$DOTFILES_DIR/.config/zsh/prompt.zsh"          "$HOME/.config/zsh/prompt.zsh"
  link "$DOTFILES_DIR/.config/ohmyposh/emodipt-extend.omp.json" \
                                                        "$HOME/.config/ohmyposh/emodipt-extend.omp.json"

  link "$DOTFILES_DIR/.config/nvim"                    "$HOME/.config/nvim"

  # GUI apps are not installed on Ubuntu.
  [[ "$OS" == "debian" || "$OS" == "wsl" ]] && return 0

  link "$DOTFILES_DIR/.config/ghostty/config"          "$HOME/.config/ghostty/config"
  link "$DOTFILES_DIR/.config/zed/settings.json"       "$HOME/.config/zed/settings.json"
}

# ─── Git identity ────────────────────────────────────────────────────────────
# .gitconfig includes ~/.gitconfig.local, so each machine has its own account.
setup_git_identity() {
  local local_cfg="$HOME/.gitconfig.local"
  [[ -f "$local_cfg" ]] && { log "Git identity already set in $local_cfg"; return 0; }

  # -r only checks permissions; opening proves a controlling terminal exists.
  if ! { : < /dev/tty; } 2>/dev/null; then
    warn "No terminal to ask for git identity. Create $local_cfg later."
    return 0
  fi

  local name email
  read -rp "Git user.name for this machine: " name < /dev/tty
  read -rp "Git user.email for this machine: " email < /dev/tty
  git config --file "$local_cfg" user.name "$name"
  git config --file "$local_cfg" user.email "$email"
  log "  wrote $local_cfg"
}

# ─── GitHub auth ─────────────────────────────────────────────────────────────
# Lets plain `git` reuse the gh login for HTTPS pull/push.
setup_gh_git() {
  command -v gh &>/dev/null || return 0
  if gh auth status &>/dev/null; then
    gh auth setup-git
    log "git now uses gh credentials for HTTPS"
  else
    warn "gh not logged in. Run: gh auth login && gh auth setup-git"
  fi
}

# ─── Set Zsh as default shell ─────────────────────────────────────────────────
set_default_shell() {
  local zsh_bin
  zsh_bin="$(command -v zsh)"
  if [[ "$SHELL" != "$zsh_bin" ]]; then
    log "Setting zsh as default shell..."
    grep -q "$zsh_bin" /etc/shells || echo "$zsh_bin" | sudo tee -a /etc/shells
    chsh -s "$zsh_bin" || warn "Run 'chsh -s $zsh_bin' manually if it failed."
  fi
}

# ─── Post-install notes ───────────────────────────────────────────────────────
post_install_notes() {
  echo ""
  echo -e "${BOLD}╭──────────────────────────────────────────────────╮${NC}"
  echo -e "${BOLD}│           dotfiles install complete!              │${NC}"
  echo -e "${BOLD}╰──────────────────────────────────────────────────╯${NC}"
  echo ""
  echo "  Next steps:"
  echo "  1. Open a new terminal (or run: exec zsh)"
  if [[ "$OS" == "macos" ]]; then
    echo "  2. Install a Nerd Font: brew install --cask font-jetbrains-mono-nerd-font"
    echo "  3. Set the font in Ghostty (already configured to JetBrains Mono)"
    echo "  4. Inside nvim, run :Lazy to install plugins"
  else
    echo "  2. Set your terminal font to JetBrains Mono (installed via apt)"
    echo "  3. Log out and back in so zsh becomes the default shell"
    echo "  4. Inside nvim, run :Lazy to install plugins"
  fi
  echo "  -  Git identity: ~/.gitconfig.local (gh auth login for GitHub)"
  echo ""
}

# ─── Windows (native, non-WSL) ───────────────────────────────────────────────
check_windows() {
  if [[ "${OS:-}" == "unknown" ]] || ( [[ -n "${WINDIR:-}" ]] && [[ -z "${WSL_DISTRO_NAME:-}" ]] ); then
    die "Native Windows detected. Please use WSL2 and re-run this script inside the WSL terminal."
  fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  check_windows

  log "Starting dotfiles installation..."
  log "Dotfiles directory: $DOTFILES_DIR"

  case "$OS" in
    macos)          install_packages_macos ;;
    debian|wsl)     install_packages_debian; install_neovim_debian; install_node_stack ;;
    fedora)         install_packages_fedora ;;
    arch)           warn "Arch Linux: installing base packages only"
                    sudo pacman -Sy --noconfirm git zsh tmux neovim eza zoxide direnv jq ;;
    *)              warn "Unknown OS — skipping package install, only creating symlinks." ;;
  esac

  install_ohmyzsh
  create_symlinks
  setup_git_identity
  setup_gh_git
  set_default_shell
  post_install_notes
}

main "$@"
