# Auto-create aliases for each folder within a given directory
# Usage: generate_alias ~/src/personal/

function generate_alias {
FOLDER=$@
echo "Auto alias : $FOLDER"
for f in `ls $FOLDER`
do
  LOWERNAME=`echo $f | tr '[A-Z]' '[a-z]'`
  alias $LOWERNAME="cd $FOLDER$f"
done
}
