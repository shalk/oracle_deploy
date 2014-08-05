#!/bin/bash

cd `dirname $0`

prepare(){
    sh prepare.sh
}
grid_install(){
    sh grid_install.sh
}
asmca_install(){
    sh asmca_install.sh
}
db_install(){
    sh db_install.sh
}
dbca_install(){
    sh dbca_install.sh
}
rac_uninstall(){
   sh dbca_uninstall.sh  &&   sh db_uninstall.sh && sh asmca_uninstall.sh && sh grid_uninstall.sh
}
rac_usage(){
   sh rac_usage
}


opt=$1
shift
case $1 in 
    -preOpt)
        prepare
        ;;
    -grid)
        grid_install
    ;;
    -asmca)
        asmca_install
    ;;
    -dbInstall)
        db_install
    ;;
    -dbca)
        dbca_install
    ;;
    -all)
        prepare
        grid_install
        asmca_install
        db_install
        dbca_install
    ;;
    -uninstall)
        rac_uninstall
    ;;
    *)
    rac_usage
    ;;
esac
