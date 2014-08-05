#!/bin/bash

cd `dirname $0`
source ../../rac.cfg

#no_pass
cd ../no_passwd/  
./xmakessh  --user root --pass  $current_passwd --nodes  10.5.101.21,10.5.101.20  
cd ../rac/ 



scp -r ../../oracle_deploy 10.5.101.21:/root/oracle_deploy
ssh 10.5.101.21 'chmod a+x  oracle_deploy -R ;cd oracle_deploy;  
cd utility/rac/
sh universe.sh install 2;
sh storage.sh install;
'


scp -r ../../oracle_deploy 10.5.101.20:/root/oracle_deploy
ssh 10.5.101.20 'chmod a+x  oracle_deploy -R ;cd oracle_deploy;   
cd utility/rac/;
sh universe.sh install 1
sh storage.sh install 
'

cd ../no_passwd/; 
chmod a+x xmakessh
./xmakessh  --user oracle --pass  $current_passwd --nodes  10.5.101.21,10.5.101.20  
cd ../rac/ 
cd utility/no_passwd/
./xmakessh  --user grid   --pass  $current_passwd --nodes  10.5.101.21,10.5.101.20  
cd utility/rac/ 

echo "Prepare Finish"
