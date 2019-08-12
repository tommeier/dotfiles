# brew install git bash-completion
if [ -f /usr/local/etc/bash_completion ]; then
  . /usr/local/etc/bash_completion
else
  echo '[dotfiles] Please install bash-completion: brew install git bash bash-completion'
fi

complete -C ~/.bash/completion_scripts/project_completion.rb -o default p
