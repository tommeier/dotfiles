source ~/.bash/aliases
source ~/.bash/aliases_script
source ~/.bash/completions
source ~/.bash/exports
source ~/.bash/paths
source ~/.bash/config
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

alias staging_ci="ssh -p 22022 tom@211.27.76.94"

#Load Boxen
export PATH=$PATH:./node_modules/.bin #Application wide NPM modules
[[ -f /opt/boxen/env.sh ]] && source /opt/boxen/env.sh
export PATH=$PATH:/opt/boxen/homebrew/share/npm/bin #Globally loaded NPM modules

# Android-Boxen
export ANDROID_HOME="/Users/tom/development/adt-bundle-mac-x86_64-20140702/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools"
export ANDROID_PROJECT_HOME="/users/tom/src/company/ferocia/johanna-android"
export ANT_OPTS="-javaagent:$ANDROID_PROJECT_HOME/class.rewriter.jar"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# added by travis gem
[ -f /Users/tom/.travis/travis.sh ] && source /Users/tom/.travis/travis.sh
