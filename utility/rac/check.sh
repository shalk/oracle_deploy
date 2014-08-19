#!/bin/bash
cd `dirname $0`
source ./rac_cfg_extend

echo "bdbf8e263663214dc60b0fdef5a30b0a  /database/p10404530_112030_Linux-x86-64_1of7.zip" | md5sum -c 
if [[ $? != 0 ]];then
    echo " p10404530_112030_Linux-x86-64_1of7.zip  is not correct file"
    exit 1
fi
echo "e56b3d9c6bc54b7717e14b6c549cef9e  /database/p10404530_112030_Linux-x86-64_2of7.zip" | md5sum -c
if [[ $? != 0 ]];then
    echo " p10404530_112030_Linux-x86-64_2of7.zip  is not correct file"
    exit 1
fi
echo "695cbad744752239c76487e324f7b1ab  /database/p10404530_112030_Linux-x86-64_3of7.zip" | md5sum -c
if [[ $? != 0 ]];then
    echo " p10404530_112030_Linux-x86-64_3of7.zip  is not correct file"
    exit 1
fi
