#Build path params
export PATH=$PATH:/usr/bin
export PATH=$PATH:/sbin
export PATH=$PATH:$BREW_PREFIXED/opt/curl/bin
#Path helper
alias find_dead_path_items="echo $PATH | tr ':' '\n' | xargs ls -ld"
