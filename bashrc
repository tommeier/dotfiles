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
source ~/.bash/rbenv_commands
#source ~/.bash/rvm_commands
source ~/.bash/log_commands

#publish_to command for Git - see https://github.com/tommeier/bash-publish_to
#enables any command from a git branch, to go to master, get latest, rebase then push to a selected remote

source ~/development/scripts/bash-publish_to/bash_publish_to.sh

# use .localrc for settings specific to one system
if [ -f ~/.localrc ]; then
  source ~/.localrc
fi


