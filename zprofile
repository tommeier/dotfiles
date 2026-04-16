# ==============================================================================
# Mise shims (fallback for non-interactive contexts)
# ==============================================================================
# For interactive shells, .zshrc handles shims via precmd/chpwd hooks that
# re-inject after each mise hook-env PATH rebuild. This line covers
# non-interactive login shells that source .zprofile but skip .zshrc
# (cron jobs, scripts invoked via `zsh -l`).
export PATH="$HOME/.local/share/mise/shims:$PATH"

if [ -f ~/.zshrc ]; then
  source ~/.zshrc
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
