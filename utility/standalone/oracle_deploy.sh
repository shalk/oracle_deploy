#!/bin/bash

prepare_soft(){

cp -rf *.rsp /home/oracle
chown oracle:oinstall /home/oracle/*.rsp

unzip linux.x64_11gR2_database_1of2.zip
unzip linux.x64_11gR2_database_2of2.zip
if [  -f database ]
then
    echo 
else
    echo "please put oracle software   in current directory!"
    exit 1
fi

mv database/   /home/oracle/
chown  -R oracle:oinstall /home/oracle/database/ 
chmod 777 -R /home/oracle/database/
}

# 检查是否备份
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

set_env(){
rpm -q syssat || rpm -ivh sysstat-8.1.5-7.32.1.x86_64.rpm
#export HOSTNAME=$your_host
#hostname $your_host
##perl -p -i -e "s/HOSTNAME.*/HOSTNAME=$your_host/" /etc/sysconfig/network
#echo "$your_host" >> /etc/HOSTNAME
#echo "$your_ip  $your_host" >>/etc/hosts


#sysctl
cat /etc/sysctl.conf  | grep '^#' -v | grep '^\s*$' -v > /etc/sysctl.conf.bak
cp /etc/sysctl.conf.bak  /etc/sysctl.conf
cat >>/etc/sysctl.conf <<EOF
kernel.shmmni = 4096
kernel.sem = 5010 641280 5010 128
fs.file-max = 671088640
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 1048576
net.core.rmem_max = 4194304
net.core.wmem_default = 1048576
net.core.wmem_max = 1048576
EOF
sysctl -p


#create oracle user and group
userdel -r oracle
groupdel dba
groupdel oinstall

/usr/sbin/groupadd oinstall
/usr/sbin/groupadd dba
/usr/sbin/useradd -m -g oinstall -G dba oracle
echo $oracle_user_passwd | passwd oracle --stdin

cat  >> /etc/security/limits.conf <<EOF
oracle  soft    nproc   65536
oracle  hard    nproc   65536
oracle  soft    nofile  65536
oracle  hard    nofile  65536
EOF

# set install path
mkdir -p /u01/app/oracle
chown -R oracle:oinstall /u01/app/oracle
chmod -R 775 /u01/app/oracle
mkdir -p /u01/app/oraInventory
chown oracle:oinstall /u01/app/oraInventory
cat >> /home/oracle/.bash_profile  <<EOF
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/11.2.0/db_1
export ORACLE_SID=orcl
export LD_LIBRARY_PATH=/u01/app/oracle/product/11.2.0/db_1/lib:\$LD_LIBRARY_PATH
export PATH=\$ORACLE_HOME/bin:\$HOME/bin:/sbin:\$PATH
EOF
chown  oracle::oinstall /home/oracle/.bash_profile
chmod  644 /home/oracle/.bash_profile
}

install_soft(){
if [ ! -f $oracle_db_soft_response_file ] 
then 
   echo $oracle_db_soft_response_file is not exsit!
   exit 1
fi
if [ ! -f $netca_response_file ] 
then 
   echo $netca_response_file is not exsit!
   exit 1
fi
if [ ! -f $dbca_response_file ] 
then 
   echo $dbca_response_file is not exsit!
   exit 1
fi



su - oracle -c "/home/oracle/database/runInstaller -silent  -ignorePrereq -responseFile $oracle_db_soft_response_file"
#检测安装完成
while true
do
    if grep "Unloading Setup Driver" /u01/app/oraInventory/logs/install*  2>&1 >/dev/null
    then
        break
    fi
    sleep 20
done

# 执行root脚本
chmod a+x /u01/app/oraInventory/orainstRoot.sh
/u01/app/oraInventory/orainstRoot.sh
chmod a+x /u01/app/oracle/product/11.2.0/db_1/root.sh
/u01/app/oracle/product/11.2.0/db_1/root.sh 

#打开切换用户的GUI
mkdir  /root/.xauth/
echo oracle >  /root/.xauth/export
# 建立监听
su - oracle -c "netca -silent -responsefile $netca_response_file "
sleep 10
# 建库
su - oracle -c "  dbca -silent -responseFile $dbca_response_file "
sleep 10
# 验证
su - oracle -c "sqlplus / as sysdba <<EOF
select instance_name,status from v\\\$instance;
select * from v\\\$version;
exit
EOF
"
}

open_X11{
mkdir  /root/.xauth/
echo oracle >  /root/.xauth/export
}

close_X11{
rm -rf /root/.xauth/
}
uninstall {
rm -rf /u01/app/oracle/
rm -rf /u01/app/oraInventory/
rm -rf /usr/local/bin/dbhome
rm -rf /usr/local/bin/oraenv
rm -rf /usr/local/bin/coraenv
rm -rf /etc/oratabb
rm -rf /etc/oraInst.loc
rm -rf /tmp/.oracle
userdel -r oracle
groupdel dba
groupdel oinstall
}
######################################################
#
#
#                    MAIN
#
###########################################################
#your_ip=${1:-192.168.132.132}
#your_host=${2:-node1}
oracle_user_passwd="111111"
oracle_db_soft_response_file="/home/oracle/db.rsp"
netca_response_file="/home/oracle/netca.rsp"
dbca_response_file="/home/oracle/dbca.rsp"

restore_file
backup_file
set_env
prepare_soft
install_soft

