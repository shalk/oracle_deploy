
cd `dirname $0`

source rac_cfg_extend

su - oracle -c "dbca -silent -deleteDatabase -sourceDB ${oracle_sid_prefix} " 
