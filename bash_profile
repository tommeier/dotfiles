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

#export PATH="$BREW_PREFIXED/opt/openssl@1.1/bin:$PATH"
#export PATH="$BREW_PREFIXED/opt/openssl@3/bin:$PATH"


# Required for M1 to compile postgresql
#export PKG_CONFIG_PATH="$BREW_PREFIXED/opt/openssl@1.1/lib/pkgconfig"
#export LDFLAGS="-L$BREW_PREFIXED/opt/openssl@1.1/lib"
#export CPPFLAGS="-I$BREW_PREFIXED/opt/openssl@1.1/include"

# Required for M1 to compile pg gem
# brew install libpq
#export PATH="$BREW_PREFIXED/opt/libpq/bin:$PATH"
#export PKG_CONFIG_PATH="$BREW_PREFIXED/opt/libpq/bin/pg_config"
