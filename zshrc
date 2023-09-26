
# https://medium.com/@Clovis_app/configuration-of-a-beautiful-efficient-terminal-and-prompt-on-osx-in-7-minutes-827c29391961
# brew install git zsh-autocomplete
# brew install zsh zsh-completions
# install oh-my-zsh: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"



eval "$(/opt/homebrew/bin/brew shellenv)"
export BREW_PREFIXED=$(brew --prefix)

source ~/.terminal/aliases.sh
source ~/.terminal/aliases_script.sh
source ~/.terminal/zsh/zsh_commands.sh
source ~/.terminal/zsh/completions.sh
source ~/.terminal/exports.sh
source ~/.terminal/git_commands.sh
source ~/.terminal/log_commands.sh
source ~/.terminal/paths.sh
source ~/.terminal/zsh/prompt.sh
source ~/.terminal/rails_commands.sh
source ~/.terminal/server_commands.sh
source ~/.terminal/xcode_commands.sh

export TERM="xterm-256color"

# Load ASDF (https://github.com/asdf-vm/asdf)
# Location: $(brew --prefix asdf)
. $(brew --prefix asdf)/libexec/asdf.sh

if [ -d $HOME/.asdf/plugins/java/ ]; then
  source $HOME/.asdf/plugins/java/set-java-home.zsh
fi