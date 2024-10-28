# brew install git zsh-autocomplete
# install oh-my-zsh: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# zsh-autocomplete has broken the usage of recent-directories:
# see https://github.com/marlonrichert/zsh-autocomplete/issues/752
# in commit https://github.com/marlonrichert/zsh-autocomplete/commit/a8fdd21227d76e077ad034c6ff7108ae44bd57a7#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5L220
# To repair I've needed to rollback to previous version via
# brew uninstall zsh-autocomplete
# brew tap homebrew/core --force
# brew extract --version=23.07.13 zsh-autocomplete $USER/local-zsh-autocomplete
# brew install zsh-autocomplete@23.07.13
# brew pin zsh-autocomplete@23.07.13
# If this is ever changed - remember to cleanup by:
# brew tap remove $USER/local-zsh-autocomplete
# brew tap remove homebrew/core (or rm -rf /opt/homebrew/Library/Taps/homebrew/homebrew-core)
# if [ -f "$BREW_PREFIXED/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]; then
#     source $BREW_PREFIXED/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# else
#   echo '[dotfiles] Please install zsh-completions: brew install git zsh zsh-autocomplete'
# fi

if [ -f "$BREW_PREFIXED/share/zsh-autocomplete@23.07.13/zsh-autocomplete.plugin.zsh" ]; then
    source $BREW_PREFIXED/share/zsh-autocomplete@23.07.13/zsh-autocomplete.plugin.zsh
else
  echo '[dotfiles] Please install zsh-completions: brew install git zsh zsh-autocomplete'
fi

+autocomplete:recent-directories() {
  typeset -ga reply=( $( ruby ~/.terminal/zsh/zsh_recent_directories.rb ) )
}
