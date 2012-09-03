#Auto alias each folder within a passed folder
#eg. generate_alias ~/Development/Projects/
#eg. generate_alias ~/Development/Projects/Clear/

function generate_alias {
FOLDER=$@
echo "Auto alias : $FOLDER"
for f in `ls $FOLDER`
do
  LOWERNAME=`echo $f | tr '[A-Z]' '[a-z]'`
  alias $LOWERNAME="cd $FOLDER$f"
done
}