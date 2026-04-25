#!/usr/bin/env bash
# Regenerate Brewfile from current install state. Comments are lost.
set -euo pipefail
DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
brew bundle dump --describe --force --file="$DOTFILES/Brewfile"
echo "Brewfile updated. Re-add header comments by hand if you want."
