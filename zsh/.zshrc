# ============================================================================
# History
# ============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS SHARE_HISTORY INC_APPEND_HISTORY

# ============================================================================
# Options
# ============================================================================
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt INTERACTIVE_COMMENTS NO_BEEP

# ============================================================================
# Completion
# ============================================================================
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ============================================================================
# Plugins (no oh-my-zsh)
# ============================================================================
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ============================================================================
# Tools
# ============================================================================
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v zoxide   &>/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v atuin    &>/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# fzf key bindings
[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && \
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && \
  source /opt/homebrew/opt/fzf/shell/completion.zsh

# ============================================================================
# Modular config — load every .zsh in ~/.config/zsh/
# ============================================================================
if [ -d "$HOME/.config/zsh" ]; then
  for f in "$HOME/.config/zsh"/*.zsh(N); do
    source "$f"
  done
fi

# ============================================================================
# fastfetch on first interactive shell of the day
# ============================================================================
if [[ -o interactive && -z "$TMUX" ]] && command -v fastfetch &>/dev/null; then
  STAMP="$XDG_CACHE_HOME/fastfetch.last"
  TODAY=$(date +%Y%j)
  LAST=$(cat "$STAMP" 2>/dev/null)
  if [[ "$TODAY" != "$LAST" ]]; then
    if command -v krabby &>/dev/null; then
      fastfetch \
        --logo-type file-raw \
        --logo =(~/.config/fastfetch/random-pokemon.sh) \
        --logo-padding-right 2
    else
      fastfetch
    fi
    mkdir -p "$XDG_CACHE_HOME" && echo "$TODAY" > "$STAMP"
  fi
fi
