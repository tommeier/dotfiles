source ~/.bash/aliases
source ~/.bash/aliases_script
source ~/.bash/completions
source ~/.bash/exports
source ~/.bash/paths
source ~/.bash/config
source ~/.bash/bash_commands
source ~/.bash/rails_commands
source ~/.bash/git_commands
source ~/.bash/server_commands
source ~/.bash/database_commands
source ~/.bash/log_commands
source ~/.bash/xcode_commands

# use .localrc for settings specific to one system
if [ -f ~/.localrc ]; then
  source ~/.localrc
fi

#Load Boxen
export PATH=$PATH:./node_modules/.bin #Application wide NPM modules
[[ -f /opt/boxen/env.sh ]] && source /opt/boxen/env.sh

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Android Studio for React Native
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# added by travis gem
[ -f /Users/tom/.travis/travis.sh ] && source /Users/tom/.travis/travis.sh
