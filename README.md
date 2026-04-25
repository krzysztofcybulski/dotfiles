# Krzysztof's Dotfiles

Single-machine macOS power-user setup. GNU Stow + Brewfile + idempotent `bootstrap.sh`.

## Install

```bash
git clone <repo> ~/Projects/dotfiles
cd ~/Projects/dotfiles
./bootstrap.sh
```

Re-run any time — the script is idempotent (Stow `--restow`, brew bundle, defaults are write-on-each-run).

## Stack

- **Window manager**: AeroSpace + JankyBorders + SketchyBar
- **Theme everywhere**: Tokyo Night
- **Font**: Maple Mono NF
- **Key remap**: Karabiner — Caps Lock = Hyper (held) / F18 (tapped → Spokenly)
- **Terminal**: Ghostty + Zsh + Starship + tmux (omerxx plugins)
- **Voice**: Spokenly (set its global hotkey to **F18**)
- **Modern CLI**: atuin, fzf, ripgrep, fd, eza, bat, zoxide, delta, lazygit, btop, dust, tldr, fastfetch
- **AI dev**: Claude Code with managed `~/.claude/`

## Layout

Each top-level directory is a Stow "package" mirroring `$HOME`:

| Package      | Symlinks to                                                    |
|--------------|----------------------------------------------------------------|
| `zsh/`       | `~/.zshrc`, `~/.zprofile`, `~/.zshenv`, `~/.config/zsh/`       |
| `git/`       | `~/.gitconfig`, `~/.config/git/ignore`                         |
| `ghostty/`   | `~/Library/Application Support/com.mitchellh.ghostty/config`   |
| `starship/`  | `~/.config/starship.toml`                                      |
| `aerospace/` | `~/.config/aerospace/aerospace.toml`                           |
| `karabiner/` | `~/.config/karabiner/karabiner.json`                           |
| `sketchybar/`| `~/.config/sketchybar/`                                        |
| `borders/`   | `~/.config/borders/bordersrc`                                  |
| `tmux/`      | `~/.config/tmux/tmux.conf`                                     |
| `atuin/`     | `~/.config/atuin/config.toml`                                  |
| `fastfetch/` | `~/.config/fastfetch/`                                         |
| `claude/`    | `~/.claude/`                                                   |
| `services/`  | `~/Library/Services/` (Finder Quick Actions)                   |

## Hyper-key bindings

Hyper = `⌘⌃⌥⇧` (sent when holding Caps Lock).

**App launchers**

| Chord     | App      |
|-----------|----------|
| Hyper+A   | Arc      |
| Hyper+W   | Ghostty  |
| Hyper+S   | Slack    |
| Hyper+C   | Cursor   |
| Hyper+D   | Craft    |
| Hyper+E   | WhatsApp |
| Hyper+M   | Spotify  |

**AeroSpace**

| Chord           | Action                    |
|-----------------|---------------------------|
| Hyper+H/J/K/L   | Focus left/down/up/right  |
| Hyper+1..5      | Switch to workspace 1..5  |
| Hyper+R         | Resize submode            |
| Hyper+V         | Move submode              |
| Hyper+F         | Fullscreen                |
| Hyper+/         | Toggle tiling layout      |
| Hyper+Space     | Toggle floating           |
| Hyper+Tab       | Last workspace            |

Workspaces: 1=Main, 2=Terminal, 3=IDE, 4=Spotify, 5=Overflow.

## Finder Quick Actions

Two Services ship with the `services/` package:

- **Open Claude Here** — right-click any folder in Finder → Quick Actions / Services → opens Ghostty in that folder and runs `claude`.
- **Open Claude in Current Folder** — Finder menubar → Services → uses the front Finder window's path. Bind a shortcut in System Settings → Keyboard → Keyboard Shortcuts → Services if you want a key for it.

Both invoke `zsh -ic claude` so your `.zshrc` aliases (e.g. the Newt-wrapped `claude`) are honored.

## Manual post-install steps

1. Grant Accessibility / Input Monitoring / Screen Recording to: **Karabiner-Elements, AeroSpace, Raycast, SketchyBar, Ice**.
2. Open **Spokenly** → set global hotkey to **F18**.
3. `gh auth login`
4. Sign in to App Store (for `mas` Spokenly install).
5. After first `claude` CLI run: `bash scripts/setup-mcp.sh` to register MCP servers.
