#!/bin/bash
cd `dirname $0`

backup_file(){
 [ -f  /etc/udev/rules.d/99-oracle-raw.rules.bak ] || cp -rf /etc/udev/rules.d/99-oracle-raw.rules{,.bak} || touch /etc/udev/rules.d/99-oracle-raw.rules.bak
 [ -f /etc/raw.bak ] || cp -rf /etc/raw{,.bak} || touch /etc/raw.bak
}
restore_file(){
 [ -f /etc/udev/rules.d/99-oracle-raw.rules.bak ] &&  cp -rf /etc/udev/rules.d/99-oracle-raw.rules{.bak,}
 [ -f /etc/raw.bak ] &&  cp -rf /etc/raw{.bak,}
}

setup_storage(){
#login
storage_flag=`iscsiadm -m discovery -t sendtargets -p $storage_ip | awk '{ print $2 }' `
iscsiadm -m  node  -T $storage_flag  -p $storage_ip  -l
#fdisk -l 2>&1 /dev/null
sleep 10
diskArray=`ls /dev/sd*  | grep sda -v | sort | awk -F/ '{print $3}'`
count=1
#set raw
for disk in $diskArray
do
   echo raw${count}:$disk >> /etc/raw
   ((count++))
done

chkconfig raw on
set owner

#set udeve file 
count=1
for disk in $diskArray
do
    chmod 666 /dev/$disk
#    echo "KERNEL==\"raw${count}\", SUBSYSTEM==\"raw\", NAME=\"${disk}\", GROUP=\"asmadmin\", MODE=\"660\", OWNER=\"grid\" " >> /etc/udev/rules.d/99-oracle-raw.rules
    ((count++))
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
diskArray=`ls /dev/sd*  | grep sda -v | sort | awk -F/ '{print $3}'`
for i in $diskArray
do
   rm -rf  /dev/$i
done 

rcraw stop
storage_flag=`iscsiadm -m discovery -t sendtargets -p $storage_ip | awk '{ print $2 }' `
iscsiadm -m  node  -p $storage_ip  -T $storage_flag  -u
}
show_disk(){
echo =========================================  
ls -l /dev/sd*
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

