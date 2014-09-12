#!/bin/bash

cd `dirname $0`
source ./rac_cfg_extend
source ./logging.sh
tmppwd=`pwd`


ora_log "scp oracle_deploy to every node"
current_oraInst_dirname=$(dirname  $( dirname $tmppwd  ) )
rm -rf /tmp/oracle_deploy
cp -rf $current_oraInst_dirname  /tmp/oracle_deploy
for tmpip in $(rac_pub_ip_list)
do
    scp -q -p -r /tmp/oracle_deploy $tmpip:/root/
done
ora_log "scp oracle_deploy to every node finish"
echo

i=1
for tmpip in $(rac_pub_ip_list)
do
    ora_log "=========$tmpip uninstall start=========="
    ssh $tmpip "chmod a+x  oracle_deploy -R ;cd oracle_deploy;  
    cd utility/rac/
    sh universe.sh uninstall;
    sh storage.sh uninstall;
    "
    ora_log "=========$tmpip uninstall finish=========="
    ((i++))
    echo 
    echo
done 
echo
unset i

ora_log  "Please Reboot each nodes  "
