#!/bin/zsh

autoload -Uz add-zsh-hook vcs_info

setopt prompt_subst

add-zsh-hook precmd vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '|+'
zstyle ':vcs_info:*' stagedstr '|*'
zstyle ':vcs_info:git:*' formats '(%b%m%u%c) '
zstyle ':vcs_info:git:*' actionformats '(%b%u%c|%a) '
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

+vi-git-untracked() {
  if [[ -n $(git status --porcelain 2>/dev/null | grep '^??') ]]; then
    hook_com[misc]+='|!'
  fi
}

PROMPT='%F{green}%~ %F{magenta}${vcs_info_msg_0_}%F{yellow}%#%f '
