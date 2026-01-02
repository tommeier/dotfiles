# =============================================================================
# Modern CLI Tool Integration
# =============================================================================
# Integrates modern replacements: fzf, ripgrep, fd, bat, eza, zoxide, delta
# Install with: brew bundle --file=~/src/personal/dotfiles/Brewfile

# =============================================================================
# FZF - Fuzzy Finder
# =============================================================================
if command -v fzf >/dev/null 2>&1; then
  # Source fzf keybindings and completion
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # Use ripgrep for fzf if available
  if command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git" 2>/dev/null'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  elif command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi

  # Use bat for fzf preview if available
  if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
  fi

  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

  # fzf + git integration
  fzf_git_log() {
    git log --oneline --decorate --color=always | fzf --ansi --preview 'git show --color=always {1}'
  }
  alias glog='fzf_git_log'

  # fzf + git branches
  fzf_git_branch() {
    local branch
    branch=$(git branch -a --color=always | fzf --ansi | sed 's/^[ *]*//' | sed 's|remotes/origin/||')
    if [[ -n "$branch" ]]; then
      git checkout "$branch"
    fi
  }
  alias gcob='fzf_git_branch'
fi

# =============================================================================
# Ripgrep (rg) - Fast grep replacement
# =============================================================================
if command -v rg >/dev/null 2>&1; then
  alias rg='rg --hidden --glob "!.git" --smart-case'
  alias rgi='rg --hidden --glob "!.git" --ignore-case'
  alias rgf='rg --files-with-matches'
fi

# =============================================================================
# fd - Fast find replacement
# =============================================================================
if command -v fd >/dev/null 2>&1; then
  alias fd='fd --hidden --exclude .git'
fi

# =============================================================================
# bat - Better cat with syntax highlighting
# =============================================================================
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --style=plain'
  alias catn='bat --paging=never'
  alias catp='bat'

  # Use bat as man pager
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"

  # bat help for any command
  help() {
    "$@" --help 2>&1 | bat --plain --language=help
  }
fi

# =============================================================================
# eza - Better ls replacement (formerly exa)
# =============================================================================
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first --git'
  alias la='eza -la --icons --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons'
  alias lta='eza --tree --level=2 --icons -a'
elif command -v exa >/dev/null 2>&1; then
  alias ls='exa --icons --group-directories-first'
  alias ll='exa -l --icons --group-directories-first --git'
  alias la='exa -la --icons --group-directories-first --git'
  alias lt='exa --tree --level=2 --icons'
else
  # Fallback to standard ls with colors
  alias ll='ls -lah'
  alias la='ls -A'
fi

# =============================================================================
# zoxide - Smarter cd command
# =============================================================================
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
  alias cdi='zi'  # Interactive selection
fi

# =============================================================================
# git-delta - Better git diff
# =============================================================================
# Note: delta is configured in gitconfig, but we can add some aliases
if command -v delta >/dev/null 2>&1; then
  alias diff='delta'
fi

# =============================================================================
# lazygit - Terminal UI for git
# =============================================================================
if command -v lazygit >/dev/null 2>&1; then
  alias lg='lazygit'
fi

# =============================================================================
# GitHub CLI (gh)
# =============================================================================
if command -v gh >/dev/null 2>&1; then
  alias ghpr='gh pr create'
  alias ghprv='gh pr view --web'
  alias ghprl='gh pr list'
  alias ghprc='gh pr checkout'
  alias ghprm='gh pr merge'
  alias ghis='gh issue create'
  alias ghisv='gh issue view --web'
  alias ghisl='gh issue list'
  alias ghrepo='gh repo view --web'
fi

# =============================================================================
# htop - Better top
# =============================================================================
if command -v htop >/dev/null 2>&1; then
  alias top='htop'
fi

# =============================================================================
# tldr - Simplified man pages
# =============================================================================
if command -v tldr >/dev/null 2>&1; then
  alias tldrf='tldr --list | fzf --preview "tldr {1}" | xargs tldr'
fi
