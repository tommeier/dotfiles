
alias list_free_space="df -h"
alias list_folders_by_size="du -h | sort -n"
alias list_specific_root_folders_by_size="du -ks /folder_name/* | sort -n"

alias list_inodes_ufs="df -F ufs -i"
alias list_inodes_ext3="df -F ext3 -i"
alias list_inodes_from_folder="ls -i /"

alias zip_file="gzip --best $1 > $1.gz"
alias mail_attachment="echo -e 'Email attachment of $1' | mutt -s 'Emailing attachment : $1' -a $1 'tom@venombytes.com'"

function list_largest_files {
 #note - Ubuntu file name $8, mac osx : $9
 find . -type f -size +10000k -exec ls -lh {} \; | awk '{ print $5 ": " $9 }' | sort -rn
}

alias start_nginx="sudo /etc/init.d/nginx start"
alias stop_nginx="/etc/init.d/nginx stop"

function analyse_ssl_certificate {
  openssl x509 -noout -text -in $1
}

function find_in_files {
  grep -r "${1}" * 2> /dev/null
}

function zip_and_mail_attachment {
  zipped="$1.gz"
  gzip --best -f $1 > $zipped
  echo -e "Email attachment of ${1} zipped" | mutt -s "Emailing attachment : ${1}" -a $zipped 'tom@venombytes.com'
}
