#!/bin/bash

cd `dirname $0`

prepare(){
    sh prepare.sh
}
grid_install(){
    sh grid_install.sh
}
grid_uninstall(){
    sh grid_uninstall.sh
}
asmca_install(){
    sh asmca_install.sh
}
asmca_uninstall(){
    sh asmca_uninstall.sh
}
db_install(){
    bash  db_install.sh
}
db_uninstall(){
    sh db_uninstall.sh
}
dbca_install(){
    sh dbca_install.sh
}
dbca_uninstall(){
    sh dbca_uninstall.sh
}
rac_usage(){
   sh rac_usage
}


opt=$1
shift
case $opt in 
    -preOpt)
        prepare
        ;;
    -grid)
        grid_install
    ;;
    -un_grid)
        grid_uninstall
    ;;
    -asmca)
        asmca_install
    ;;
    -un_asmca)
        asmca_uninstall
    ;;
    -dbInstall)
        db_install
    ;;
    -un_db)
        db_uninstall
    ;;
    -dbca)
        dbca_install
    ;;
    -un_dbca)
        dbca_uninstall
    ;;
    -all)
        prepare
        grid_install
        asmca_install
        db_install
        dbca_install
    ;;
    -uninstall)
        dbca_uninstall
        db_uninstall
        asmca_uninstall
        grid_uninstall
    ;;
    *)
    rac_usage
    ;;
esac
