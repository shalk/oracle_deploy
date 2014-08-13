
cd `dirname $0`

source rac_cfg_extend
source logging.sh

ora_log "start dbca silent installment "
su - oracle -c " dbca  -silent  -createDatabase -templateName '${oracle_oracle_home}/assistants/dbca/templates/General_Purpose.dbc' -gdbName $oracle_sid_prefix  -sid $oracle_sid_prefix  -sysPassword $dbca_sys_passwd -systemPassword  $dbca_system_passwd -storageType ASM  -diskGroupName $dbca_disk_groupname  -nodelist $dbca_nodelist  -characterSet $dbca_characterset -nationalCharacterSet $dbca_national_characterset   -asmSysPassword $grid_sysasm_passwd " 

ora_log "finish dbca silent installment "
