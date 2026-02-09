#Tail all log files in a passed directory
function tail_all_log_files {
  for f in *.log; do
    [[ -f "$f" ]] && tail "$f"
  done
}
