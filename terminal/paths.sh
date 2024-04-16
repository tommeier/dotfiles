#!/bin/bash -e

#Build path params
export PATH=$PATH:/usr/bin
#Path helper
alias find_dead_path_items="echo $PATH | tr ':' '\n' | xargs ls -ld"
