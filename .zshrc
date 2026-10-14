# ╭──────────────────────────────────────────╮
# │              Oh My Zsh Setup              │
# ╰──────────────────────────────────────────╯
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
CASE_SENSITIVE="false"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# ╭──────────────────────────────────────────╮
# │              OS Detection                 │
# ╰──────────────────────────────────────────╯
_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  grep -q Microsoft /proc/version 2>/dev/null && echo "wsl" || echo "linux" ;;
    *)      echo "unknown" ;;
  esac
}
OS="$(_os)"

# ╭──────────────────────────────────────────╮
# │   Autosuggestions + Syntax Highlighting   │
# ╰──────────────────────────────────────────╯
# Paths cover Homebrew, apt and a manual clone. Highlighting must load last.
_source_first() {
  local f
  for f in "$@"; do
    [[ -f "$f" ]] && { source "$f"; return 0; }
  done
  return 1
}
_source_first \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
_source_first \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ╭──────────────────────────────────────────╮
# │         Zoxide (smarter cd)               │
# ╰──────────────────────────────────────────╯
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ╭──────────────────────────────────────────╮
# │           Oh My Posh Prompt               │
# ╰──────────────────────────────────────────╯
# Ubuntu has no apt package for oh-my-posh, so fall back to a native prompt.
if command -v oh-my-posh &>/dev/null; then
  eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/emodipt-extend.omp.json)"
else
  [[ -f ~/.config/zsh/prompt.zsh ]] && source ~/.config/zsh/prompt.zsh
fi

# ╭──────────────────────────────────────────╮
# │               Direnv                     │
# ╰──────────────────────────────────────────╯
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# ╭──────────────────────────────────────────╮
# │           NVM — lazy load                 │
# ╰──────────────────────────────────────────╯
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  # git clone install lives in ~/.nvm; Homebrew keeps the script elsewhere.
  _source_first "$NVM_DIR/nvm.sh" /opt/homebrew/opt/nvm/nvm.sh
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
# Put nvm's default Node on PATH up front, so nvim (Mason, treesitter) and
# other tools find node/npm without loading the slow nvm.sh.
_nvm_default_bin() {
  local v i
  v="$(<"$NVM_DIR/alias/default")" 2>/dev/null || return 1
  # Follow alias chains such as lts/* -> lts/krypton -> v24.x.
  for i in 1 2 3; do
    [[ -f "$NVM_DIR/alias/$v" ]] || break
    v="$(<"$NVM_DIR/alias/$v")"
  done
  v="${v#v}"
  local -a bins=("$NVM_DIR"/versions/node/v${v}(|.*)/bin(Nn))
  (( ${#bins} )) && print -r -- "${bins[-1]}"
}
_node_bin="$(_nvm_default_bin)"
unfunction _nvm_default_bin
if [[ -n "$_node_bin" ]]; then
  export PATH="$_node_bin:$PATH"
  _nvm_cmds=(nvm)
else
  _nvm_cmds=(nvm node npm npx pnpm yarn corepack)
fi
unset _node_bin
for _cmd in $_nvm_cmds; do
  eval "${_cmd}() { unfunction \$_nvm_cmds; _load_nvm; ${_cmd} \"\$@\"; }"
done
unset _cmd

# Switch Node when entering a project with .nvmrc, installing it if missing.
_auto_nvmrc() {
  [[ -f .nvmrc ]] || return 0
  nvm use --silent 2>/dev/null || nvm install
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _auto_nvmrc
_auto_nvmrc

# ╭──────────────────────────────────────────╮
# │                Bun                       │
# ╰──────────────────────────────────────────╯
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ╭──────────────────────────────────────────╮
# │               pnpm                       │
# ╰──────────────────────────────────────────╯
if [[ "$OS" == "macos" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ╭──────────────────────────────────────────╮
# │              SDKMAN                      │
# ╰──────────────────────────────────────────╯
if [[ "$OS" == "macos" ]]; then
  export SDKMAN_DIR="/opt/homebrew/opt/sdkman-cli/libexec"
  [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
else
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

# ╭──────────────────────────────────────────╮
# │      Docker / Testcontainers (macOS)      │
# ╰──────────────────────────────────────────╯
if [[ "$OS" == "macos" ]]; then
  export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
  export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
  if command -v colima &>/dev/null && command -v jq &>/dev/null; then
    export TESTCONTAINERS_HOST_OVERRIDE=$(colima ls -j 2>/dev/null | jq -r '.address // empty')
  fi
fi
export TESTCONTAINERS_HOST_OVERRIDE="${TESTCONTAINERS_HOST_OVERRIDE:-localhost}"

# ╭──────────────────────────────────────────╮
# │       Angular CLI — lazy completion       │
# ╰──────────────────────────────────────────╯
_ng_completion_loaded=0
ng() {
  if [[ $_ng_completion_loaded -eq 0 ]]; then
    _ng_completion_loaded=1
    source <(command ng completion script)
  fi
  command ng "$@"
}

# ╭──────────────────────────────────────────╮
# │          Mole shell completion            │
# ╰──────────────────────────────────────────╯
command -v mole &>/dev/null && { output="$(mole completion zsh 2>/dev/null)" && eval "$output"; }

# ╭──────────────────────────────────────────╮
# │              Git Aliases                  │
# ╰──────────────────────────────────────────╯
alias gs='git status'
alias gc='git checkout'
alias ga='git add'
alias gaa='git add .'
alias gcm='git commit -m'
alias gca='git commit -am'
alias gp='git push'
alias gl='git pull'
alias gf='git fetch'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gcb='git checkout -b'
alias gm='git merge'

# ╭──────────────────────────────────────────╮
# │             Tmux Aliases                  │
# ╰──────────────────────────────────────────╯
alias tm='tmux'
alias tu='tmux'
alias t,='tmux'
alias ty='tmux'
alias tn='tmux'

# ╭──────────────────────────────────────────╮
# │          Editor / Open Aliases            │
# ╰──────────────────────────────────────────╯
if [[ "$OS" == "macos" ]]; then
  alias code='open -a "Visual Studio Code"'
fi

# ╭──────────────────────────────────────────╮
# │            eza (modern ls)                │
# ╰──────────────────────────────────────────╯
if command -v eza &>/dev/null; then
  alias ls='eza'
  alias ll='eza -lh'
  alias la='eza -lha'
  alias lt='eza -T'
  alias llt='eza -lhT'
  alias lg='eza -lh --git'
  alias ld='eza -lhD'
fi

# ╭──────────────────────────────────────────╮
# │             Env / Locale                  │
# ╰──────────────────────────────────────────╯
export LANG=en_US.UTF-8
export ARCHFLAGS="-arch $(uname -m)"
export MANPATH="/usr/local/man:$MANPATH"
