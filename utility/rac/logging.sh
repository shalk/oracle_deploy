#!/bin/bash

ora_log(){

    printf  "%b" "[INFO] $*\n"
}
ora_err(){

    printf  "%b" "\033[40;31m[ERROR]\033[0m $*\n"
}
