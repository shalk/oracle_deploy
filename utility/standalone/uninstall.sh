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
