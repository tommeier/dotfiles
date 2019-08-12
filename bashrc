source ~/.bash/aliases.sh
source ~/.bash/aliases_script.sh
source ~/.bash/bash_commands.sh
source ~/.bash/completions.sh
source ~/.bash/exports.sh
source ~/.bash/git_commands.sh
source ~/.bash/log_commands.sh
source ~/.bash/paths.sh
source ~/.bash/rails_commands.sh
source ~/.bash/server_commands.sh
source ~/.bash/xcode_commands.sh

# use .localrc for settings specific to one system
if [ -f ~/.localrc ]; then
  source ~/.localrc
fi

# Ruby via Rbenv
eval "$(rbenv init -)"

# Node
eval "$(nodenv init -)"
export PATH=$PATH:./node_modules/.bin #Application wide NPM modules
# Yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

### Android Studio for React Native
if [ -x /usr/libexec/java_home ]; then
  export JAVA_HOME=`/usr/libexec/java_home`
  export PATH="$JAVA_HOME/bin:$PATH"
fi

if [ -z ${ANDROID_HOME+x} ]; then
  export ANDROID_HOME=$HOME/Library/Android/sdk
  export PATH=$ANDROID_HOME/tools:$PATH
  export PATH=$ANDROID_HOME/tools/bin:$PATH
  export PATH=$ANDROID_HOME/platform-tools:$PATH
fi

# GCloud
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'
