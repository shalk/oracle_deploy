#!/bin/bash

cd `dirname $0`
source rac_cfg_extend
source logging.sh
tmppwd=`pwd`
rac_pub_iplist_by_comma=$( split_list_by_comma $(rac_pub_ip_list ))
rac_pub_hostname_list_by_comma=$( split_list_by_comma $(rac_pub_hostname_list ))


#no_pass

ora_log "setup no password for root"
cd ../no_passwd/  
./xmakessh  --user root --pass  $current_passwd --nodes  $rac_pub_hostname_list_by_comma  1>/dev/null  
cd $tmppwd
ora_log "setup no password for root finish"

#scp to every node
ora_log "scp oracle_deploy to every node"
current_oraInst_dirname=$(dirname  $( dirname $tmppwd  ) )
rm -rf /tmp/oracle_deploy
cp -rf $current_oraInst_dirname  /tmp/oracle_deploy
for tmpip in $(rac_pub_ip_list)
do
    scp -q -r /tmp/oracle_deploy $tmpip:/root/
done
ora_log "scp oracle_deploy to every node finish"
echo

# preOpt for every node
for tmpip in $(rac_pub_ip_list)
do
    ora_log "=========$tmpip prepare start=========="
    ssh $tmpip 'chmod a+x  oracle_deploy -R ;cd oracle_deploy;  
    cd utility/rac/
    sh universe.sh install 2;
    sh storage.sh install;
    '
    ora_log "=========$tmpip prepare finish=========="
    echo 
    echo
done 
echo

ora_log "setup no password for user grid,oracle"
cd ../no_passwd/; 
chmod a+x xmakessh
./xmakessh  --user oracle --pass  $current_passwd --nodes  $rac_pub_hostname_list_by_comma  >/dev/null
./xmakessh  --user grid   --pass  $current_passwd --nodes  $rac_pub_hostname_list_by_comma  >/dev/null
cd $tmppwd
ora_log "setup no password for user grid,oracle finish"

# make sure connect
ora_log "try ssh node  for each node and user "
for tmphostname in $(rac_pub_hostname_list)
do
    su - grid -c "ssh -o StrictHostKeyChecking=no $tmphostname test 1" 
    su - oracle -c "ssh -o StrictHostKeyChecking=no $tmphostname test 1"
    ssh -o StrictHostKeyChecking=no $tmphostname test 1
done
ora_log "try ssh node date for each node and user finish"

echo "Prepare Finish"
