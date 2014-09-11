

cd `dirname $0`

# setup parameter
source ./rac_cfg_extend
source ./logging.sh
source ./check_software.sh
grid_base_base=`dirname $grid_oracle_base `


ora_log "check grid software md5"
check_grid || { ora_err "check grid failed "; exit 1 ;}
ora_log "check grid software md5 finish"


# prepare software
chmod 777 $software_path/$grid_softname
ora_log "unzip grid software waiting..."
grid_unzip_log_name=`mktemp --tmpdir=/tmp --suffix=.log grid_unzip.XXXXX`
chmod 777 $grid_unzip_log_name
ora_log "detail in log : $grid_unzip_log_name "
su - grid  -c " [ -d /home/grid/grid ] ||  unzip ${software_path}/${grid_softname} -d /home/grid >$grid_unzip_log_name"
if  [ ! -d /home/grid/grid/ ]
then 
    echo "unzip failed"
    exit 1
fi
ora_log "unzip grid software finish"

ora_log "run orcacle cluster verify enviroment "
ora_log "detail in: $grid_pre_log"
tmpnodelist=$( split_list_by_comma  $(rac_pub_hostname_list))
su - grid -c "cd grid ; ./runcluvfy.sh  stage -pre crsinst -n $tmpnodelist -fixup -verbose > $grid_pre_log 2>&1"
unset tmpnodelist
ora_log "run orcacle cluster verify enviroment finish "

# prepare rsp file
prepare_grid_file(){
ora_log "prepare grid file"
touch  $grid_rsp_file
> $grid_rsp_file

cat >> $grid_rsp_file <<EOF 
oracle.install.responseFileVersion=/oracle/install/rspfmt_crsinstall_response_schema_v11_2_0
ORACLE_HOSTNAME=${grid_hostname}
INVENTORY_LOCATION=${grid_base_base}/oraInventory
SELECTED_LANGUAGES=en
oracle.install.option=CRS_CONFIG
ORACLE_BASE=${grid_oracle_base}
ORACLE_HOME=${grid_oracle_home}
oracle.install.asm.OSDBA=asmdba
oracle.install.asm.OSOPER=asmoper
oracle.install.asm.OSASM=asmadmin
oracle.install.crs.config.gpnp.scanName=${grid_scanname}
oracle.install.crs.config.gpnp.scanPort=1521
oracle.install.crs.config.clusterName=${grid_scanname}
oracle.install.crs.config.gpnp.configureGNS=false
oracle.install.crs.config.gpnp.gnsSubDomain=
oracle.install.crs.config.gpnp.gnsVIPAddress=
oracle.install.crs.config.autoConfigureClusterNodeVIP=false
oracle.install.crs.config.clusterNodes=${grid_cluster_node}
oracle.install.crs.config.networkInterfaceList=${grid_network_interface}
oracle.install.crs.config.storageOption=ASM_STORAGE
oracle.install.crs.config.sharedFileSystemStorage.diskDriveMapping=
oracle.install.crs.config.sharedFileSystemStorage.votingDiskLocations=
oracle.install.crs.config.sharedFileSystemStorage.votingDiskRedundancy=NORMAL
oracle.install.crs.config.sharedFileSystemStorage.ocrLocations=
oracle.install.crs.config.sharedFileSystemStorage.ocrRedundancy=NORMAL
oracle.install.crs.config.useIPMI=false
oracle.install.crs.config.ipmi.bmcUsername=
oracle.install.crs.config.ipmi.bmcPassword=
oracle.install.asm.SYSASMPassword=${grid_sysasm_passwd}
oracle.install.asm.diskGroup.name=${grid_diskgroup_name}
oracle.install.asm.diskGroup.redundancy=${grid_disk_redunt}
oracle.install.asm.diskGroup.AUSize=${grid_disk_ausize}
oracle.install.asm.diskGroup.disks=${grid_disk_list}
oracle.install.asm.diskGroup.diskDiscoveryString=
oracle.install.asm.monitorPassword=${grid_monitor_passwd}
oracle.install.crs.upgrade.clusterNodes=
oracle.install.asm.upgradeASM=false
oracle.installer.autoupdates.option=SKIP_UPDATES
oracle.installer.autoupdates.downloadUpdatesLoc=
AUTOUPDATES_MYORACLESUPPORT_USERNAME=
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=
PROXY_HOST=
PROXY_PORT=0
PROXY_USER=
PROXY_PWD=
PROXY_REALM=
EOF
chmod 777 $grid_rsp_file
}
# setup x11
open_X11_for_grid(){
mkdir -p ~/.xauth/
echo grid > ~/.xauth/export
}
# execute silent mode 
exec_grid(){
ora_log "execute grid silent installment"
rm -rf ${grid_base_base}/oraInventory/logs/*
su - grid -c "cd grid;  ./runInstaller -ignorePrereq -silent -responseFile ${grid_rsp_file}  "
}


#check grid success
check_grid_finish(){
    echo
    ora_log "waiting grid silent installment in background"
    sleep 20
    while true
    do
        if grep "Unloading Setup Driver" ${grid_base_base}/oraInventory/logs/installActions*  >/dev/null 2>&1
        then
            break
        fi
        sleep 5
        if grep "Exit Status is 0" ${grid_base_base}/oraInventory/logs/installActions*  >/dev/null 2>&1
        then
            break
        fi
        for errfile in `ls  ${grid_base_base}/oraInventory/logs/*.err 2>/dev/null`
        do
            if [ -s $errfile  ]   
            then 
                echo "[ERROR] error in log " ${grid_base_base}/oraInventory/logs/*.err 
                return 1
            fi
        done
        sleep 20
    done
    ora_log "grid silent complete"
    return 0
}
grid_after_install(){
    ora_log "execute orainstRoot.sh and root.sh for everynode"
    for tmpnode in `rac_pub_hostname_list` 
    do
        ssh $tmpnode "${grid_base_base}/oraInventory/orainstRoot.sh"
    done
    for tmpnode in `rac_pub_hostname_list`
    do
        ssh $tmpnode "${grid_oracle_home}/root.sh"
    done
    ora_log "execute configToolAllCommands"
    su - grid -c "${grid_oracle_home}/cfgtoollogs/configToolAllCommands"
}

prepare_grid_file
open_X11_for_grid
exec_grid
if check_grid_finish 
then 
    grid_after_install
    exit 0
else 
    exit 1
fi
