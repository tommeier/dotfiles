# ==============================================================================
# GPG Configuration
# ==============================================================================
# Enable gpg signing with gitconfig commit.gpgsign
# Note - _must_ be above powerlevel10k instant prompt init
# https://unix.stackexchange.com/a/608921
export GPG_TTY=$(tty)

# ==============================================================================
# History Configuration
# ==============================================================================
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history

setopt HIST_IGNORE_DUPS       # Ignore duplicate commands
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries
setopt HIST_IGNORE_SPACE      # Commands starting with space are not saved
setopt HIST_VERIFY            # Don't execute expanded history immediately
setopt INC_APPEND_HISTORY     # Append to history as commands are entered
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks

# ==============================================================================
# Zsh Usability Options
# ==============================================================================
setopt AUTO_CD                # cd by typing directory name
setopt AUTO_PUSHD             # Push directories onto stack
setopt PUSHD_IGNORE_DUPS      # No duplicate directories in stack
setopt CORRECT                # Spell correction for commands
setopt COMPLETE_IN_WORD       # Complete from both ends
setopt EXTENDED_GLOB          # Extended globbing patterns
setopt NO_BEEP                # Disable terminal beep

# ==============================================================================
# Powerlevel10k Configuration
# ==============================================================================
# https://medium.com/@Clovis_app/configuration-of-a-beautiful-efficient-terminal-and-prompt-on-osx-in-7-minutes-827c29391961
# brew install git zsh-autocomplete zsh zsh-completions
# install oh-my-zsh: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# install powerlevl10k zsh theme: "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k"
#   - configure: `p10k configure`

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# ==============================================================================
# Local Configuration
# ==============================================================================
if [ -f ~/.localrc ]; then
  source ~/.localrc
fi

# ==============================================================================
# Homebrew
# ==============================================================================
export BREW_BIN='/opt/homebrew/bin/brew'
[ -x '/usr/local/bin/brew' ] && export BREW_BIN='/usr/local/bin/brew'

if [ -x "$BREW_BIN" ]; then
  eval "$($BREW_BIN shellenv)"
  export BREW_PREFIXED=$(brew --prefix)
fi

# ==============================================================================
# Shell Configuration Sources
# ==============================================================================
source ~/.terminal/aliases.sh
source ~/.terminal/aliases_script.sh
source ~/.terminal/docker_commands.sh
source ~/.terminal/exports.sh
source ~/.terminal/git_commands.sh
source ~/.terminal/log_commands.sh
source ~/.terminal/paths.sh
source ~/.terminal/zsh/theme.sh
source ~/.terminal/rails_commands.sh
source ~/.terminal/server_commands.sh
source ~/.terminal/xcode_commands.sh
source ~/.terminal/zsh/zsh_commands.sh
source ~/.terminal/zsh/completions.sh
source ~/.terminal/modern_tools.sh

export TERM="xterm-256color"

# ==============================================================================
# Mise (Runtime Version Manager)
# ==============================================================================
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# ==============================================================================
# OrbStack Integration
# ==============================================================================
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# ==============================================================================
# Environment Variables
# ==============================================================================
# Used in computology/packagecloud.io project
export SEED_ENRICHED=set

# ==============================================================================
# GPG Signing Check
# ==============================================================================
# Warn on shell startup if GPG signing is misconfigured
check_gpg_signing

# ==============================================================================
# Prompt Customization
# ==============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
