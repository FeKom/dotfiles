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

install_packages_debian() {
  log "Updating apt..."
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends \
    git zsh tmux curl wget unzip build-essential \
    direnv jq

  # Neovim — use AppImage if apt version is too old (< 0.9)
  if ! command -v nvim &>/dev/null || [[ "$(nvim --version | head -1 | grep -oP '\d+\.\d+')" < "0.9" ]]; then
    log "Installing Neovim from AppImage..."
    local nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
    curl -Lo /tmp/nvim.appimage "$nvim_url"
    chmod +x /tmp/nvim.appimage
    /tmp/nvim.appimage --appimage-extract-and-run --version &>/dev/null \
      && sudo mv /tmp/nvim.appimage /usr/local/bin/nvim \
      || { /tmp/nvim.appimage --appimage-extract -q; sudo mv squashfs-root /opt/nvim; sudo ln -sf /opt/nvim/usr/bin/nvim /usr/local/bin/nvim; }
  fi

  # eza
  if ! command -v eza &>/dev/null; then
    log "Installing eza..."
    sudo apt-get install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -qq && sudo apt-get install -y eza
  fi

  # zoxide
  command -v zoxide &>/dev/null || curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

  # oh-my-posh
  command -v oh-my-posh &>/dev/null || {
    log "Installing oh-my-posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
  }

  # zsh-syntax-highlighting
  [[ -d ~/.zsh/zsh-syntax-highlighting ]] || \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

  # zsh-autosuggestions (oh-my-zsh custom plugin)
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] || \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

  # bun
  command -v bun &>/dev/null || curl -fsSL https://bun.sh/install | bash

  # nvm
  [[ -d ~/.nvm ]] || {
    log "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  }

  # SDKMAN (for Java)
  [[ -d ~/.sdkman ]] || {
    log "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash || true
  }

  # gh (GitHub CLI)
  command -v gh &>/dev/null || {
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
    sudo apt-get update -qq && sudo apt-get install -y gh
  }
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
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
  link "$DOTFILES_DIR/.config/ghostty/config"          "$HOME/.config/ghostty/config"
  link "$DOTFILES_DIR/.config/ohmyposh/emodipt-extend.omp.json" \
                                                        "$HOME/.config/ohmyposh/emodipt-extend.omp.json"
  link "$DOTFILES_DIR/.config/nvim"                    "$HOME/.config/nvim"
  link "$DOTFILES_DIR/.config/zed/settings.json"       "$HOME/.config/zed/settings.json"
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
  else
    echo "  2. Install a Nerd Font for the prompt icons to render correctly:"
    echo "     https://www.nerdfonts.com/font-downloads  (JetBrainsMono Nerd Font)"
  fi
  echo "  3. Inside nvim, run :Lazy to install plugins"
  echo "  4. Edit ~/.gitconfig to update your name/email if needed"
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
    debian|wsl)     install_packages_debian ;;
    fedora)         install_packages_fedora ;;
    arch)           warn "Arch Linux: installing base packages only"
                    sudo pacman -Sy --noconfirm git zsh tmux neovim eza zoxide direnv jq ;;
    *)              warn "Unknown OS — skipping package install, only creating symlinks." ;;
  esac

  install_ohmyzsh
  create_symlinks
  set_default_shell
  post_install_notes
}

main "$@"
