if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

#1 - Remove duplicates from history
#2 - Increase bash history size
#3 - Apppend at close of session
export HISTCONTROL=erasedups
export HISTSIZE=10000
shopt -s histappend

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
