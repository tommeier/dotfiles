#Build path params
export PATH="$HOME/.local/bin:$PATH:/usr/bin"
#Path helper
alias find_dead_path_items="echo $PATH | tr ':' '\n' | xargs ls -ld"
