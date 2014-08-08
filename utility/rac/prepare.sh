#!/bin/bash

cd `dirname $0`
source ../../rac.cfg
source logging.sh
tmppwd=`pwd`
#no_pass
ora_log "setup no password for root"
cd ../no_passwd/  
./xmakessh  --user root --pass  $current_passwd --nodes  10.5.101.21,10.5.101.20 1>/dev/null  
cd $tmppwd
ora_log "setup no password for root finish"

#scp to every node
ora_log "scp oracle_deploy to every node"
current_oraInst_dirname=$(dirname  $( dirname $tmppwd  ) )
rm -rf /tmp/oracle_deploy
cp -rf $current_oraInst_dirname  /tmp/oracle_deploy
scp -q -r /tmp/oracle_deploy 10.5.101.20:/root/
scp -q -r /tmp/oracle_deploy 10.5.101.21:/root/
ora_log "scp oracle_deploy to every node finish"
echo
ora_log "=========rac2 prepare start=========="
ssh 10.5.101.21 'chmod a+x  oracle_deploy -R ;cd oracle_deploy;  
cd utility/rac/
sh universe.sh install 2;
sh storage.sh install;
'
ora_log "=========rac2 prepare finish=========="
echo
echo
ora_log "=========rac1 prepare start=========="
ssh 10.5.101.20 'chmod a+x  oracle_deploy -R ;cd oracle_deploy;   
cd utility/rac/;
sh universe.sh install 1
sh storage.sh install 
'
ora_log "=========rac1 prepare finish=========="
echo
ora_log "setup no password for user grid,oracle"
cd ../no_passwd/; 
chmod a+x xmakessh
./xmakessh  --user oracle --pass  $current_passwd --nodes  10.5.101.21,10.5.101.20  >/dev/null
./xmakessh  --user grid   --pass  $current_passwd --nodes  10.5.101.21,10.5.101.20  >/dev/null
cd $tmppwd
ora_log "setup no password for user grid,oracle finish"

# make sure connect
ora_log "try ssh node  for each node and user "
su - grid -c 'ssh -o StrictHostKeyChecking=no rac1 test 1' 
su - grid -c 'ssh -o StrictHostKeyChecking=no rac2 test 1'
su - oracle -c 'ssh -o StrictHostKeyChecking=no rac2 test 1'
su - oracle -c 'ssh -o StrictHostKeyChecking=no rac1 test 1'
ssh -o StrictHostKeyChecking=no rac1 test 1
ssh -o StrictHostKeyChecking=no rac2 test 1
ssh rac2 "
su - grid -c 'ssh -o StrictHostKeyChecking=no rac1 test 1'
su - grid -c 'ssh -o StrictHostKeyChecking=no rac2 test 1'
su - oracle -c 'ssh -o StrictHostKeyChecking=no rac2 test 1'
su - oracle -c 'ssh -o StrictHostKeyChecking=no rac1 test 1'
ssh -o StrictHostKeyChecking=no rac1 test 1
ssh -o StrictHostKeyChecking=no rac2 test 1
"
ora_log "try ssh node date for each node and user finish"

echo "Prepare Finish"
