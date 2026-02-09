alias list_free_space="df -h"
alias list_folders_by_size="du -h | sort -rn"

zip_file() {
  gzip --best "$1"
}

function list_largest_files {
  find . -type f -size +10000k -exec ls -lh {} \; | awk '{ print $5 ": " $9 }' | sort -rn
}

function analyse_ssl_certificate {
  openssl x509 -noout -text -in "$1"
}

function find_in_files {
  grep -rF "${1}" . 2>/dev/null
}
