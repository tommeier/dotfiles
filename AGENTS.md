# Agent Instructions

This repository contains personal dotfiles for macOS with zsh.

## Key Files

- `zshrc` - Main zsh configuration
- `bashrc` - Bash configuration (secondary)
- `Rakefile` - Installation script (Ruby)
- `terminal/` - Shell functions and aliases
- `claude/` - Claude Code config (individual files symlinked into `~/.claude/`)

## Installation

```bash
REPLACE_ALL=true rake install
```

## Testing Changes

After editing shell configs, test with:
```bash
source ~/.zshrc
```

## Conventions

- Use `$HOME` or `~` instead of hardcoded paths
- Scripts in `terminal/` are sourced, not executed (no shebangs needed)
- Machine-specific config goes in `~/.localrc` (not tracked)
- Language versions managed by mise via `.tool-versions`
