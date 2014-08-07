#Oracle_Deploy#


This project can install Oracle 11gR2 in silent mode.
It contains two Parts : Rac(Real Application Cluster) and StandAlone .


##SYSNOPSIS##
        





##StandAlone(单机)##


Usage：
        
        cd utility/standalone/; 
        sh oracle_deploy.sh
        
        

##RAC Installment##

###前提###


> OS：Two nodes with SUSE 11SP2 <br>
> Network：two Ethernet interface cards，eth0 and eth1 ，DNS for racscan <br>
> Storage：iscsi



###用法###

1. modify `ip_map` for network  

        12.12.12.1  rac1
        12.12.12.2  rac2
        12.12.12.3  rac1-vip
        12.12.12.4  rac2-vip
        10.10.10.1  rac1-priv
        10.10.10.2  rac2-priv
        12.12.12.5  racsan

2. modify `o.conf` for all configuration  
        
        #universe

        grid_oracle_base='/oracle/app/grid' 
        grid_oracle_home='/oracle/app/product/11.2.0'
        
        oracle_oracle_base='/oracle/app/oracle'
        oracle_oracle_home='/oracle/app/oracle/product/11.2.0'
        oracle_sid_prefix='sugon'
        
        
        #software
        software_path='/database'
        grid_softname='p10404530_112030_Linux-x86-64_3of7.zip'
        oracle_softname1='p10404530_112030_Linux-x86-64_1of7.zip'
        oracle_softname2='p10404530_112030_Linux-x86-64_2of7.zip'
        
        
        #for grid
        grid_rsp_file='/tmp/grid_clean.rsp'
         #grid parameter for rsp
        grid_hostname='rac1'
        grid_scanname='racscan'
        grid_cluster_node='rac1:rac1-vip,rac2:rac2-vip'
        grid_network_interface='eth0:10.5.0.0:1,eth1:1.1.1.0:2'         # <========modify it
        grid_sysasm_passwd='Oracle_123'
        grid_monitor_passwd='Oracle_123'
        grid_disk_list='/dev/raw/raw1,/dev/raw/raw2,/dev/raw/raw3'      # <========modify it
        grid_disk_redunt='NORMAL'
        grid_diskgroup_name='CRS'
        grid_disk_ausize='1'
        
        
        
        #for db
        oracle_rsp_file='/tmp/db_clean.rsp'
         #oracle parameter for rsp
        oracle_db_hostname='rac1'
        oracle_db_clusternode='rac1,rac2'
        
        
        #for asmca
        asmca_diskstring='/dev/raw/*'                                   # <========modify it
        asmca_groupname='DATA'                                          # <========modify it
        asmca_disklist='/dev/raw/raw4,/dev/raw/raw5'                    # <========modify it
        asmca_redunt='NORMAL'                                           # <========modify it
        
        
        #for dbca
        dbca_sys_passwd='oracle_123'
        dbca_system_passwd='oracle_123'
        dbca_disk_groupname='DATA'
        dbca_nodelist='rac1,rac2'
        dbca_characterset='ZHS16GKB'
        dbca_national_characterset='UTF8'

2. put software under `/database` directory
        
        -rwxrwxrwx 1 root root 1358454646  p10404530_112030_Linux-x86-64_1of7.zip
        -rwxrwxrwx 1 root root 1142195302  p10404530_112030_Linux-x86-64_2of7.zip
        -rwxrwxrwx 1 root root  979195792  p10404530_112030_Linux-x86-64_3of7.zip


3. On `rac1` prepare system confiuration  and storage configuration 
        
        $ cd oracle_deploy
        $ perl install

4. Execute each phase one by one,

        $ cd oracle_deploy/utility/rac
        
        #  Please inpute Enter  after Each installment finished,don't do this too early

        $ ./grid_install.sh 
    
        $ ./asmca_install.sh
    
        $ ./db_install.sh
    
        $ ./dbca_instal.sh
To be on the safe side，you can extract grid
    ` ./runcluvfy.sh stage -pre crsinst -n rac1,rac2 -verbose` before  execute script.

##Mess up?

Take it easy<br>
Just use `grid_uninstall.sh`，`asmca_uninstall.sh`,`db_uninstall.sh`,`dbca_uninstall.sh`




##Reference##

[Oracle 11g R2 Official Document]([http://docs.oracle.com/cd/E11882_01/index.htm)

Many blog acticles for trouble shoting.

Docs from hxx

Thanks for [Google](http://www.google.com.hk) and [StackOverFlow](http://stackoverflow.com)
