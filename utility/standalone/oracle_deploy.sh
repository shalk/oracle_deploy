#!/bin/bash

source ../../single.cfg

prepare_soft(){

cp -rf *.rsp /home/oracle
chown oracle:oinstall /home/oracle/*.rsp

 [ -f ${software_path}/${oracle_softname1} ] || exit 1 
 [ -f ${software_path}/${oracle_softname2} ] || exit 1 
chmod 777 ${software_path}/${oracle_softname1} 
chmod 777 ${software_path}/${oracle_softname2} 

su - oracle  -c " unzip -o ${software_path}/${oracle_softname1}  -d /home/oracle "
su - oracle  -c " unzip -o ${software_path}/${oracle_softname2}  -d /home/oracle "

cd `dirname $0`
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

open_X11(){
mkdir  /root/.xauth/
echo oracle >  /root/.xauth/export
}

close_X11(){
rm -rf /root/.xauth/
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

groupadd oinstall
groupadd dba
useradd -m -g oinstall -G dba oracle
echo $oracle_user_passwd | passwd oracle --stdin

cat  >> /etc/security/limits.conf <<EOF
oracle  soft    nproc   65536
oracle  hard    nproc   65536
oracle  soft    nofile  65536
oracle  hard    nofile  65536
EOF

# set install path
oracle_base_base=`dirname $oracle_oracle_base`
mkdir -p $oracle_oracle_base
chown -R oracle:oinstall $oracle_oracle_base
chmod -R 775 $oracle_oracle_base
mkdir -p ${oracle_base_base}/oraInventory
chown oracle:oinstall ${oracle_base_base}/oraInventory

cat >> /home/oracle/.bash_profile  <<EOF
export ORACLE_BASE=${oracle_oracle_base}
export ORACLE_HOME=${oracle_oracle_home}
export ORACLE_SID=${oracle_sid}
export LD_LIBRARY_PATH=${oracle_ld_lib_path}:\$LD_LIBRARY_PATH
export PATH=\$ORACLE_HOME/bin:\$HOME/bin:/sbin:\$PATH
EOF
chown  oracle:oinstall /home/oracle/.bash_profile
chmod  644 /home/oracle/.bash_profile

}

db_install(){
if [ ! -f $oracle_db_soft_response_file ] 
then 
   echo $oracle_db_soft_response_file is not exsit!
   exit 1
fi
rm ${oracle_base_base}/oraInventory/logs/install*  -rf
su - oracle -c "/home/oracle/database/runInstaller -silent  -ignorePrereq -responseFile $oracle_db_soft_response_file"
#检测安装完成
while true
do
    if grep "Unloading Setup Driver" ${oracle_base_base}/oraInventory/logs/install*  2>&1 >/dev/null
    then
        break
    fi
    sleep 20
done

# 执行root脚本
chmod a+x ${oracle_base_base}/oraInventory/orainstRoot.sh
${oracle_base_base}/oraInventory/orainstRoot.sh
chmod a+x ${oracle_base_base}/oracle/product/11.2.0/db_1/root.sh
${oracle_base_base}/oracle/product/11.2.0/db_1/root.sh 

}

netca_install(){

if [ ! -f $netca_response_file ] 
then 
   echo $netca_response_file is not exsit!
   exit 1
fi
open_X11
# 建立监听
su - oracle -c "netca -silent -responsefile $netca_response_file "
sleep 10

}
dbca_install(){
if [ ! -f $dbca_response_file ] 
then 
   echo $dbca_response_file is not exsit!
   exit 1
fi


#打开切换用户的GUI
mkdir  /root/.xauth/
echo oracle >  /root/.xauth/export
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

uninstall(){
su - oracle -c " sqlplus / nolog <<EOF
connect / as sysdba;
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
    rm -rf /etc/oratabb
    rm -rf /etc/oraInst.loc
    rm -rf /tmp/.oracle
    userdel -r oracle
    groupdel dba
    groupdel oinstall
}
single_usage(){
echo '
usage: oracInst single  <opt>

      -preOpt    预处理，建用户，路径, 配置环境
      -dbInstall 安装数据库
      -netca     建立监听
      -dbca      建库
      -all       相当于依次执行-preOpt -dbInstall -netca -dbca  
      -uninstall    卸载数据库环境
'
}
######################################################
#
#
#                    MAIN
#
###########################################################
#your_ip=${1:-192.168.132.132}
#your_host=${2:-node1}
oracle_db_soft_response_file="/home/oracle/db.rsp"
netca_response_file="/home/oracle/netca.rsp"
dbca_response_file="/home/oracle/dbca.rsp"


opt=$1
shift
case $1 in 
    -preOpt)
        restore_file
        backup_file
        set_env
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
        prepare  && db_install && netca_install && dbca_install
    ;;
    -uninstall)
        uninstall
    ;;
    *)
    single_usage
    ;;
esac


