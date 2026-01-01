# Project root directories: Edit ~/.terminal/completion_scripts/project_completion_roots

function p {
	# If argument is already a valid directory (e.g., from tab completion), go directly
	if [ -d "$1" ]; then
		cd "$1"
		return
	fi

	# Otherwise, search project roots for a matching project name
	while read line; do
		# Expand ~ to $HOME (tilde expansion doesn't work in variable values)
		case "$line" in
			'~'/*) root="${HOME}${line#\~}" ;;
			*)     root="$line" ;;
		esac

		project_file="${root}${1}"

		if [ -d "$project_file" ]; then
			cd "$project_file"
			return
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
alias rsync_qnap="$HOME/development/scripts/backup/rsync_backup.sh"
alias killall_ruby="ps aux | grep ruby | grep -v grep | awk '{print $2}' | xargs kill"

#Editor
alias m=$EDITOR

# SSH Key removal - Usage: remove_ssh_host 3 (removes line 3)
remove_ssh_host() {
  sed -i '' -e "${1}d" ~/.ssh/known_hosts
}

#alias otp generation for 1password via yubikey
alias 1p="ykman oath code 1p"
