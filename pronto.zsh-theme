#!/bin/zsh

autoload -Uz add-zsh-hook edit-command-line

setopt prompt_subst

add-zsh-hook precmd vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '|+'
zstyle ':vcs_info:*' stagedstr '|*'
zstyle ':vcs_info:git:*' formats '(%b%m%u%c) '
zstyle ':vcs_info:git:*' actionformats '(%b%u%c|%a) '
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

function +vi-git-untracked() {
  if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
    hook_com[misc]+='|!'
  fi
}

function _pronto_pwd() {
  echo "${PWD/#$HOME/~}" | sed 's|\([^/]\)[^/]*/|\1/|g'
}

function vi-mode-color() {
  local color=$([[ $KEYMAP == vicmd ]] && echo blue || echo yellow)
  local git_info=${vcs_info_msg_0_}
  local prompt_pwd=$(_pronto_pwd)
  local status_color="%(?.%F{$color}.%F{red})"

  PROMPT="%F{green}${prompt_pwd} %F{magenta}${git_info}${status_color}%#%f "

  zle reset-prompt
}

zle -N edit-command-line
zle -N zle-line-init vi-mode-color
zle -N zle-keymap-select vi-mode-color

bindkey -M vicmd '^[e' edit-command-line
bindkey -M viins '^e' edit-command-line
