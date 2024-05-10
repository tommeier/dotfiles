# https://medium.com/@Clovis_app/configuration-of-a-beautiful-efficient-terminal-and-prompt-on-osx-in-7-minutes-827c29391961
# brew install git zsh-autocomplete zsh zsh-completions
# install oh-my-zsh: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# install powerlevl10k zsh theme: "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k"
#   - configure: `p10k configure`

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [ -f ~/.localrc ]; then
  source ~/.localrc
fi

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

# Enable gpg signing with gitconfig commit.gpgsign
export GPG_TTY=$(tty)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
