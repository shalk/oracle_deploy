#!/bin/bash
cd `dirname $0`
if  [ ! -f ./rac_cfg_extend ] ;then
    echo "rac.cfg is not exist"
    exit 1
fi	
source ./rac_cfg_extend
source ./logging.sh
datadisks=$(rac_data_disk_list)
crsdisks=$(rac_crs_disk_list)

if [ -f /etc/redhat-release ] ; then
    DistroBasedOn='RedHat'
elif [ -f /etc/SuSE-release ] ; then
    DistroBasedOn='SuSe'
else
    DistroBasedOn='NULL'
fi

backup_file(){
 [ -f  /etc/udev/rules.d/99-oracle-raw.rules.bak ] || cp -rf /etc/udev/rules.d/99-oracle-raw.rules{,.bak} >& /dev/null || touch /etc/udev/rules.d/99-oracle-raw.rules.bak
 [ -f /etc/raw.bak ] || cp -rf /etc/raw{,.bak} >& /dev/null || touch /etc/raw.bak
 [ -f /etc/rc.d/rc.local.bak ] || cp -rf /etc/rc.d/rc.local{,.bak} >& /dev/null
}
restore_file(){
 [ -f /etc/udev/rules.d/99-oracle-raw.rules.bak ] &&  cp -rf /etc/udev/rules.d/99-oracle-raw.rules{.bak,} >& /dev/null
 [ -f /etc/raw.bak ] &&  cp -rf /etc/raw{.bak,} >& /dev/null
 [ -f /etc/rc.d/rc.local.bak ]  && cp -rf /etc/rc.d/rc.local{.bak,} >& /dev/null
}

stor_login(){
storage_flag=`iscsiadm -m discovery -t sendtargets -p $storage_ip | awk '{ print $2 }' `
iscsiadm -m  node  -T $storage_flag  -p $storage_ip  -l
}

setup_storage(){
ora_log "[setup_storage] raw device relationship take effect"
sleep 10
> /etc/raw
i=1
for disk in  $crsdisks
do
    chmod 666 $disk
    echo crsraw${i}:${disk} >> /dev/raw
    ((i++))
done
i=1
for disk in  $datadisks
do
    chmod 666 $disk
    echo dataraw${i}:${disk} >> /dev/raw
    ((i++))
done
unset i
sed -i 's/\/dev\///' /etc/raw


#set udeve file 

echo "SUBSYSTEM==\"raw\", KERNEL==\"crsraw[0-9]*\", NAME=\"raw/%k\", GROUP=\"asmadmin\", MODE=\"660\", OWNER=\"grid\"" >> /etc/udev/rules.d/99-oracle-raw.rules
echo "SUBSYSTEM==\"raw\", KERNEL==\"dataraw[0-9]*\", NAME=\"raw/%k\", GROUP=\"asmadmin\", MODE=\"660\", OWNER=\"grid\"" >> /etc/udev/rules.d/99-oracle-raw.rules
chkconfig raw on
rcraw start
}
setup_storage_for_redhat(){
ora_log "[setup_storage] raw device relationship take effect"
sleep 10
#set udeve file 
> /etc/rc.d/raw.local
touch /etc/rc.d/raw.local
chmod 755 /etc/rc.d/raw.local
i=1
for disk in  $crsdisks
do
    chmod 666 $disk
    echo raw /dev/raw/crsraw${i} ${disk} >> /etc/rc.d/raw.local
    ((i++))
done
i=1
for disk in  $datadisks
do
    chmod 666 $disk
    echo raw /dev/raw/dataraw${i} ${disk} >> /etc/rc.d/raw.local
    ((i++))
done
unset i

chmod 755 /etc/rc.d/raw.local 
echo "/etc/rc.d/raw.local" >> /etc/rc.d/rc.local 
/etc/rc.d/raw.local
echo "SUBSYSTEM==\"raw\", KERNEL==\"crsraw[0-9]*\", NAME=\"raw/%k\", GROUP=\"asmadmin\", MODE=\"660\", OWNER=\"grid\"" >> /etc/udev/rules.d/99-oracle-raw.rules
echo "SUBSYSTEM==\"raw\", KERNEL==\"dataraw[0-9]*\", NAME=\"raw/%k\", GROUP=\"asmadmin\", MODE=\"660\", OWNER=\"grid\"" >> /etc/udev/rules.d/99-oracle-raw.rules
start_udev
}

uninstall(){
rawArray=`raw -qa  | awk -F: '{print $1}'`
for i in $rawArray
do
   raw $i 0 0 
done
rcraw stop
}

stor_logout(){
storage_flag=`iscsiadm -m discovery -t sendtargets -p $storage_ip | awk '{ print $2 }' `
iscsiadm -m  node  -p $storage_ip  -T $storage_flag  -u
}
show_disk(){
ora_log "[show_disk] raw list"
diskArray="$raw1 $raw2 $raw3 $raw4 $raw5"
echo "========================================="  
for disk in $diskArray
do
    ls -l $disk
done
echo =========================================  
ls -l  /dev/raw 
echo "========================================="
}

storage_ip=${2:-10.5.101.16}

case $1 in
  install) 
        restore_file >/dev/null 2>&1
        backup_file
        if [ X$DistroBasedOn == 'XSuSe' ] ; then 
            setup_storage
        elif [ X$DistroBasedOn == 'XRedHat' ]; then
            setup_storage_for_redhat
        else
            :
        fi
#        show_disk
        ;;
  uninstall)
        uninstall
        restore_file
        show_disk
        ;;
   *)
        echo "usage:$0 [install  | uninstall] "
       ;;
esac

