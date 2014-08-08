#!/bin/bash
cd `dirname $0`

source ../../single.cfg
oracle_base_base=`dirname $oracle_oracle_base`

ora_log(){

printf  "%b" "[INFO] $*\n"
}

prepare_soft(){
cp -rf rsp11g0203/*.rsp /home/oracle
chown oracle:oinstall /home/oracle/*.rsp

 [ -f ${software_path}/${oracle_softname1} ] || exit 1 
 [ -f ${software_path}/${oracle_softname2} ] || exit 1 

chmod 777 ${software_path}/${oracle_softname1} 
chmod 777 ${software_path}/${oracle_softname2} 
ora_log "check md5 for software"
echo "$oracle_soft1_md5  ${software_path}/${oracle_softname1}" | md5sum -c 
if [[ $? != 0 ]];then
    echo " ${software_path}/${oracle_softname1} is not correct file"
    exit 1
fi
echo "$oracle_soft2_md5  ${software_path}/${oracle_softname2}" | md5sum -c
if [[ $? != 0 ]];then
    echo "${software_path}/${oracle_softname2}  is not correct file"
    exit 1
fi
ora_log "check md5 for software finish"
ora_log "unzip software to /home/oracle waiting ..."
su - oracle  -c " unzip -o ${software_path}/${oracle_softname1}  -d /home/oracle  >/dev/null"
su - oracle  -c " unzip -o ${software_path}/${oracle_softname2}  -d /home/oracle  >/dev/null"
ora_log "unzip software to /home/oracle finish "
echo
chown  -R oracle:oinstall /home/oracle/database/ 
chmod 777 -R /home/oracle/database/
}

backup_file(){
  [ -f /etc/hosts.bak ] || cp  -rf /etc/hosts{,.bak}
  [ -f /etc/sysctl.conf.bak ] || cp  -rf /etc/sysctl.conf{,.bak}
  [ -f /etc/security/limits.conf.bak ] || cp -rf  /etc/security/limits.conf{,.bak}
}
restore_file(){
  [ -f /etc/hosts.bak ] && cp  -rf /etc/hosts{.bak,}
  [ -f /etc/sysctl.conf.bak ] && cp -rf  /etc/sysctl.conf{.bak,}
  [ -f /etc/security/limits.conf.bak ] && cp -rf  /etc/security/limits.conf{.bak,}
}

open_X11(){
mkdir -p  /root/.xauth/ 2>/dev/null
echo oracle >  /root/.xauth/export
}

close_X11(){
rm -rf /root/.xauth/
}
turn_off_firewall(){
    [ -f /etc/init.d/SuSEfirewall2_setup ] && rcSuSEfirewall2 stop
    chkconfig SuSEfirewall2_setup off 
    [ -f /etc/init.d/iptables ] && service iptables stop
    chkconfig iptables off 
}
set_env(){
echo
ora_log "=========== start set environment ==========="
ora_log "check rpm"
rpm -ivh ../rpm/sysstat-8.1.5-7.32.1.x86_64.rpm >/dev/null 2>&1
rpm -e orarun >/dev/null 2>&1
rpm -ivh ../rpm/libcap1-1.10-6.10.x86_64.rpm >/dev/null 2>&1
ora_log "check rpm finish"
#hostname
ora_log "set hostname "
export HOSTNAME=$hostname
hostname $hostname
 [ -f  /etc/sysconfig/network ] && perl -p -i -e "s/HOSTNAME.*/HOSTNAME=${hostname}/" /etc/sysconfig/network
 [ -f  /etc/HOSTNAME ] &&  echo "$hostname" > /etc/HOSTNAME
cat  > /etc/hosts <<EOF
127.0.0.1       localhost
::1             localhost ipv6-localhost ipv6-loopback
$ip    $hostname
EOF
ora_log "set hostname finish"
#turn off firewall
ora_log "turn off firewall"
turn_off_firewall >/dev/null 2>&1
ora_log "turn off firewall finish"

#sysctl
ora_log "config sysctl"
shmmax=`cat /proc/meminfo  | grep MemTotal | awk '{print $2*512}' `
sed -i '/kernel.shmmax/d' /etc/sysctl.conf
cat >>/etc/sysctl.conf <<EOF
kernel.shmmax = $shmmax
fs.aio-max-nr = 1048576 
fs.file-max = 6815744 
kernel.shmmni = 4096 
kernel.sem = 250 32000 100 128 
net.ipv4.ip_local_port_range = 9000 65500 
net.core.rmem_default = 262144 
net.core.rmem_max = 4194304 
net.core.wmem_default = 262144 
net.core.wmem_max = 1048586
EOF
sysctl -p >/dev/null 2>&1 

ora_log "config sysctl finish"

#create oracle user and group
ora_log "create user for oracle"
userdel -r oracle >/dev/null 2>&1
groupdel dba >/dev/null 2>&1
groupdel oinstall >/dev/null 2>&1
groupadd oinstall >/dev/null 2>&1
groupadd dba >/dev/null 2>&1
useradd -m -g oinstall -G dba oracle >/dev/null 2>&1
echo $oracle_user_passwd | passwd oracle --stdin
ora_log "create user for oracle finish"

ora_log "set limits"
cat  >> /etc/security/limits.conf <<EOF
oracle  soft    nproc   65536
oracle  hard    nproc   65536
oracle  soft    nofile  65536
oracle  hard    nofile  65536
EOF

ora_log "create diretory for oracle"
# set install path
mkdir -p $oracle_oracle_base
chown -R oracle:oinstall $oracle_oracle_base
chmod -R 775 $oracle_oracle_base
mkdir -p ${oracle_base_base}/oraInventory
chown oracle:oinstall ${oracle_base_base}/oraInventory

ora_log "setup oracle user env value"
cat >> /home/oracle/.bash_profile  <<EOF
export ORACLE_BASE=${oracle_oracle_base}
export ORACLE_HOME=${oracle_oracle_home}
export ORACLE_SID=${oracle_sid}
export LD_LIBRARY_PATH=${oracle_ld_lib_path}:\$LD_LIBRARY_PATH
export PATH=\$ORACLE_HOME/bin:\$HOME/bin:/sbin:\$PATH
EOF
chown  oracle:oinstall /home/oracle/.bash_profile
chmod  644 /home/oracle/.bash_profile

open_X11
ora_log "=========== finish set environment ==========="
echo 
}

db_install(){

ora_log "db silent installment start"
if [ ! -f $oracle_db_soft_response_file ] 
then 
   echo $oracle_db_soft_response_file is not exsit!
   exit 1
fi
rm ${oracle_base_base}/oraInventory/logs/install*  -rf
su - oracle -c "/home/oracle/database/runInstaller -silent  -ignorePrereq -responseFile $oracle_db_soft_response_file"
#
sleep 30
ora_log "db silent installment in the backgroud waiting..."
while true
do
    if grep "Unloading Setup Driver" ${oracle_base_base}/oraInventory/logs/install*  >/dev/null 2>&1
    then
        break
    fi
    sleep 20
done

ora_log "execute scripts after db installment"
#  
chmod a+x ${oracle_base_base}/oraInventory/orainstRoot.sh
${oracle_base_base}/oraInventory/orainstRoot.sh
chmod a+x ${oracle_base_base}/oracle/product/11.2.0/db_1/root.sh
${oracle_base_base}/oracle/product/11.2.0/db_1/root.sh 
ora_log "db silent installment finish "
echo
}

netca_install(){

if [ ! -f $netca_response_file ] 
then 
   echo $netca_response_file is not exsit!
   exit 1
fi
open_X11
# setup netca 
ora_log "netca installment start"
su - oracle -c "netca -silent -responsefile $netca_response_file "
sleep 10
ora_log "netca installment finish"
echo 

}
dbca_install(){
if [ ! -f $dbca_response_file ] 
then 
   echo $dbca_response_file is not exsit!
   exit 1
fi


open_X11
sleep 5
# create database 
ora_log "dbca installment start"
su - oracle -c "  dbca -silent -responseFile $dbca_response_file "
ora_log "dbca installment finish"
sleep 10
ora_log "check oracle database"
# check database instance
su - oracle -c "sqlplus / as sysdba <<EOF
select instance_name,status from v\\\$instance;
select * from v\\\$version;
exit
EOF
"
ora_log "Oracle Single Installment All Finish"
}

uninstall(){
su - oracle -c " sqlplus / as sysdba <<EOF
shutdown immediate;
exit
EOF
"
sleep 10
su - oracle -c "lsnrctl stop"
sleep 10
    rm -rf ${oracle_base_base}/oracle/
    rm -rf ${oracle_base_base}/oraInventory/
    rm -rf /usr/local/bin/dbhome
    rm -rf /usr/local/bin/oraenv
    rm -rf /usr/local/bin/coraenv
    rm -rf /etc/oratab
    rm -rf /etc/oraInst.loc
    rm -rf /tmp/.oracle
    userdel -r oracle
    groupdel dba
    groupdel oinstall
}
single_usage(){
echo '
usage: oracInst single  <opt>

      -preOpt       prepare enviroment: unzip software,set env value, create user ,create directory and so on.
      -dbInstall    install database software only.
      -netca        setup listener
      -dbca         create database instance
      -all          install oracle all in one opt. the same as -preOpt, -dbInstall, -netca, -dbca,   one by one.
      -uninstall    uninstall oracle database 
'
}
######################################################
#
#
#                    MAIN
#
###########################################################
oracle_db_soft_response_file="/home/oracle/db.rsp"
netca_response_file="/home/oracle/netca.rsp"
dbca_response_file="/home/oracle/dbca.rsp"


opt=$1
shift
case $opt in 
    -preOpt)
        restore_file
        backup_file
        set_env
        prepare_soft
        ;;
    -dbInstall)
        db_install
    ;;
    -netca)
        netca_install
    ;;
    -dbca)
        dbca_install
    ;;
    -all)
        bash $0 -preOpt  && db_install && netca_install && dbca_install
    ;;
    -uninstall)
        uninstall
    ;;
    *)
    single_usage
    ;;
esac
