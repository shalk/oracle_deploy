#!/bin/bash
cd `dirname $0`


# setup parameter
source ../../rac.cfg
oracle_base_base=`dirname  $oracle_oracle_base `
source logging.sh


#create ORACLE_HOME dir
ssh rac2 " su - oracle -c ' mkdir \$ORACLE_HOME -p ' "
ssh rac1 " su - oracle -c ' mkdir \$ORACLE_HOME -p ' "
#prepare software

 [ -f ${software_path}/${oracle_softname1} ] || exit 1 
 [ -f ${software_path}/${oracle_softname2} ] || exit 1 
chmod 777 ${software_path}/${oracle_softname1} 
chmod 777 ${software_path}/${oracle_softname2} 

unzip_oracle_software(){
ora_log "unzip oracle database software "
su - oracle  -c " unzip -o ${software_path}/${oracle_softname1}  -d /home/oracle >/dev/null"
su - oracle  -c " unzip -o ${software_path}/${oracle_softname2}  -d /home/oracle >/dev/null"
ora_log "unzip oracle database software finish"
}
# prepare rsp file
prepare_oracle_rsp_file(){
touch $oracle_rsp_file
> $oracle_rsp_file
cat >> $oracle_rsp_file <<EOF 
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=${oracle_db_hostname}
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=${oracle_base_base}/oraInventory
SELECTED_LANGUAGES=en
ORACLE_HOME=${oracle_oracle_home}
ORACLE_BASE=${oracle_oracle_base}
oracle.install.db.InstallEdition=EE
oracle.install.db.EEOptionsSelection=false
oracle.install.db.optionalComponents=
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=oper
oracle.install.db.CLUSTER_NODES=${oracle_db_clusternode}
oracle.install.db.isRACOneInstall=false
oracle.install.db.racOneServiceName=
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=
oracle.install.db.config.starterdb.SID=
oracle.install.db.config.starterdb.characterSet=
oracle.install.db.config.starterdb.memoryOption=false
oracle.install.db.config.starterdb.memoryLimit=
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.enableSecuritySettings=true
oracle.install.db.config.starterdb.password.ALL=
oracle.install.db.config.starterdb.password.SYS=
oracle.install.db.config.starterdb.password.SYSTEM=
oracle.install.db.config.starterdb.password.SYSMAN=
oracle.install.db.config.starterdb.password.DBSNMP=
oracle.install.db.config.starterdb.control=DB_CONTROL
oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=
oracle.install.db.config.starterdb.automatedBackup.enable=false
oracle.install.db.config.starterdb.automatedBackup.osuid=
oracle.install.db.config.starterdb.automatedBackup.ospwd=
oracle.install.db.config.starterdb.storageType=
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
oracle.install.db.config.asm.diskGroup=
oracle.install.db.config.asm.ASMSNMPPassword=
MYORACLESUPPORT_USERNAME=
MYORACLESUPPORT_PASSWORD=
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
PROXY_REALM=
COLLECTOR_SUPPORTHUB_URL=
oracle.installer.autoupdates.option=SKIP_UPDATES
oracle.installer.autoupdates.downloadUpdatesLoc=
AUTOUPDATES_MYORACLESUPPORT_USERNAME=
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=
EOF
}

db_silent_install(){
ora_log "execute db silent installment"
rm -rf ${oracle_base_base}/oraInventory/logs/installActions*  2>/dev/null
su - oracle -c "cd database; ./runInstaller -ignorePrereq -silent -responseFile ${oracle_rsp_file}"

}

# pause
check_db_finish(){
    ora_log "waiting db silent installment in background"
    sleep 20
    while true
    do
        if grep "Unloading Setup Driver" ${oracle_base_base}/oraInventory/logs/installActions*   >/dev/null 2>&1
        then
            break
        fi
        for errfile in `ls  ${oracle_base_base}/oraInventory/logs/*.err `
        do
            if [ -s $errfile  ]   
            then 
                echo "[ERROR] error in log " ${oracle_base_base}/oraInventory/logs/*.err 
                return 1
            fi
        done
        sleep 20
    done
    ora_log "db installment finish"
    return 0
}
after_db_silent_install(){
ssh rac1 "$oracle_oracle_home/root.sh"
ssh rac2 "$oracle_oracle_home/root.sh"
}

unzip_oracle_software
prepare_oracle_rsp_file
db_silent_install
if check_db_finish
then 
     after_db_silent_install
fi

