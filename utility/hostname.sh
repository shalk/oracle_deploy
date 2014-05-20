#!/bin/bash
cd `dirname $0`
your_host=$1
export HOSTNAME=$your_host
hostname $your_host
 [ -f /etc/sysconfig/network ] &&  perl -p -i -e "s/HOSTNAME.*/HOSTNAME=$your_host/" /etc/sysconfig/network
 [ -f /etc/HOSTNAME ] && echo $your_host > /etc/HOSTNAME

