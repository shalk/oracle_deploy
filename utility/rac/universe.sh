#config network


#config storage

oracle_passwd='111111'
node_num=$1
#sysconfig

backup_file(){
    [  -f /etc/security/limits.conf.bak ] ||  cp -rf /etc/security/limits.conf{,.bak}
    [  -f /etc/pam.d/login.bak ] ||  cp -rf /etc/pam.d/login{,.bak}
    [  -f /etc/sysctl.conf.bak ] ||  cp -rf /etc/sysctl.conf{,.bak}
    [  -f /etc/hosts.bak ] ||  cp -rf /etc/hosts{,.bak}
}

restore_file(){
    [  -f /etc/security/limits.conf.bak ] &&  cp -rf /etc/security/limits.conf{.bak,}
    [  -f /etc/pam.d/login.bak ] &&  cp -rf /etc/pam.d/login{.bak,}
    [  -f /etc/sysctl.conf.bak ] &&  cp -rf /etc/sysctl.conf{.bak,}
    [  -f /etc/hosts.bak ] &&  cp -rf /etc/hosts{.bak,}
}

set_env(){

cat >> /etc/security/limits.conf <<EOF
grid soft nproc 2047 
grid hard nproc 16384 
grid soft nofile 1024 
grid hard nofile 65536 
oracle soft nproc 2047 
oracle hard nproc 16384 
oracle soft nofile 1024 
oracle hard nofile 65536
EOF

cat >>/etc/pam.d/login <<EOF
session required pam_limits.so
EOF

cat >>/etc/sysctl.conf <<EOF
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
#stop ntp
/etc/init.d/ntpd stop 
chkconfig ntpd off 
mv /etc/ntp.conf /etc/ntp.org
#config host

cat  > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF

cat ../../ip_map >> /etc/hosts
# set hostname
your_host=node$node_num
export HOSTNAME=$your_host
hostname $your_host
 [ -f /etc/sysconfig/network ] &&  perl -p -i -e "s/HOSTNAME.*/HOSTNAME=$your_host/" /etc/sysconfig/network
 [ -f /etc/HOSTNAME ] && echo $your_host > /etc/HOSTNAME
#del group adn user
userdel -r oracle
userdel -r grid
groupdel oinstall
groupdel dba
groupdel poer
groupdel asmadmin
groupdel asmoper
groupdel asmdba
#add group and user
/usr/sbin/groupadd -g 502 oinstall 
/usr/sbin/groupadd -g 503 dba 
/usr/sbin/groupadd -g 504 oper 
/usr/sbin/groupadd -g 505 asmadmin
/usr/sbin/groupadd -g 506 asmoper 
/usr/sbin/groupadd -g 507 asmdba 
/usr/sbin/useradd -m -g oinstall -G dba,asmdba,oper oracle 
/usr/sbin/useradd -m -g oinstall -G asmadmin,asmdba,asmoper,oper,dba grid
echo $oracle_passwd | passwd oracle --stdin
echo $oracle_passwd | passwd grid --stdin

#create dir
mkdir -p /home/oracle 
mkdir -p /home/grid 
chown -R oracle:oinstall /home/oracle 
chown -R grid:oinstall /home/grid 
mkdir -p /oracle/app 
chown -R grid:oinstall /oracle/app/ 
chmod -R 775 /oracle/app/ 
mkdir -p /oracle/app/oraInventory 
chown -R grid:oinstall /oracle/app/oraInventory 
chmod -R 775 /oracle/app/oraInventory 
mkdir -p /oracle/app/grid 
mkdir -p /oracle/app/oracle 
chown -R grid:oinstall /oracle/app/grid 
chown -R oracle:oinstall /oracle/app/oracle 
chmod -R 775 /oracle/app/oracle 
chmod -R 775 /oracle/app/grid
}
user_env(){
cat >>/home/oracle/.bash_profile <<EOF
ORACLE_SID=+ASM${node_num}; export ORACLE_SID 
ORACLE_BASE=/oracle/app/grid; export ORACLE_BASE 
ORACLE_HOME=/home/grid/product/11.2.0; export ORACLE_HOME
PATH=\$ORACLE_HOME/bin:\$PATH; export PATH 
LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
EOF

cat >>/home/grid/.bash_profile <<EOF
ORACLE_BASE=/oracle/app/oracle; export ORACLE_BASE 
ORACLE_HOME=\$ORACLE_BASE/product/11.2.0; export ORACLE_HOME 
ORACLE_SID=rac${node_num}; export ORACLE_SID
PATH=\$ORACLE_HOME/bin:\$PATH; export PATH 
LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
EOF
}

restore_file
backup_file
set_env
user_env
exit 0 


