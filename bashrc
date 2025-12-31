# =============================================================================
# Homebrew
# =============================================================================
export PATH="/opt/homebrew/bin:$PATH"
export BREW_PREFIXED=$(brew --prefix)

# =============================================================================
# Terminal Configuration
# =============================================================================
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

# =============================================================================
# Local Configuration
# =============================================================================
if [ -f ~/.localrc ]; then
  source ~/.localrc
fi

# =============================================================================
# Mise (Runtime Version Manager)
# =============================================================================
if command -v mise &> /dev/null; then
  eval "$(mise activate bash)"
fi

# =============================================================================
# Android Studio / React Native
# =============================================================================
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

# =============================================================================
# Google Cloud SDK / Kubernetes
# =============================================================================
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

if [ -f "$BREW_PREFIXED/opt/google-cloud-sdk/path.bash.inc" ]; then
  source "$BREW_PREFIXED/opt/google-cloud-sdk/path.bash.inc"
fi

if [ -f "$BREW_PREFIXED/opt/google-cloud-sdk/completion.bash.inc" ]; then
  source "$BREW_PREFIXED/opt/google-cloud-sdk/completion.bash.inc"
fi
