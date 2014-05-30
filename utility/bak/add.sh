chmod 666 /dev/fuse
chmod 666 /dev/null
chmod 666 /dev/zero
chmod 666 /dev/ptmx
chmod 666 /dev/tty
chmod 666 /dev/full
chmod 666 /dev/urandom
chmod 666 /dev/random
chmod 777 /database//p*.zip
su - grid  -c ' [ -d /home/grid/grid ] ||  unzip /database/p*3of7.zip -d /home/grid'
mkdir  /root/.xauth/
echo grid >  /root/.xauth/export
echo ================Excute this ============================
echo "cd grid ; ./runInstaller -ignoreSysPrereqs "
su - grid
