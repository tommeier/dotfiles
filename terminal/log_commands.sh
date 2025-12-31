#Tail all log files in a passed directory
#useful for folders with lots of small 'progress' logs
function tail_all_log_files {
for f in `ls *.log`
do
  tail $f
done
}
