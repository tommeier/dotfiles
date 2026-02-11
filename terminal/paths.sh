#Build path params
export PATH="$HOME/.local/bin:$PATH:/usr/bin"

# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
#Path helper
alias find_dead_path_items='echo "$PATH" | tr ":" "\n" | xargs ls -ld'
