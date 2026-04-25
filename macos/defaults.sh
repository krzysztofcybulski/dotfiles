#!/usr/bin/env bash
# macOS defaults — adapted from mathiasbynens/.macos, pruned for our setup.
# Re-running this is safe (`defaults write` overwrites in place).
set -euo pipefail

# Close System Settings to prevent overrides
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# ============================================================================
# Keyboard
# ============================================================================
# Disable press-and-hold for keys (faster repeat)
defaults write -g ApplePressAndHoldEnabled -bool false
# Faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Disable autocorrect / smart-quotes / dashes (developer poison)
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# ============================================================================
# Trackpad / mouse
# ============================================================================
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ============================================================================
# Window dragging (huge for AeroSpace floating windows)
# ============================================================================
defaults write -g NSWindowShouldDragOnGesture -bool true

# ============================================================================
# Dock
# ============================================================================
# Empty the persistent dock
defaults write com.apple.dock persistent-apps -array
# Auto-hide + speed
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
# Disable hot corners
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-br-corner -int 0

# ============================================================================
# Menu bar (auto-hide; tighter spacing for SketchyBar look)
# ============================================================================
defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 8
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 6

# ============================================================================
# Finder
# ============================================================================
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # current folder
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
# Disable .DS_Store on network/USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ============================================================================
# Disable Spotlight Cmd+Space (frees it for Raycast)
# ============================================================================
/usr/libexec/PlistBuddy \
  -c 'Set :AppleSymbolicHotKeys:64:enabled false' \
  -c 'Set :AppleSymbolicHotKeys:65:enabled false' \
  ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || true

# ============================================================================
# Stage Manager off (fights AeroSpace)
# ============================================================================
defaults write com.apple.WindowManager GloballyEnabled -bool false

# ============================================================================
# Screenshots (use ~/Pictures/Screenshots, no shadow, png)
# ============================================================================
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# ============================================================================
# Apply
# ============================================================================
killall cfprefsd Dock Finder SystemUIServer 2>/dev/null || true
echo "macOS defaults applied. Some changes require logout/restart."
