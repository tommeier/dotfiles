#!/bin/bash -e

#If you want more project root directories : Update /bash/completion_scripts/project_completion_roots

function p {
	#Note - Must not use symlinked folders like ~/../.., must be full location /users/someone/work/ etc
	#TODO : Append trailing slash if missing, and auto convert symlinked folders (hint -L)
	while read line; do
		project_file="${line}${1}";
		if [ -d $project_file ]; then
			cd $project_file;
			break;
		fi
	done < ~/.terminal/completion_scripts/project_completion_roots
}

#System commands
alias cls='tput clear'
alias flushdns='dscacheutil -flushcache'
alias reload="source ~/.zshrc"
alias edit_hostfile="$EDITOR /private/etc/hosts"
alias current_time='echo $(date +%H:%M:%S)'
alias please='sudo $(fc -ln -1)' # sudo last command

#User commands
alias rsync_qnap="/users/tom/development/scripts/backup/rsync_backup.sh"
alias killall_ruby="ps aux | grep ruby | grep -v grep | awk '{print $2}' | xargs kill"

#Editor
alias m=$EDITOR

# SSH Key removal
alias remove_ssh_host="sed -i'' -e '$1 d' ~/.ssh/known_hosts"

#alias otp generation for 1password via yubikey
alias 1p="ykman oath code 1p"
