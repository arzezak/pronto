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

function short-pwd() {
  echo "${PWD/#$HOME/~}" | sed 's|\([^/]\)[^/]*/|\1/|g'
}

function vi-mode-color() {
  local color=$([[ $KEYMAP == vicmd ]] && echo blue || echo yellow)

  PROMPT="%F{green}\$(short-pwd) %F{magenta}\${vcs_info_msg_0_}%F{$color}%#%f "

  zle reset-prompt
}

zle -N edit-command-line
zle -N zle-line-init vi-mode-color
zle -N zle-keymap-select vi-mode-color

bindkey -M vicmd '^[e' edit-command-line
bindkey -M viins '^e' edit-command-line
