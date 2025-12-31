# brew install bash-git-prompt
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  # GIT_PROMPT_THEME=Single_line_DarkTom_Custom # custom settings in ~/.git-prompt-colors.sh
  GIT_PROMPT_ONLY_IN_REPO=0

  # Disable - not doing as much kube now
  # # brew install kube-ps1
  # if [ -f "$(brew --prefix)/opt/kube-ps1/share/kube-ps1.sh" ]; then
  #   source "$(brew --prefix)/opt/kube-ps1/share/kube-ps1.sh"
  #   KUBE_PS1_NS_ENABLE="false"
  #   # KUBE_PS1_SYMBOL_USE_IMG="true"
  #   KUBE_PS1_SYMBOL_COLOR="white"
  #   function prompt_callback {
  #     local kube_result=$(kube_ps1)
  #     if [[ "$kube_result" != "" ]]; then
  #       echo '[$(kube_ps1)]'
  #     fi
  #   }
  # else
  #   echo "[dotfiles:prompt.sh] 'brew install kube-ps1' for kube prompt"
  # fi
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
else
  echo "[dotfiles:prompt.sh] 'brew install bash-git-prompt' for git prompt"
fi
