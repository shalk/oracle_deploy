#oracle_deploy.sh

cd /home/oracle
unzip p10404530_112030_Linux-x86-64_1of7.zip
unzip p10404530_112030_Linux-x86-64_2of7.zip
chown –R oracle:oinstall database/
cd  database
# 安装软件 GUI
#./runInstaller
# 配置监听 GUI
# netca
#创建数据库 GUI
#dbca
sqlplus / as sysdba <<EOF
select instance_name,status from v\$instance;
create user tpcc identified by tpcc;
grant dba to tpcc;
drop user tpcc;
EOF
