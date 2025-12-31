# Dotfiles

Personal configuration files for macOS with zsh, oh-my-zsh, and powerlevel10k.

## Prerequisites

Install these before running the dotfiles:

```bash
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Core dependencies
brew install git zsh zsh-autocomplete zsh-completions

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Mise (runtime version manager)
brew install mise
```

## Installation

```bash
git clone git@github.com:tommeier/dotfiles.git ~/src/personal/dotfiles
cd ~/src/personal/dotfiles
REPLACE_ALL=true rake install
```

Without `REPLACE_ALL=true`, you'll be prompted for each existing file.

## Features

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

- `sup` / `startup` — Fetch all remotes, prune branches, update default branch, clean merged local branches
- `remote_sup` — Same as above, plus removes merged remote branches
- `git_default_branch` — Get the default branch name
- `analyse_remote_branches` — Show unmerged commits on remote branches

### Other Aliases

- `reload` — Reload zsh configuration
- `flushdns` — Flush DNS cache
- `please` — Re-run last command with sudo
- `m` — Open editor (VSCode)

## Customization

### Machine-Specific Configuration

Create `~/.localrc` for settings specific to one machine. This file is sourced automatically and is not tracked in git. Use it for:

- Private environment variables
- Work-specific configurations
- API tokens and credentials

### Project Roots

Edit `terminal/completion_scripts/project_completion_roots` to add directories for `p` command completion.

## Directory Structure

```
├── bin/                  # Custom scripts added to PATH
├── terminal/
│   ├── aliases.sh        # Shell aliases
│   ├── git_commands.sh   # Git helper functions
│   ├── exports.sh        # Environment variables
│   ├── paths.sh          # PATH configuration
│   ├── completion_scripts/
│   │   └── project_completion_roots
│   └── zsh/
│       ├── completions.sh
│       └── theme.sh      # Powerlevel10k/oh-my-zsh setup
├── zshrc                 # Main zsh config
├── zprofile              # zsh profile
├── gitconfig.erb         # Git config (templated)
├── irbrc                 # Ruby IRB config
└── Rakefile              # Installation tasks
```

## License

See [LICENSE](LICENSE).
