
cd `dirname $0`


# setup parameter
source ../../o.conf
oracle_base_base=`dirname  $oracle_oracle_base `



#creake ORACLE_HOME dir
ssh rac2 " su - oracle -c ' mkdir \$ORACLE_HOME -p ' "
ssh rac1 " su - oracle -c ' mkdir \$ORACLE_HOME -p ' "
#prepare software

 [ -f ${software_path}/${oracle_softname1} ] || exit 1 
 [ -f ${software_path}/${oracle_softname2} ] || exit 1 
chmod 777 ${software_path}/${oracle_softname1} 
chmod 777 ${software_path}/${oracle_softname2} 

su - oracle  -c " unzip -o ${software_path}/${oracle_softname1}   -d /home/oracle && unzip -o  ${software_path}/${oracle_softname2} -o -d /home/oracle "

# prepare rsp file
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

su - oracle -c "cd database; ./runInstaller -ignorePrereq -silent -responseFile ${oracle_rsp_file}"
# pause
echo  "###########################"
echo  -n "Continue (y/n)[y]:"
read  tmp_continue
case $tmp_continue in
n|N)
    echo "Let's stop here"
    exit 1
    ;;
*)
    echo "Let's continue"
esac


ssh rac1 "$oracle_oracle_home/root.sh"
ssh rac2 "$oracle_oracle_home/root.sh"
