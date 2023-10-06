# Homebrew bin locations
export PATH="/opt/homebrew/bin:$PATH"
export BREW_PREFIXED=$(brew --prefix)

source ~/.terminal/aliases.sh
source ~/.terminal/aliases_script.sh
source ~/.terminal/docker_commands.sh
source ~/.terminal/exports.sh
source ~/.terminal/git_commands.sh
source ~/.terminal/log_commands.sh
source ~/.terminal/paths.sh
source ~/.terminal/bash/prompt.sh
source ~/.terminal/rails_commands.sh
source ~/.terminal/server_commands.sh
source ~/.terminal/xcode_commands.sh
source ~/.terminal/bash/bash_commands.sh
source ~/.terminal/bash/completions.sh

export TERM="xterm-256color"

# use .localrc for settings specific to one system
if [ -f ~/.localrc ]; then
  source ~/.localrc
fi

# Load ASDF (https://github.com/asdf-vm/asdf)
# Location: $(brew --prefix asdf)
# . $(brew --prefix asdf)/libexec/asdf.sh

# if [ -d $HOME/.asdf/plugins/java/ ]; then
#   source $HOME/.asdf/plugins/java/set-java-home.bash
#   #source $HOME/.asdf/plugins/java/set-java-home.zsh
# fi

# Ruby via Rbenv (deprecated - use asdf)
eval "$(rbenv init -)"

# Node
eval "$(nodenv init -)"
export PATH=$PATH:./node_modules/.bin #Application wide NPM modules
# Yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

### Android Studio for React Native
if [ -x /usr/libexec/java_home ]; then
  export JAVA_HOME=`/usr/libexec/java_home -v 15`
  if [[ "$JAVA_HOME" != "" ]]; then
    export PATH=$JAVA_HOME/bin:$PATH
  fi
fi

if [ -z ${ANDROID_HOME+x} ]; then
  export ANDROID_HOME=$HOME/Library/Android/sdk
  export PATH=$ANDROID_HOME/emulator:$PATH
  export PATH=$ANDROID_HOME/tools:$PATH
  export PATH=$ANDROID_HOME/tools/bin:$PATH
  export PATH=$ANDROID_HOME/platform-tools:$PATH
  export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
fi

# Gcloud SDK /Kube
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

source "$BREW_PREFIXED/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
source "$BREW_PREFIXED/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
