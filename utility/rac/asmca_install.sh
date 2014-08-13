

cd `dirname $0`
source rac_cfg_extend

su - grid -c "asmca  -silent -sysAsmPassword $grid_sysasm_passwd  -asmsnmpPassword $grid_monitor_passwd  -createDiskGroup -diskString '${asmca_diskstring}'  -diskGroupName $asmca_groupname  -diskList '$asmca_disklist' -redundancy $asmca_redunt "
