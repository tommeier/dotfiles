# Agent Instructions

This repository contains personal dotfiles for macOS with zsh.

## Key Files

- `zshrc` - Main zsh configuration (primary shell)
- `bashrc` - Bash configuration (secondary)
- `Rakefile` - Installation script (Ruby) — symlinks dotfiles to `~/`
- `terminal/` - Shell functions and aliases (sourced by both zsh and bash)
- `claude/` - Claude Code config (individual files symlinked into `~/.claude/`)
- `Brewfile` - Homebrew packages (includes `duti` for default app management)
- `bin/bootstrap` - Fresh machine setup script
- `bin/macos` - macOS system defaults (includes setting VS Code as default editor for code files)

## Installation

```bash
REPLACE_ALL=true rake install
```

## Testing Changes

After editing shell configs, test with:
```bash
source ~/.zshrc
```

Syntax-check scripts before committing:
```bash
bash -n terminal/<file>.sh
```

## Conventions

- Use `$HOME` or `~` instead of hardcoded paths
- Scripts in `terminal/` are sourced, not executed (no shebangs needed)
- Quote all variables: `"$var"` not `$var`
- Use `$(command)` not backticks
- Use `grep -E` not `egrep` (deprecated)
- Machine-specific config goes in `~/.localrc` (not tracked)
- Private synced config goes in `~/.privaterc` (separate repo)
- Language versions managed by mise via `.tool-versions`
- ERB templates (`.erb`) are rendered at install time, not symlinked
