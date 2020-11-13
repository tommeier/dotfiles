source ~/.bash/aliases.sh
source ~/.bash/aliases_script.sh
source ~/.bash/bash_commands.sh
source ~/.bash/completions.sh
source ~/.bash/exports.sh
source ~/.bash/git_commands.sh
source ~/.bash/log_commands.sh
source ~/.bash/paths.sh
source ~/.bash/prompt.sh
source ~/.bash/rails_commands.sh
source ~/.bash/server_commands.sh
source ~/.bash/xcode_commands.sh

# use .localrc for settings specific to one system
if [ -f ~/.localrc ]; then
  source ~/.localrc
fi

# Homebrew bin locations
export PATH="/usr/local/sbin:$PATH"

# Ruby via Rbenv
eval "$(rbenv init -)"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"

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
  export ANDROID_SDK=$ANDROID_HOME
  export PATH=$ANDROID_HOME/emulator:$PATH
  export PATH=$ANDROID_HOME/tools:$PATH
  export PATH=$ANDROID_HOME/tools/bin:$PATH
  export PATH=$ANDROID_HOME/platform-tools:$PATH
fi

# GCloud (note python 3.9 fails)
export CLOUDSDK_PYTHON="/usr/local/opt/python@3.8/libexec/bin/python"
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
