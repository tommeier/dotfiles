# ==============================================================================
# Mise shims (fallback for non-interactive shells and newly-installed tools)
# ==============================================================================
# `mise activate zsh` in .zshrc prepends direct install paths that take
# priority over shims in interactive shells. Shims cover scripts, subprocesses,
# and tools installed mid-session before hooks re-evaluate.
export PATH="$HOME/.local/share/mise/shims:$PATH"

if [ -f ~/.zshrc ]; then
  source ~/.zshrc
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
