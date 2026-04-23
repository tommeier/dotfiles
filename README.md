# Dotfiles

Personal configuration files for macOS with zsh, oh-my-zsh, and powerlevel10k.

## Quick Start (Fresh macOS Install)

```bash
# Clone the repo
git clone git@github.com:tommeier/dotfiles.git ~/src/personal/dotfiles

# Run the bootstrap script
~/src/personal/dotfiles/bin/bootstrap
```

The bootstrap script will:
1. Install Xcode Command Line Tools
2. Install Homebrew and packages from Brewfile
3. Install Oh My Zsh and Powerlevel10k
4. Set up fzf key bindings
5. Install dotfiles
6. Optionally apply macOS defaults

## Manual Installation

### Prerequisites

```bash
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Core dependencies
brew bundle --file=~/src/personal/dotfiles/Brewfile

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
```

### Install Dotfiles

```bash
cd ~/src/personal/dotfiles
REPLACE_ALL=true rake install
```

Without `REPLACE_ALL=true`, you'll be prompted for each existing file.

### Apply macOS Defaults

```bash
./bin/macos
```

This applies sensible macOS defaults (fast key repeat, Finder settings, Dock config, etc.). Requires restart to take full effect.

## Features

### Modern CLI Tools

The dotfiles integrate these modern replacements (install via `brew bundle`):

| Tool | Replaces | Description |
|------|----------|-------------|
| `rg` (ripgrep) | `grep` | Fast, recursive search |
| `fd` | `find` | User-friendly find |
| `bat` | `cat` | Syntax highlighting |
| `eza` | `ls` | Better file listing with icons |
| `fzf` | - | Fuzzy finder (Ctrl+R, Ctrl+T) |
| `zoxide` | `cd` | Smarter directory navigation |
| `delta` | `diff` | Better git diffs |
| `lazygit` | - | Terminal UI for git |
| `htop` | `top` | Better process viewer |

### Project Switching

Quickly navigate to projects with tab completion:

```bash
p some_project<Tab>
```

Configure project root directories in `terminal/completion_scripts/project_completion_roots`:

```
~/src/
~/src/personal/
~/src/work/
```

### Git Helpers

| Command | Description |
|---------|-------------|
| `sup` / `startup` | Switch to default branch (or main worktree), fetch all remotes, prune, update default branch, clean up merged worktrees/branches. Skips the switch with a loud error if the current worktree is dirty. |
| `remote_sup` | Same as above, plus removes merged remote branches |
| `lg` | Open lazygit |
| `gcob` | Fuzzy checkout branch (fzf + git) |
| `glog` | Fuzzy search git log (fzf + git) |

### Docker Shortcuts

| Command | Description |
|---------|-------------|
| `d`, `dps`, `dpsa` | Docker, ps, ps -a |
| `dc`, `dcu`, `dcd` | Docker Compose up/down |
| `dsh <container>` | Shell into container |
| `docker_prune_all` | Remove all Docker resources (with confirmation) |

### Rails/Ruby Shortcuts

| Command | Description |
|---------|-------------|
| `be` | `bundle exec` |
| `bi`, `bu`, `bo` | bundle install/update/outdated |
| `brc`, `brs` | Rails console/server |
| `brdb`, `brdbr` | Rails db:migrate/rollback |
| `ber`, `berf` | RSpec, RSpec --fail-fast |

### GitHub CLI

| Command | Description |
|---------|-------------|
| `ghpr`, `ghprv` | Create PR, view PR in browser |
| `ghprc`, `ghprm` | Checkout PR, merge PR |
| `ghrepo` | Open repo in browser |

### Other Aliases

| Command | Description |
|---------|-------------|
| `reload` | Reload zsh configuration |
| `flushdns` | Flush DNS cache |
| `please` | Re-run last command with sudo |
| `o` / `of` | Open current dir / in Finder |
| `ip` / `localip` | Get public/local IP |
| `portused 3000` | Check what's using a port |
| `..`, `...`, `....` | Navigate up directories |
| `mkcd dir` | Make directory and cd into it |

## Customization

### Machine-Specific Configuration

Create `~/.localrc` for settings specific to one machine. This file is sourced automatically and is not tracked in git. Use it for:

- Private environment variables
- Work-specific configurations  
- GPG signing key (auto-detected by `rake install`)

**Important:** Never commit secrets. Use a password manager or 1Password CLI for actual credentials.

### Security

- GPG signing is auto-configured during install
- History ignores commands prefixed with space (`HIST_IGNORE_SPACE`)
- `.localrc` has 600 permissions (owner-only)
- Destructive commands require confirmation

## Directory Structure

```
├── bin/
│   ├── bootstrap         # Fresh install script
│   ├── macos             # macOS defaults script
│   └── tagversions       # Version tagging script
├── terminal/
│   ├── aliases.sh        # Shell aliases
│   ├── docker_commands.sh
│   ├── exports.sh        # Environment variables
│   ├── git_commands.sh   # Git helpers + GPG setup
│   ├── modern_tools.sh   # fzf, rg, bat, eza integration
│   ├── paths.sh
│   ├── rails_commands.sh
│   ├── server_commands.sh
│   ├── completion_scripts/
│   └── zsh/
├── Brewfile              # Homebrew packages
├── editorconfig          # Editor settings
├── gitconfig.erb         # Git config (templated)
├── zshrc                 # Main zsh config
└── Rakefile              # Installation tasks
```

## Troubleshooting

### GPG Signing Not Working

```bash
# Check current configuration
check_gpg_signing

# Auto-detect and configure GPG key
setup_gpg_signing_key

# Regenerate gitconfig
cd ~/src/personal/dotfiles && REPLACE_ALL=true rake install
```

### Shell Not Loading Correctly

```bash
# Check for syntax errors
zsh -n ~/.zshrc

# Reload configuration
source ~/.zshrc
# or
reload
```

### Tools Not Found

Make sure Homebrew packages are installed:

```bash
brew bundle --file=~/src/personal/dotfiles/Brewfile
```

## License

See [LICENSE](LICENSE).
