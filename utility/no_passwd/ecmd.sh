#!/bin/bash

expfile=${expfile:-"cmd.exp"}
outexpfile=/tmp/$expfile.$$

cd ${0%/*}

if [[ ! -f "$expfile" ]] ; then
   echo no temp file
   exit 1
fi

T_PASS=${PASS:-"111111"}

echo spawn "$@" > $outexpfile
sed "s/THE_PASSWORD/$T_PASS/" $expfile >> $outexpfile

/usr/bin/expect $outexpfile

RM=$?

rm -r $outexpfile

exit $RM

