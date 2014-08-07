#!/bin/bash
cd `dirname $0`
source ../../rac.cfg
source logging.sh


ora_log "asmca uninstall umount $asmca_groupname "
su - grid -c "                  
ssh rac2 'source .bash_profile ; asmcmd umount  $asmca_groupname '
asmcmd dropdg -r $asmca_groupname
"                                               
ora_log "asmca uninstall umount $asmca_groupname  finish"
