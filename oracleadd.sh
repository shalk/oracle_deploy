chmod 777 /database//p*.zip
su - oracle  -c ' [ -d /home/oracle/database ] ||  unzip /database/p*1of7.zip -d /home/oracle && unzip /database/p*2of7.zip -d /home/oracle '
mkdir  /root/.xauth/
echo oracle >  /root/.xauth/export
echo ================Excute this ============================
echo "cd database ; ./runInstaller -ignoreSysPrereqs "
su - oracle
