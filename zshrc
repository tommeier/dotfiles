
# Load ASDF (https://github.com/asdf-vm/asdf)
# Location: $(brew --prefix asdf)
. $(brew --prefix asdf)/libexec/asdf.sh

if [ -d $HOME/.asdf/plugins/java/ ]; then
  source $HOME/.asdf/plugins/java/set-java-home.zsh
fi
