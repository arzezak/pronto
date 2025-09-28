# Walkthrough

This document explains what each line in the `pronto.zsh-theme` file does.

## Shebang

```zsh
#!/bin/zsh
```

Standard shebang line indicating this is a Zsh script.

## Function Loading

```zsh
autoload -Uz add-zsh-hook edit-command-line
```
Loads two Zsh functions:

- `add-zsh-hook`: Allows adding functions to Zsh hooks (event system)
- `edit-command-line`: Enables editing the current command line in an external editor

The `-Uz` flags mean:

- `-U`: Don't expand aliases when loading
- `-z`: Use Zsh-style autoloading

## Prompt Substitution

```zsh
setopt prompt_subst
```

Enables parameter expansion, command substitution, and arithmetic expansion in prompts. This allows dynamic content like `$(short-pwd)` to be evaluated each time the prompt is displayed.

## Hook Registration

```zsh
add-zsh-hook precmd vcs_info
```

Registers the `vcs_info` function to run before each command prompt is displayed (`precmd` hook). This updates Git information before showing the prompt.

## Git Integration Setup

```zsh
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '|+'
zstyle ':vcs_info:*' stagedstr '|*'
zstyle ':vcs_info:git:*' formats '(%b%m%u%c) '
zstyle ':vcs_info:git:*' actionformats '(%b%u%c|%a) '
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
```

Configures the `vcs_info` system:

- Enable Git support only
- Check for staged/unstaged changes (slower but more informative)
- Show `|+` for unstaged changes
- Show `|*` for staged changes
- Format for normal Git state: `(branch|indicators) `
- Format during Git actions (merge, rebase, etc.): `(branch|indicators|action) `
- Register a custom hook for untracked files

## Untracked Files Detection

```zsh
function +vi-git-untracked() {
  if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
    hook_com[misc]+='|!'
  fi
}
```

Custom function that adds `|!` to the prompt when there are untracked files:

- `git ls-files --others --exclude-standard`: Lists untracked files (respecting .gitignore)
- `2>/dev/null`: Suppresses error messages
- `hook_com[misc]`: Special array used by vcs_info to store additional information

## Directory Abbreviation

```zsh
function _pronto_pwd() {
  echo "${PWD/#$HOME/~}" | sed 's|\([^/]\)[^/]*/|\1/|g'
}
```

Creates abbreviated directory paths (Fish shell style):

- `${PWD/#$HOME/~}`: Replace home directory with `~`
- `sed 's|\([^/]\)[^/]*/|\1/|g'`: Keep only first character of each directory except the last
- Example: `/Users/name/Developer/project` → `~/D/project`

## Vi-mode Color Function

```zsh
function vi-mode-color() {
  local color=$([[ $KEYMAP == vicmd ]] && echo blue || echo yellow)
  local status_color="%(?.%F{$color}.%F{red})"

  PROMPT="%F{green}\$(_pronto_pwd) %F{magenta}\${vcs_info_msg_0_}${status_color}%#%f "

  zle reset-prompt
}
```

Updates prompt colors based on vi-mode state and command exit status:

- Set color to blue for command mode (`vicmd`), yellow for insert mode
- Create status_color variable with conditional coloring: `%(?.%F{$color}.%F{red})`
  - `?` checks the exit status of the previous command
  - If exit status is 0 (success), use vi-mode color
  - If exit status is non-zero (failure), use red color
- Build the prompt with:
  - `%F{green}`: Green color for directory
  - `\$(_pronto_pwd)`: Abbreviated directory path
  - `%F{magenta}`: Magenta color for Git info
  - `\${vcs_info_msg_0_}`: Git branch and status
  - `${status_color}`: Exit status dependent color (vi-mode or red)
  - `%#`: `#` for root, `%` for regular user
  - `%f`: Reset color
- Refresh the prompt display

## Widget Registration

```zsh
zle -N edit-command-line
zle -N zle-line-init vi-mode-color
zle -N zle-keymap-select vi-mode-color
```

Registers ZLE (Zsh Line Editor) widgets:

- Register `edit-command-line` as a widget
- Call `vi-mode-color` when line editor initializes
- Call `vi-mode-color` when keymap changes (vi-mode switches)

## Key Bindings

```zsh
bindkey -M vicmd '^[e' edit-command-line
bindkey -M viins '^e' edit-command-line
```

Sets up keybindings for external editor:

- `Alt+e` in vi command mode opens external editor
- `Ctrl+e` in vi insert mode opens external editor

## Prompt Result

The final prompt displays as:

```
~/D/p/pronto (main|+) %
```

Where:

- `~/D/p/pronto`: Abbreviated current directory
- `(main|+)`: Git branch with unstaged changes indicator
- `%`: Prompt character (yellow for insert mode, blue for command mode)
