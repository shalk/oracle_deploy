
cd `dirname $0`

source ../../rac.cfg

su - oracle -c "dbca -silent -deleteDatabase -sourceDB ${oracle_sid_prefix} " 
