#!/usr/bin/env bash
# Pull dotfiles, update brew, restow, restart services.
set -euo pipefail
DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"

step() { printf "\n\033[1;35m▸ %s\033[0m\n" "$*"; }

cd "$DOTFILES"

step "git pull"
git pull --rebase --autostash

step "brew update + bundle"
brew update
brew bundle --file="$DOTFILES/Brewfile"
brew upgrade

step "restow"
PACKAGES=(zsh git ghostty starship aerospace karabiner sketchybar borders
          tmux atuin fastfetch claude)
for pkg in "${PACKAGES[@]}"; do
  [ -d "$pkg" ] && stow --restow --target="$HOME" "$pkg"
done

step "restart services"
brew services restart sketchybar 2>/dev/null || true
brew services restart borders    2>/dev/null || true

echo "Update complete."
