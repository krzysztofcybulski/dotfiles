# Dedupe PATH
typeset -U path PATH

# User binaries
[ -d "$HOME/.local/bin" ] && path=("$HOME/.local/bin" $path)

# Cargo
[ -d "$HOME/.cargo/bin" ] && path=("$HOME/.cargo/bin" $path)

# Bun
if [ -d "$HOME/.bun" ]; then
  export BUN_INSTALL="$HOME/.bun"
  path=("$BUN_INSTALL/bin" $path)
fi

# Atuin (curl install location)
[ -d "$HOME/.atuin/bin" ] && path=("$HOME/.atuin/bin" $path)

export PATH
