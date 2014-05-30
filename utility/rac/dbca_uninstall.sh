
cd `dirname $0`

source ../../o.conf

su - oracle -c "dbca -silent -deleteDatabase -sourceDB ${oracle_sid_prefix} " 
