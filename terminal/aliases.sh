# Project root directories: Edit ~/.terminal/completion_scripts/project_completion_roots

function p {
	# If argument is already a valid directory (e.g., from tab completion), go directly
	if [ -d "$1" ]; then
		cd "$1"
		return
	fi

	local roots_file="$HOME/.terminal/completion_scripts/project_completion_roots"
	[[ -f "$roots_file" ]] || return 0

	# Otherwise, search project roots for a matching project name
	while read line; do
		# Expand ~ to $HOME (tilde expansion doesn't work in variable values)
		case "$line" in
			'~'/*) root="${HOME}${line#\~}" ;;
			*)     root="$line" ;;
		esac

		project_file="${root}${1}"

		if [ -d "$project_file" ]; then
			cd "$project_file"
			return
		fi
	done < "$roots_file"
}

# =============================================================================
# Navigation
# =============================================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Make directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# =============================================================================
# System commands
# =============================================================================
alias cls='tput clear'
alias flushdns='dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias reload="source ~/.zshrc"
alias edit_hostfile='$EDITOR /private/etc/hosts'
alias current_time='echo $(date +%H:%M:%S)'
alias please='sudo $(fc -ln -1)' # sudo last command

# macOS specific
alias o='open .'
alias of='open -a Finder .'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'

# Network utilities
alias ip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'
portused() { lsof -i tcp:"$1" | head -10; }

# =============================================================================
# User commands
# =============================================================================
alias rsync_qnap="$HOME/development/scripts/backup/rsync_backup.sh"
alias killall_ruby='pkill -f ruby'

#Editor
alias m=$EDITOR

# SSH Key removal - Usage: remove_ssh_host 3 (removes line 3)
remove_ssh_host() {
  sed -i '' -e "${1}d" ~/.ssh/known_hosts
}

#alias otp generation for 1password via yubikey
alias 1p="ykman oath code 1p"

# =============================================================================
# Claude Code — account helpers
# =============================================================================
# Work is the default `claude`; personal runs in a cswap session profile in the
# current terminal only, so both work concurrently. claude-swap owns both
# logins, which is what lets CodexBar show usage per account — it shells out to
# `cswap`. The default login can drift (CodexBar's account switch, an unclean
# run), so both helpers restore it before launching. They also run
# claude-swap-repair (dotfiles bin/), which is silent for a healthy account and
# walks through the re-login when cswap reports one dead.
#   claude-swap-repair          check both accounts, repair a broken one
#   cswap list --token-status   token health for every account
#   cswap switch work           restore the default login by hand
_claude_swap_link_plugins() {
  local sessions="$HOME/.claude-swap-backup/sessions" profile
  # cswap mirrors settings / CLAUDE.md / skills / commands into its session
  # profiles, but not the plugin payloads enabledPlugins still points at.
  if [[ -n "$(ls -A "$sessions" 2>/dev/null)" ]]; then
    for profile in "$sessions"/*; do
      [[ -d "$profile" && ! -e "$profile/plugins" ]] &&
        ln -s "$HOME/.claude/plugins" "$profile/plugins"
    done
  fi
}

# Work must stay the default login. Only the default login's token is refreshed
# in place by Claude Code where cswap/CodexBar can read it; an account run
# through `cswap run` keeps its own token generation in the session profile, and
# running the default account that way kills its stored backup within a refresh
# cycle (CodexBar: "Re-login required").
_claude_default_is_work() {
  # ~/.claude.json names the account; cswap status catches a keychain token
  # that belongs to another account even when ~/.claude.json still says work.
  local work_email
  work_email="$(jq -r '[.accounts[] | select(.alias == "work") | .email][0] // empty' \
    "$HOME/.claude-swap-backup/sequence.json" 2>/dev/null)"
  if [[ -n "$work_email" &&
    "$(jq -r '.oauthAccount.emailAddress // empty' "$HOME/.claude.json" 2>/dev/null)" == "$work_email" ]] &&
    ! command cswap status 2>/dev/null | grep -q 'belongs to another account'; then
    return 0
  fi
  echo "claude: default login is not work; switching" >&2
  command cswap switch work
}

claude-personal() {
  _claude_default_is_work || return 1
  claude-swap-repair --quiet personal || return 1
  _claude_swap_link_plugins
  command cswap run personal --share-history -- "$@"
}

claude-work() {
  _claude_default_is_work || return 1
  claude-swap-repair --quiet work || return 1
  command claude "$@"
}
