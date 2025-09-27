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
  if [[ -n $(git status --porcelain 2>/dev/null | grep '^??') ]]; then
    hook_com[misc]+='|!'
  fi
}

function vi-mode-color() {
  if [[ $KEYMAP == vicmd ]]; then
    PROMPT='%F{green}%~ %F{magenta}${vcs_info_msg_0_}%F{yellow}%F{blue}%#%f '
  else
    PROMPT='%F{green}%~ %F{magenta}${vcs_info_msg_0_}%F{yellow}%#%f '
  fi

  zle reset-prompt
}

zle -N edit-command-line
zle -N zle-line-init vi-mode-color
zle -N zle-keymap-select vi-mode-color

bindkey -M vicmd ";" edit-command-line
bindkey -M viins "^;" edit-command-line
bindkey -M viins "jk" vi-cmd-mode
