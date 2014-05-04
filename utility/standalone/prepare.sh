#host
your_ip='ip'
your_host='node1'
export HOSTNAME=$your_host
hostname $your_host
perl -p -i -e "s/HOSTNAME.*/HOSTNAME=$your_host/" /etc/sysconfig/network
echo "$your_ip  $your_host" >>/etc/hosts


#sysctl
cat /etc/sysctl.conf  | grep '^#' -v | grep '^\s*$' -v > /etc/sysctl.conf.bak
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
oracle_passwd="111111"
userdel -r oracle
groupdel dba
groupdel oinstall

/usr/sbin/groupadd oinstall
/usr/sbin/groupadd dba
/usr/sbin/useradd -m -g oinstall -G dba oracle
echo $oracle_passwd | passwd oracle --stdin

cat  >> /etc/security/limits.conf <<EOF
oracle 	soft 	nproc 	65536
oracle 	hard 	nproc 	65536
oracle 	soft 	nofile 	65536
oracle	hard 	nofile 	65536
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

cp -rf oracle_deploy.sh /home/oracle
chmod a+x /home/oracle/oracle_deploy.sh 
su - oracle  -c ' cd /home/oracle ; sh oracle_deploy.sh'

