#Build path params
ORIGINAL_PATH=$PATH
export PATH=$PATH:/usr/bin
export PATH=$PATH:/sbin
export PATH=$PATH:/usr/local/opt/curl/bin
export PATH=$PATH:$ORIGINAL_PATH
export MANPATH="/usr/local/man:/usr/local/git/man:$MANPATH"
#Path helper
alias find_dead_path_items="echo $PATH | tr ':' '\n' | xargs ls -ld"
