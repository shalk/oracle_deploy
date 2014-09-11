#!/bin/bash

cd `dirname $0`
source ./rac_cfg_extend
source ./logging.sh
tmppwd=`pwd`
rac_pub_iplist_by_comma=$( split_list_by_comma $(rac_pub_ip_list ))
rac_pub_hostname_list_by_comma=$( split_list_by_comma $(rac_pub_hostname_list ))

#no_pass

ora_log "setup no password for root"
cd ../no_passwd/  
./xmakessh  --user root --pass  $current_passwd --nodes  $rac_pub_iplist_by_comma    >/dev/null
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
i=1
for tmpip in $(rac_pub_ip_list)
do
    ora_log "=========$tmpip prepare start=========="
    ssh $tmpip "chmod a+x  oracle_deploy -R ;cd oracle_deploy;  
    cd utility/rac/
    sh universe.sh install $i;
    sh storage.sh install;
    "
    ora_log "=========$tmpip prepare finish=========="
    ((i++))
    echo 
    echo
done 
echo
unset i

for tmpip in $(rac_pub_ip_list)
do
    scp -p -q -r /etc/shadow $tmpip:/etc/
    scp -p -q -r /etc/gshadow $tmpip:/etc/
    scp -p -q -r /etc/passwd $tmpip:/etc/
    scp -p -q -r /etc/group $tmpip:/etc/
    scp -p -q -r /home/  $tmpip:/
    #ssh $tmpip "chmod "
done

ora_log "setup no password for user grid,oracle"
cd ../no_passwd/; 
chmod a+x xmakessh
./xmakessh  --user root   --pass  $current_passwd     --nodes  $rac_pub_hostname_list_by_comma  >/dev/null
./xmakessh  --user oracle --pass  $user_oracle_passwd --nodes  $rac_pub_hostname_list_by_comma  >/dev/null
./xmakessh  --user grid   --pass  $user_grid_passwd   --nodes  $rac_pub_hostname_list_by_comma  >/dev/null
cd $tmppwd
ora_log "setup no password for user grid,oracle finish"

# make sure connect

echo "Prepare Finish"
exit 0
