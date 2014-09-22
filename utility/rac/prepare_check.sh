#!/bin/bash
cd `dirname $0`

source ./rac_cfg_extend
source ./logging.sh
RET=0
check_ip_format(){
    local ip=$1
    stat=1
    if [ -z $ip ]  ; then
        return $stat 
    fi
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        iplist=($ip)
        IFS=$OIFS
        [[ ${iplist[0]} -le 255 && ${iplist[1]} -le 255 \
        && ${iplist[2]} -le 255 && ${iplist[3]} -le 255 ]]
        stat=$?
    fi
    [ ${stat} -eq 0 ] || echo "input $ip is ilegal, IP format is  xx.xx.xx.xx  (xx < 255)"
    [ ${stat} -eq 0 ] || return 2
}
check_eth_ip_match(){
    local eth=$1
    local ip=$2
    local stat=1
    if [ -z $ip ] || [ -z $eth ] ; then
        echo "[func:check_eth_ip_match] Miss arg "
        return $stat
    fi
    tmpip=`ifconfig $eth | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
    if [ "X$tmpip" !=  "X$ip" ] ; then
        ora_err "ip( $ip) is not configured on interface ($eth) ! "
    else
        stat=0
    fi
    unset tmpip
    return $stat
}

check_ip_link(){
    ip=$1
    wantstat=${2:-link}
    stat=1
    if [ -z $ip ]  ; then
        return $stat 
    fi
    if  ping $ip -c 2  >& /dev/null  ; then
        stat=0
    else
        stat=2
    fi
    # want link   but can not ping 
    if [ "X$wantstat" == "Xlink" ] && [ $stat -eq 2  ]
    then
        ora_err "( $ip ) can not ping !  "
    fi
    # want no link but can ping 
    if [ "X$wantstat" == "Xnolink" ]  && [ $stat -eq 0  ]
    then
        ora_err "( $ip ) is occupied !  "
    fi

    return $stat
}

check_disk_miss()
{
    disk=$1
    stat=1
    if [ -z $disk ] ; then
        return $stat 
    fi
    if [ -b $disk ] ; then
        stat=0
    else
        ora_err "Disk ( $disk )is not exists"
        stat=2
    fi
    return $stat
    
}
get_ip_from_eth(){
    local eth=$1
    echo $( ifconfig $eth 2>/dev/null | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}' )
}

get_mask_form_eth(){
    local eth=$1
    echo $( ifconfig $eth 2>/dev/null | grep "inet addr" | awk -F: '{print $NF}' )
}
check_subnet()
{
    local eth=$1
    local subnet=$2
    local stat=1
    local ip=$(get_ip_from_eth $eth)
    local netmask=$(get_mask_form_eth $eth)

    local local_subnet=`perl calc_subnet.pl $ip $netmask` 
    if [[ $local_subnet != $subnet ]]
    then
        ora_err "subnet($subnet) is not correct,the actual subnet is ($local_subnet)"
        ora_err "Please Check each node for the same subnet "
        stat=2
    else
        stat=0
    fi
    return $stat
}

#step 1 check rac.cfg status
bash -u ../../rac.cfg 
if [ $? != 0 ]
then
    ora_err "Please  modify rac.cfg correctly "
    exit 1
fi

#step 2 check public ip
for ip in $(rac_pub_ip_list) 
do
    check_ip_format $ip || RET=1
#    check_eth_ip_match $public_eth  $ip || RET=1
    check_ip_link  $ip || RET=1
done
check_eth_ip_match $public_eth  $rac1_ip || RET=1

for ip in $(rac_vip_list) 
do
    check_ip_format $ip || RET=1
    check_ip_link  $ip  nolink && RET=1
done

for ip in $(rac_priv_ip_list) 
do
    check_ip_format $ip || RET=1
#    check_eth_ip_match $priv_eth  $ip || RET=1
    check_ip_link  $ip ||  RET=1
done
check_eth_ip_match $priv_eth  $rac1_priv_ip || RET=1


tmpip=$racscan_ip
check_ip_format $tmpip || RET=1
check_ip_link  $tmpip nolink && RET=1
unset tmpip

check_ip_format $public_subnet || RET=1
check_ip_format $priv_subnet   || RET=1
check_subnet $public_eth $public_subnet   || RET=1
check_subnet $priv_eth   $priv_subnet     || RET=1

# step 3 check disk 
for disk in $(rac_data_disk_list)
do 
    check_disk_miss $disk || RET=1
done

for disk in $(rac_crs_disk_list)
do 
    check_disk_miss $disk || RET=1
done


exit $RET
