# Personal preferences

## Tooling defaults

- **Package manager**: prefer `bun` over `npm`/`yarn`/`pnpm` when both lockfiles or both binaries are present. Fall back to whatever the project's lockfile dictates.
- **Formatters**: `prettier` for JS/TS, `ruff format` for Python. Don't add a formatter the project doesn't already have.
- **Shell tools**: prefer `rg` over `grep`, `fd` over `find`, `eza` over `ls`, `bat` over `cat` when running commands for me. (These all live in the user's `$PATH`.)
- **Editor**: `cursor` (set as `$EDITOR`).
- **Git**: `delta` is configured as the pager — `git diff` output is already pretty.

## Aesthetic

- Tokyo Night palette wherever colors are configurable in code I write (themes, dashboards, READMEs with badges, etc.).

## Behavior

- Don't summarize work I just watched you do.
- Skip preamble like "I'll now…", "Let me…", "Here's what I'll do…". Just do it.
- For pure questions (no code change), answer in plain prose, not bulleted reports.
- When unsure between two approaches, ask — don't pick silently.

## What lives where

- Dotfiles repo: `~/Projects/dotfiles` (Stow-managed)
- This file: `~/.claude/CLAUDE.md` (user-level, applied everywhere)
