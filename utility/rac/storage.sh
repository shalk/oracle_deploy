#!/bin/bash
cd `dirname $0`
if  [ ! -f ../../rac.cfg ] ;then
    echo "rac.cfg is not exist"
    exit 1
fi	
source ../../rac.cfg

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

sleep 10
cat > /etc/raw  <<EOF
raw1:$raw1
raw2:$raw2
raw3:$raw3
raw4:$raw4
raw5:$raw5
EOF
sed -i 's/\/dev\///' /etc/raw


#set udeve file 
diskArray="$raw1 $raw2 $raw3 $raw4 $raw5"

for disk in $diskArray
do
    chmod 666 $disk
done

echo "SUBSYSTEM==\"raw\", KERNEL==\"raw[0-9]*\", NAME=\"raw/%k\", GROUP=\"asmadmin\", MODE=\"660\", OWNER=\"grid\"" >> /etc/udev/rules.d/99-oracle-raw.rules
chkconfig raw on
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
diskArray="$raw1 $raw2 $raw3 $raw4 $raw5"
echo =========================================  
for disk in $diskArray
do
    ls -l $disk
done
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

