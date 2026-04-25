# ls / file ops
alias ls='eza --icons --git'
alias ll='eza -l --icons --git --time-style=long-iso'
alias la='eza -la --icons --git --time-style=long-iso'
alias lt='eza --tree --icons --level=2'

# tools
alias cat='bat'
alias top='btop'
alias lg='lazygit'
alias du='dust'
alias g='git'

# git shortcuts
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'
alias gcb='git checkout -b'

# dotfiles management
alias dotfiles='cd $DOTFILES'
alias brewdump='brew bundle dump --describe --force --file=$DOTFILES/Brewfile'

# AeroSpace helpers
alias ws='aerospace list-workspaces --all'

# Quick edits
alias zshrc='$EDITOR $DOTFILES/zsh/.zshrc'
alias aero='$EDITOR $DOTFILES/aerospace/.config/aerospace/aerospace.toml'
