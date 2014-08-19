#!/bin/bash
cd `dirname $0`
source ./rac_cfg_extend

su - grid -c 'cd  $ORACLE_HOME/deinstall; ./deinstall'
for tmpnode in `rac_pub_hostname_list`
do
    ssh $tmpnode "rm -rf /etc/oraInst.loc; rm -rf /opt/ORCLfmap"
done

