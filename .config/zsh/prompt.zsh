# Native zsh prompt, used when oh-my-posh is not installed (Ubuntu via apt).
# Mirrors emodipt-extend.omp.json using 256 colors and no Nerd Font glyphs,
# so it renders with any monospace font.
#
#   [14:02] zsh main *+
#   ~/projects/api
#   ❯                                   x1 230ms

autoload -Uz vcs_info add-zsh-hook
zmodload zsh/datetime
setopt prompt_subst

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats '%b %u%c'
zstyle ':vcs_info:git:*' actionformats '%b|%a %u%c'

_prompt_preexec() { _prompt_start=$EPOCHREALTIME }

_prompt_precmd() {
  local code=$? elapsed=""

  if [[ -n $_prompt_start ]]; then
    local -i ms=$(( (EPOCHREALTIME - _prompt_start) * 1000 ))
    if (( ms < 1000 )); then
      elapsed="${ms}ms"
    else
      elapsed="$(printf '%.1fs' $(( ms / 1000.0 )))"
    fi
    unset _prompt_start
  fi

  if (( code != 0 )); then
    _prompt_status="%F{168}x${code} ${elapsed}%f"
  else
    _prompt_status="%F{156}${elapsed}%f"
  fi

  vcs_info
  local git="${vcs_info_msg_0_%% }"
  # Escape % so branch names cannot inject prompt sequences.
  git="${git//\%/%%}"
  if [[ -z $git ]]; then
    _prompt_git=""
  elif [[ $git == *' '[*+]* ]]; then
    _prompt_git=" %F{209}${git}%f"
  else
    _prompt_git=" %F{221}${git}%f"
  fi
}

add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd

PROMPT=$'\n''%F{180}[%D{%H:%M}]%f %F{168}zsh%f${_prompt_git}'$'\n'
PROMPT+='%F{75}%~%f'$'\n'
PROMPT+='%(!.%F{168}!%f.)%F{168}❯%f '
RPROMPT='${_prompt_status}'
