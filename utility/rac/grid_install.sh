

cd `dirname $0`

# setup parameter
source ../../o.conf
grid_base_base=`dirname $grid_oracle_base `
sh check.sh



#fix permissive

chmod 666 /dev/fuse
chmod 666 /dev/null
chmod 666 /dev/zero
chmod 666 /dev/ptmx
chmod 666 /dev/tty
chmod 666 /dev/full
chmod 666 /dev/urandom
chmod 666 /dev/random

# make sure connect
su - grid -c 'ssh -o StrictHostKeyChecking=no rac1 date'
su - grid -c 'ssh -o StrictHostKeyChecking=no rac2 date'
su - oracle -c 'ssh -o StrictHostKeyChecking=no rac2 date'
su - oracle -c 'ssh -o StrictHostKeyChecking=no rac1 date'
ssh -o StrictHostKeyChecking=no rac1 date
ssh -o StrictHostKeyChecking=no rac2 date
ssh rac2 "
su - grid -c 'ssh -o StrictHostKeyChecking=no rac1 date'
su - grid -c 'ssh -o StrictHostKeyChecking=no rac2 date'
su - oracle -c 'ssh -o StrictHostKeyChecking=no rac2 date'
su - oracle -c 'ssh -o StrictHostKeyChecking=no rac1 date'
ssh -o StrictHostKeyChecking=no rac1 date
ssh -o StrictHostKeyChecking=no rac2 date
"

# prepare software
 [ -f ${software_path}/${grid_softname} ] || exit 1 
chmod 777 /database/$grid_softname
su - grid  -c " [ -d /home/grid/grid ] ||  unzip ${software_path}/${grid_softname} -d /home/grid "


# prepare rsp file
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


# setup x11

mkdir ~/.xauth/
echo grid > ~/.xauth/export


# execute silent mode 
su - grid -c "cd grid; ./runInstaller -ignorePrereq -silent -responseFile ${grid_rsp_file}"

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
# 
ssh rac1 "${grid_base_base}/oraInventory/orainstRoot.sh"
ssh rac2 "${grid_base_base}/oraInventory/orainstRoot.sh"
ssh rac1 "${grid_oracle_home}/root.sh"
ssh rac2 "${grid_oracle_home}/root.sh"

su - grid -c "${grid_oracle_home}/cfgtoollogs/configToolAllCommands"
#
