# brew install git zsh-autocomplete
# install oh-my-zsh: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


if [ -f "$BREW_PREFIXED/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]; then
    source $BREW_PREFIXED/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
else
  echo '[dotfiles] Please install zsh-completions: brew install git zsh zsh-autocomplete'
fi

+autocomplete:recent-directories() {
  typeset -ga reply=( $( ruby ~/.terminal/zsh/zsh_recent_directories.rb ) )
}
