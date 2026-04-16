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
# Private & Local Configuration
# ==============================================================================
# ~/.privaterc - synced private config (from private-dotfiles repo)
# ~/.localrc   - machine-specific config (not tracked in git)
[[ -f ~/.privaterc ]] && source ~/.privaterc
[[ -f ~/.localrc ]] && source ~/.localrc

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
# mise activate and shims are mutually exclusive — hook-env strips the shims
# dir on every PATH rebuild. We use activate (needed for [env] support) and
# re-inject shims as a low-priority fallback via precmd/chpwd hooks that run
# AFTER mise's own hooks. This lets tools scoped to other directories (e.g.
# gke-gcloud-auth-plugin from infra/.mise.toml) resolve via shim when cwd is
# elsewhere — kubectl needs this for GKE auth regardless of working directory.
if command -v mise &>/dev/null && [[ -z "$__MISE_ACTIVATED" ]]; then
  eval "$(mise activate zsh)"
  _mise_shims_fallback() {
    [[ ":$PATH:" != *":$HOME/.local/share/mise/shims:"* ]] && \
      export PATH="$PATH:$HOME/.local/share/mise/shims"
  }
  precmd_functions+=(_mise_shims_fallback)
  chpwd_functions+=(_mise_shims_fallback)
  __MISE_ACTIVATED=1
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

# ==============================================================================
# zoxide - Smarter cd command
# ==============================================================================
# Must be initialized AFTER mise, orbstack, and p10k to avoid hook conflicts.
# Guard prevents double init (.zprofile sources .zshrc, then zsh sources it again).
# _ZO_DOCTOR=0 silences a false positive — init IS last, doctor gets confused by
# the double-source path.
#
# --cmd cd: replaces `cd` with a function that does `builtin cd` when the arg
# is an existing directory, falls back to zoxide frecent matching otherwise.
# This avoids the footgun where `cd relative/path` jumps to a different
# checkout because zoxide ranked it higher. Also provides `cdi` for interactive.
if command -v zoxide >/dev/null 2>&1 && [[ -z "$__ZOXIDE_INITIALIZED" ]]; then
  export _ZO_DOCTOR=0
  eval "$(zoxide init zsh --cmd cd)"
  __ZOXIDE_INITIALIZED=1
fi
