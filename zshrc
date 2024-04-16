
# https://medium.com/@Clovis_app/configuration-of-a-beautiful-efficient-terminal-and-prompt-on-osx-in-7-minutes-827c29391961
# brew install git zsh-autocomplete zsh zsh-completions
# install oh-my-zsh: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# install powerlevl9k zsh theme: "git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k"

export BREW_BIN='/opt/homebrew/bin/brew'
[ -f '/usr/local/bin/brew' ] && export BREW_BIN='/usr/local/bin/brew'
eval "$($BREW_BIN shellenv)"
export BREW_PREFIXED=$(brew --prefix)

source ~/.terminal/aliases.sh
source ~/.terminal/aliases_script.sh
source ~/.terminal/docker_commands.sh
source ~/.terminal/exports.sh
source ~/.terminal/git_commands.sh
source ~/.terminal/log_commands.sh
source ~/.terminal/paths.sh
source ~/.terminal/zsh/theme.sh
source ~/.terminal/rails_commands.sh
source ~/.terminal/server_commands.sh
source ~/.terminal/xcode_commands.sh
source ~/.terminal/zsh/zsh_commands.sh
source ~/.terminal/zsh/completions.sh

export TERM="xterm-256color"

# Load ASDF (https://github.com/asdf-vm/asdf)
# Location: $(brew --prefix asdf)
# . $(brew --prefix asdf)/libexec/asdf.sh

eval "$(rbenv init -)" # Ruby

eval "$(nodenv init -)" # Node

if command -v pyenv 1>/dev/null 2>&1; then # Python
  eval "$(pyenv init -)"
fi

# if [ -d $HOME/.asdf/plugins/java/ ]; then
#   source $HOME/.asdf/plugins/java/set-java-home.zsh
# fi

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Used in computology/packagecloud.io project
export SEED_ENRICHED=set
