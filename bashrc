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
# source ~/.bash/ci_commands
source ~/.bash/xcode_commands

# use .localrc for settings specific to one system
if [ -f ~/.localrc ]; then
  source ~/.localrc
fi

# Load Ruby
eval "$(rbenv init -)"

#Load Node
eval "$(nodenv init -)"
export PATH=$PATH:./node_modules/.bin #Application wide NPM modules

### Android Studio for React Native
if [ -x /usr/libexec/java_home ]; then
  export JAVA_HOME=`/usr/libexec/java_home`
  export PATH="$JAVA_HOME/bin:$PATH"
fi

if [ -z ${ANDROID_HOME+x} ]; then
  export ANDROID_HOME=$HOME/Library/Android/sdk
  export PATH=$PATH:$ANDROID_HOME/tools
  export PATH=$PATH:$ANDROID_HOME/tools/bin
  export PATH=$PATH:$ANDROID_HOME/platform-tools
fi

# GCloud
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'

## Hack for High Sierra + Ruby with Unicorn
# https://blog.phusion.nl/2017/10/13/why-ruby-app-servers-break-on-macos-high-sierra-and-what-can-be-done-about-it/
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

### Added by IBM Cloud CLI
[ -f /usr/local/Bluemix/bx/bash_autocomplete ] && source /usr/local/Bluemix/bx/bash_autocomplete
