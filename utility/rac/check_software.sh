#!/bin/bash
cd `dirname $0`

check_grid(){
    cd $software_path  || { ora_err "dir($software_path) is not exists"  ; exit 1 ; }
    [ -f $grid_softname ] || { ora_err "file($grid_softname) is not exists" ; exit 1 ;}
    echo "bdbf8e263663214dc60b0fdef5a30b0a $grid_softname" |  md5sum -c  || { ora_err "file ($grid_softname) md5 is not correct"; exit 1} 
    exit 0
}
check_oracle(){
    cd $software_path  || { ora_err "dir($software_path) is not exists"  ; exit 1 ; }
    [ -f $oracle_softname1 ] || { ora_err "file($oracle_softname1) is not exists" ; exit 1 ;}
    [ -f $oracle_softname2 ] || { ora_err "file($oracle_softname2) is not exists" ; exit 1 ;}
    echo "e56b3d9c6bc54b7717e14b6c549cef9e $oracle_softname1" |  md5sum -c  || { ora_err "file ($oracle_softname1) md5 is not correct"; exit 1} 
    echo "695cbad744752239c76487e324f7b1ab $oracle_softname2" |  md5sum -c  || { ora_err "file ($oracle_softname2) md5 is not correct"; exit 1} 
    exit 0
}

