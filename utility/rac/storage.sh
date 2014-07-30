#!/bin/bash
cd `dirname $0`
if  [ ! -f ../../disk_map ] ;then
    echo "disk_map is not exist"
    exit 1
fi	
disk_map='../../disk_map'
backup_file(){
 [ -f  /etc/udev/rules.d/99-oracle-raw.rules.bak ] || cp -rf /etc/udev/rules.d/99-oracle-raw.rules{,.bak} || touch /etc/udev/rules.d/99-oracle-raw.rules.bak
 [ -f /etc/raw.bak ] || cp -rf /etc/raw{,.bak} || touch /etc/raw.bak
}
restore_file(){
 [ -f /etc/udev/rules.d/99-oracle-raw.rules.bak ] &&  cp -rf /etc/udev/rules.d/99-oracle-raw.rules{.bak,}
 [ -f /etc/raw.bak ] &&  cp -rf /etc/raw{.bak,}
}

stor_login(){
storage_flag=`iscsiadm -m discovery -t sendtargets -p $storage_ip | awk '{ print $2 }' `
iscsiadm -m  node  -T $storage_flag  -p $storage_ip  -l
}

setup_storage(){

perl -i -ne 's/ / /g;s/^ //g;s/ $//g;s/#.*//g; next if /^\s*$/ ; print  ' ../../disk_map 

sleep 10
diskArray=`awk -F: '{print $2}' ../../disk_map`
cp -rf ../../disk_map  /etc/raw
sed -i 's/\/dev\///' /etc/raw
chkconfig raw on

#set udeve file 
for disk in $diskArray
do
    chmod 666 $disk
done

echo "SUBSYSTEM==\"raw\", KERNEL==\"raw[0-9]*\", NAME=\"raw/%k\", GROUP=\"asmadmin\", MODE=\"660\", OWNER=\"grid\"" >> /etc/udev/rules.d/99-oracle-raw.rules
rcraw start
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
echo =========================================  
awk -F: '{print $2}' ../../disk_map | xargs ls -l
echo =========================================  
ls -l  /dev/raw
echo =========================================  
}

storage_ip=${2:-10.5.101.16}

case $1 in
  install) 
        restore_file
        backup_file
        setup_storage
	    show_disk
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

