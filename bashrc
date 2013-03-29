source ~/.bash/aliases
source ~/.bash/aliases_script
source ~/.bash/completions
source ~/.bash/exports
source ~/.bash/paths
source ~/.bash/config
source ~/.bash/rails_commands
source ~/.bash/git_commands
source ~/.bash/server_commands
source ~/.bash/database_commands
source ~/.bash/log_commands

#source ~/.bash/rbenv_commands #Disabled for Boxen
#source ~/.bash/rvm_commands #Deprecated for RBEnv

# use .localrc for settings specific to one system
if [ -f ~/.localrc ]; then
  source ~/.localrc
fi

alias staging_ci="ssh -p 22022 evan@ci.ferocia.com.au"

#Ruby memory tweaks for 1.9.3
export RUBY_HEAP_MIN_SLOTS=1000000
export RUBY_HEAP_SLOTS_INCREMENT=1000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_GC_MALLOC_LIMIT=1000000000
export RUBY_HEAP_FREE_MIN=500000

#Load Boxen
[ -f /opt/boxen/env.sh ] && source /opt/boxen/env.sh
