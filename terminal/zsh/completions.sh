# brew install git zsh-autocomplete
# install oh-my-zsh: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if [ -f "$BREW_PREFIXED/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]; then
    source "$BREW_PREFIXED/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
else
  echo '[dotfiles] Please install zsh-completions: brew install git zsh zsh-autocomplete'
fi

# https://github.com/marlonrichert/zsh-autocomplete/issues/752
zstyle -e ':completion:*:directories' fake '[[ -z $PREFIX$SUFFIX || -d $PREFIX$SUFFIX ]] || +autocomplete:recent-directories'
zstyle ':completion:*:directories' sort no

+autocomplete:recent-directories() {
  typeset -ga reply=( $( ruby $HOME/.terminal/zsh/zsh_recent_directories.rb ) )
}
