#!/usr/bin/env bash
# bootstrap.sh — one-click macOS setup. Idempotent, designed to run on a
# fresh MacBook from zero.
#
# Usage:
#   ./bootstrap.sh             # full run
#   ./bootstrap.sh --dry-run   # show what would happen
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

step()  { printf "\n\033[1;35m▸ %s\033[0m\n" "$*"; }
info()  { printf "  \033[2m%s\033[0m\n" "$*"; }
warn()  { printf "  \033[1;33m! %s\033[0m\n" "$*"; }
fail()  { printf "\033[1;31m✗ %s\033[0m\n" "$*"; exit 1; }
run()   { if [ "$DRY_RUN" = 1 ]; then echo "  [dry-run] $*"; else eval "$@"; fi; }

# ----------------------------------------------------------------------------
# 0. Sanity
# ----------------------------------------------------------------------------
[ "$(uname)" = "Darwin" ] || fail "macOS only."
[ -d "$DOTFILES" ] || fail "Clone repo to $DOTFILES first."

ARCH="$(uname -m)"
if [ "$ARCH" = "arm64" ]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi
info "Detected arch: $ARCH (Homebrew prefix: $BREW_PREFIX)"

# ----------------------------------------------------------------------------
# 1. Xcode Command Line Tools
# ----------------------------------------------------------------------------
if ! xcode-select -p &>/dev/null; then
  step "Installing Xcode Command Line Tools"
  run "xcode-select --install"
  if [ "$DRY_RUN" = 0 ]; then
    info "Waiting for CLT install to finish (close the dialog when done)…"
    until xcode-select -p &>/dev/null; do sleep 5; done
  fi
fi

# ----------------------------------------------------------------------------
# 2. Homebrew
# ----------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  step "Installing Homebrew"
  run 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  if [ "$DRY_RUN" = 0 ] && ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
    echo "eval \"\$($BREW_PREFIX/bin/brew shellenv)\"" >> "$HOME/.zprofile"
  fi
fi
[ -x "$BREW_PREFIX/bin/brew" ] && eval "$($BREW_PREFIX/bin/brew shellenv)"

# ----------------------------------------------------------------------------
# 3. Mac App Store sign-in check (mas can't sign in itself since macOS 10.15)
# ----------------------------------------------------------------------------
if grep -q '^mas ' "$DOTFILES/Brewfile" 2>/dev/null; then
  if command -v mas &>/dev/null && ! mas account &>/dev/null; then
    warn "Not signed in to App Store — open the App Store app and sign in,"
    warn "then re-run this script. (mas commands in Brewfile will fail otherwise.)"
    warn "Press Enter to continue anyway, or Ctrl-C to abort."
    [ "$DRY_RUN" = 0 ] && read -r _
  fi
fi

# ----------------------------------------------------------------------------
# 4. Brewfile
# ----------------------------------------------------------------------------
step "Running brew bundle"
run "brew bundle --file=\"$DOTFILES/Brewfile\""

# ----------------------------------------------------------------------------
# 5. Pre-stow: back up conflicting real files at target locations.
#    Stow refuses to overwrite real files; --restow handles symlinks fine.
# ----------------------------------------------------------------------------
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
declare -a CONFLICT_FILES=(
  "$HOME/.zshrc"
  "$HOME/.zprofile"
  "$HOME/.zshenv"
  "$HOME/.gitconfig"
  "$HOME/.config/karabiner/karabiner.json"
  "$HOME/.config/aerospace/aerospace.toml"
  "$HOME/.config/sketchybar"
  "$HOME/.config/borders/bordersrc"
  "$HOME/.config/tmux/tmux.conf"
  "$HOME/.config/atuin/config.toml"
  "$HOME/.config/fastfetch"
  "$HOME/.config/starship.toml"
  "$HOME/.config/git/ignore"
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
)

NEEDS_BACKUP=0
for path in "${CONFLICT_FILES[@]}"; do
  if [ -e "$path" ] && [ ! -L "$path" ]; then
    NEEDS_BACKUP=1; break
  fi
done

if [ "$NEEDS_BACKUP" = 1 ]; then
  step "Backing up existing real files to $BACKUP_DIR"
  [ "$DRY_RUN" = 0 ] && mkdir -p "$BACKUP_DIR"
  for path in "${CONFLICT_FILES[@]}"; do
    if [ -e "$path" ] && [ ! -L "$path" ]; then
      rel="${path#$HOME/}"
      dst="$BACKUP_DIR/$rel"
      info "  $path"
      if [ "$DRY_RUN" = 1 ]; then
        echo "  [dry-run] mv \"$path\" \"$dst\""
      else
        mkdir -p "$(dirname "$dst")"
        mv "$path" "$dst"
      fi
    fi
  done
  info "Originals preserved in $BACKUP_DIR — diff against new symlinks if needed."
fi

# ----------------------------------------------------------------------------
# 6. Stow symlinks
# ----------------------------------------------------------------------------
step "Stowing dotfiles"
PACKAGES=(zsh git ghostty starship aerospace karabiner sketchybar borders
          tmux atuin fastfetch claude services musictags)

for pkg in "${PACKAGES[@]}"; do
  [ -d "$DOTFILES/$pkg" ] || continue
  info "stow $pkg"
  run "(cd \"$DOTFILES\" && stow --restow --target=\"$HOME\" \"$pkg\")"
done

# ----------------------------------------------------------------------------
# 7. macOS defaults
# ----------------------------------------------------------------------------
step "Applying macOS defaults"
run "bash \"$DOTFILES/macos/defaults.sh\""

# ----------------------------------------------------------------------------
# 7b. Refresh Finder Services registration
#     LaunchServices caches ~/Library/Services/*.workflow; nudge it so freshly
#     stowed Quick Actions show up in Finder right-click without a logout.
# ----------------------------------------------------------------------------
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"
if [ -x "$LSREGISTER" ]; then
  step "Refreshing macOS Services registration"
  run "\"$LSREGISTER\" -kill -r -domain user >/dev/null 2>&1 || true"
  run "/usr/bin/killall -HUP pbs 2>/dev/null || true"
fi

# ----------------------------------------------------------------------------
# 8. fzf shell integration (key bindings + completion)
# ----------------------------------------------------------------------------
if [ -f "$BREW_PREFIX/opt/fzf/install" ] && [ ! -f "$HOME/.fzf.zsh" ]; then
  step "Installing fzf shell integration"
  run "$BREW_PREFIX/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish"
fi

# ----------------------------------------------------------------------------
# 9. SbarLua (FelixKratz's Lua bridge for SketchyBar)
# ----------------------------------------------------------------------------
SBARLUA_LIB="$BREW_PREFIX/lib/lua/5.4/sketchybar.so"
if [ ! -f "$SBARLUA_LIB" ]; then
  step "Installing SbarLua"
  TMP_SBAR=$(mktemp -d)
  run "git clone --depth 1 https://github.com/FelixKratz/SbarLua.git \"$TMP_SBAR\""
  run "(cd \"$TMP_SBAR\" && make install)"
  run "rm -rf \"$TMP_SBAR\""
fi

# ----------------------------------------------------------------------------
# 10. sketchybar-app-font
# ----------------------------------------------------------------------------
FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"
if [ ! -f "$FONT_DIR/sketchybar-app-font.ttf" ]; then
  step "Installing sketchybar-app-font"
  run "curl -fsSL -o \"$FONT_DIR/sketchybar-app-font.ttf\" \
        \"https://github.com/kvndrsslr/sketchybar-app-font/releases/latest/download/sketchybar-app-font.ttf\""
fi

# ----------------------------------------------------------------------------
# 11. tmux plugin manager (TPM) — needs ~/.config/tmux to exist (stowed)
# ----------------------------------------------------------------------------
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  step "Installing tmux plugin manager"
  run "git clone --depth 1 https://github.com/tmux-plugins/tpm \"$TPM_DIR\""
fi

# ----------------------------------------------------------------------------
# 12. Claude Code CLI (npm-based; not on Homebrew)
# ----------------------------------------------------------------------------
if ! command -v claude &>/dev/null; then
  step "Installing Claude Code CLI"
  if command -v bun &>/dev/null; then
    run "bun add --global @anthropic-ai/claude-code"
  elif command -v npm &>/dev/null; then
    run "npm install -g @anthropic-ai/claude-code"
  else
    warn "Neither bun nor npm available — install Claude Code manually:"
    warn "  https://docs.claude.com/en/docs/claude-code/quickstart"
  fi
fi

# ----------------------------------------------------------------------------
# 13. Claude Code plugin: game-sounds (Citedy/game-sounds)
#     Retro game SFX on Claude lifecycle events. Plugin ships its own hooks,
#     so ~/.claude/settings.json stays untouched. macOS-only (uses afplay).
# ----------------------------------------------------------------------------
if command -v claude &>/dev/null; then
  step "Installing game-sounds Claude plugin"
  run "claude plugin marketplace add citedy/claude-plugins 2>/dev/null || true"
  run "claude plugin install game-sounds@citedy 2>/dev/null || true"

  if [ "$DRY_RUN" = 0 ]; then
    GS_CONFIG="$(find "$HOME/.claude/plugins" -type f -name config.json -path '*game-sounds*' 2>/dev/null | head -n1)"
    if [ -n "$GS_CONFIG" ] && command -v jq &>/dev/null; then
      info "Configuring game-sounds → pack=starcraft, quiet prompts/turns"
      tmp="$(mktemp)"
      jq '.active_pack = "starcraft"
          | .enabled_events["session-start"]    = true
          | .enabled_events["task-acknowledge"] = false
          | .enabled_events["task-complete"]    = false
          | .enabled_events.error               = true
          | .enabled_events.permission          = true' \
        "$GS_CONFIG" > "$tmp" && mv "$tmp" "$GS_CONFIG"
    else
      warn "game-sounds config.json not found or jq missing — skipping pack/event config."
      warn "Run manually: game-sounds switch starcraft"
    fi
  fi
fi

# ----------------------------------------------------------------------------
# 14. Default shell → zsh
# ----------------------------------------------------------------------------
ZSH_PATH="$(command -v zsh)"
if [ -n "$ZSH_PATH" ] && [ "$SHELL" != "$ZSH_PATH" ]; then
  step "Changing default shell to zsh"
  if ! grep -qx "$ZSH_PATH" /etc/shells; then
    run "echo \"$ZSH_PATH\" | sudo tee -a /etc/shells >/dev/null"
  fi
  run "chsh -s \"$ZSH_PATH\""
fi

# ----------------------------------------------------------------------------
# 15. Restart services
# ----------------------------------------------------------------------------
step "Starting services"
run "brew services restart sketchybar 2>/dev/null || true"
run "brew services restart borders    2>/dev/null || true"

# ----------------------------------------------------------------------------
# 16. Manual reminders
# ----------------------------------------------------------------------------
cat <<EOF

╭─────────────────────────────────────────────────────────────────╮
│  ✅ Bootstrap complete. Manual steps remaining:                 │
│                                                                 │
│  1. System Settings → Privacy & Security → Accessibility:       │
│     enable Karabiner-Elements, AeroSpace, Raycast, Ice.         │
│  2. System Settings → Privacy & Security → Input Monitoring:    │
│     enable karabiner_grabber and karabiner_observer.            │
│  3. System Settings → Privacy & Security → Screen Recording:    │
│     enable SketchyBar, Ice.                                     │
│  4. Open Spokenly once, set its global hotkey to F18.           │
│  5. gh auth login                                               │
│  6. After Claude Code login, run: bash scripts/setup-mcp.sh     │
$( [ "$NEEDS_BACKUP" = 1 ] && echo "│  7. Compare your old configs in $BACKUP_DIR" )
│                                                                 │
│  Restart or log out so the shell + services pick up changes.    │
╰─────────────────────────────────────────────────────────────────╯

EOF
