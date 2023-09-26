#!/bin/bash -e

# brew install zsh-git-prompt
if [ -f "$BREW_PREFIXED/opt/zsh-git-prompt/zshrc.sh" ]; then
  source "$BREW_PREFIXED/opt/zsh-git-prompt/zshrc.sh"
  PROMPT='%B%m%~%b$(git_super_status) %# '
else
  echo "[dotfiles:prompt.sh] 'brew install bash-git-prompt' for git prompt"
fi
