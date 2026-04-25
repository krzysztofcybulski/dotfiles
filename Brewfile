# Krzysztof's Brewfile — managed in dotfiles repo.
# Re-dump with: brewdump (alias) or scripts/brew-dump.sh

# ============================================================================
# Taps
# ============================================================================
tap "homebrew/bundle"
tap "felixkratz/formulae"
tap "nikitabobko/tap"
tap "yannjor/krabby"

# ============================================================================
# Runtimes (needed by SbarLua, MCP servers, Claude Code, etc.)
# ============================================================================
brew "lua"                     # SbarLua bridge
brew "node"                    # npx for MCP servers
brew "bun"                     # preferred JS runtime / pkg manager

# ============================================================================
# CLI essentials
# ============================================================================
brew "stow"                    # dotfiles symlinker
brew "mas"                     # Mac App Store CLI
brew "gh"                      # GitHub CLI
brew "jq"                      # JSON
brew "git-delta"               # better diffs
brew "ripgrep"                 # rg
brew "fd"                      # better find
brew "fzf"                     # fuzzy finder
brew "bat"                     # better cat
brew "eza"                     # better ls
brew "zoxide"                  # smarter cd
brew "starship"                # prompt
brew "atuin"                   # shell history
brew "tldr"                    # cheatsheets
brew "lazygit"                 # git TUI
brew "btop"                    # better top
brew "dust"                    # better du
brew "tmux"                    # multiplexer
brew "fastfetch"               # system info
brew "krabby"                  # random pokémon for fastfetch logo
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# ============================================================================
# Window management & status bar
# ============================================================================
cask "nikitabobko/tap/aerospace"
brew "felixkratz/formulae/sketchybar"
brew "borders"                 # JankyBorders

# ============================================================================
# Key remap
# ============================================================================
cask "karabiner-elements"

# ============================================================================
# Terminal & dev
# ============================================================================
cask "ghostty"
cask "cursor"
cask "docker-desktop"          # the `docker` cask was renamed in 2025

# ============================================================================
# Fonts
# ============================================================================
cask "font-maple-mono-nf"
cask "font-sf-pro"
cask "sf-symbols"

# ============================================================================
# Apps
# ============================================================================
cask "arc"
cask "slack"
cask "spotify"
cask "whatsapp"
cask "craft"
cask "raycast"

# Premium niche tier
cask "jordanbaird-ice"         # Ice — menu bar manager
cask "soulver"

# ============================================================================
# Mac App Store (requires being signed in to App Store)
# ============================================================================
mas "Spokenly", id: 6740315592       # voice dictation (Caps-Lock-tap → F18)
mas "Plash",     id: 1494023538       # website-as-wallpaper
mas "ColorSlurp", id: 1287239339      # menu-bar color picker
