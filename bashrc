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

# Load ASDF (https://github.com/asdf-vm/asdf)
# Location: $(brew --prefix asdf)
. /usr/local/opt/asdf/asdf.sh
. /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash

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

if [ -z ${ANDROID_SDK_ROOT+x} ]; then
  export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
  export PATH=$ANDROID_SDK_ROOT/emulator:$PATH
  export PATH=$ANDROID_SDK_ROOT/tools:$PATH
  export PATH=$ANDROID_SDK_ROOT/tools/bin:$PATH
  export PATH=$ANDROID_SDK_ROOT/platform-tools:$PATH
fi

# Gcloud SDK
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
