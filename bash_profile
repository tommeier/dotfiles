if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

#Custom Ruby memory for 1.9.3-perf
#export RUBY_HEAP_MIN_SLOTS=1000000
#export RUBY_HEAP_SLOTS_INCREMENT=1000000
#export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
#export RUBY_GC_MALLOC_LIMIT=1000000000
#export RUBY_HEAP_FREE_MIN=500000

#1 - Remove duplicates from history
#2 - Increase bash history size
#3 - Apppend at close of session
export HISTCONTROL=erasedups
export HISTSIZE=10000
shopt -s histappend
