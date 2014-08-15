#Oracle_Deploy#


This project can install Oracle 11gR2 in silent mode.
It contains two Parts : Rac(Real Application Cluster) and StandAlone .


##SYNOPSIS##

    #prepare enviroment
    oraInst single   -preOpt      
    oraInst single   -dbInstall   install software only
    oraInst single   -netca       setup listener
    oraInst single   -dbca        create database instance
    oraInst single   -all         install oracle all in one opt.
    oraInst single   -uninstall   uninstall oracle database 
    oraInst single   -h           help for  <oraInst single>   Command
    
    oraInst rac   -preOpt         enviroment prepare : setup user for oracle ,build ssh equivalent,create directory for oralce and so on .
    oraInst rac   -grid           install grid software
    oraInst rac   -asmca          create asm diskgroup for oracle data 
    oraInst rac   -dbInstall      install database software only
    oraInst rac   -dbca           create oracle database instance. 
    oraInst rac   -all            install oracle all in one parameter . 
    oraInst rac   -uninstall      uninstall a complete oracle rac, uninstall dbca,db,asmca,grid one by one .
    oraInst rac   -h              help for <oraInst rac> Command          


##StandAlone Installment##

###Need###

> A Server with SUSE11SP2(select all rpm) , config a ip.

###Usage###

 
1. upload oracle  media zip  to /database directory

        p10404530_112030_Linux-x86-64_1of7.zip bdbf8e263663214dc60b0fdef5a30b0a
        p10404530_112030_Linux-x86-64_2of7.zip e56b3d9c6bc54b7717e14b6c549cef9e
    

2. upload oracle deploy and extract it

        eg:
        tar zxvf oracle_deplpy-master.tar.gz
    
3. modify `single.cfg` for oracle configuration

        cd oracle_deploy
        vim single.cfg
    
        ip='192.168.132.128'               <=========== modify it 
        hostname='node1'                   <=========== modify it 
        
        software_path='/database'
        oracle_softname1='p10404530_112030_Linux-x86-64_1of7.zip'
        oracle_softname2='p10404530_112030_Linux-x86-64_2of7.zip'
        oracle_soft1_md5="bdbf8e263663214dc60b0fdef5a30b0a"
        oracle_soft2_md5="e56b3d9c6bc54b7717e14b6c549cef9e"
        oracle_user_passwd="111111"
        
        oracle_oracle_base="/u01/app/oracle"
        oracle_oracle_home="/u01/app/oracle/product/11.2.0/db_1"
        oracle_sid="orcl"
        oracle_ld_lib_path="/u01/app/oracle/product/11.2.0/db_1/lib"
4. execute the command

        oraInst single -all




##RAC Installment##

###Need###


> OS：Two nodes with SUSE 11SP2 (with all rpm selected)<br>
> Network：two Ethernet interface cards<br> 

     RAC    Public ip   Private ip  Virtual ip   Scanip
     rac1   10.5.101.1  1.1.1.1     10.5.101.3   10.5.101.100
     rac2   10.5.101.2  1.1.1.2     10.5.101.4  

    Public  subnet  10.5.101.0
    Private subnet  1.1.1.0     
    Public  eth     eth0
    Private eth     eth1
                    
- `public ip` use one ethernet interface
- `private ip` use another ethernet interface
- you should configure pub-ip and pri-ip on each node with coincide eth.
- `vip-ip` should not configure it，but need `preserve it`. `vip-ip` and `pub-ip` are in  the same subnet.
- `scan-ip` should not configure it，but need `preserve it`. `scan-ip` and `pub-ip` are in  the same subnet.(only support one scan ip)


> Storage：iscsi or something else ;

    Five LUN/Disk/Vol   
    3 Lun  for OCR and VOTE . bigger than 1G
    2 Lun  for store database.  
- you should have configure multipath(if needed) , the same disk name on each node,the name should not changed after reboot.
-  each shared disk should be the same disk 
speed and size



###Usage###

 
1. upload oracle  media zip  to /database directory

        p10404530_112030_Linux-x86-64_1of7.zip bdbf8e263663214dc60b0fdef5a30b0a
        p10404530_112030_Linux-x86-64_2of7.zip e56b3d9c6bc54b7717e14b6c549cef9e
        p10404530_112030_Linux-x86-64_3of7.zip 695cbad744752239c76487e324f7b1ab
2. upload oracle deploy and extract it

        eg:
        tar zxvf oracle_deplpy-master.tar.gz

3. modify `rac.cfg` for rac configuration

		
		
		current_passwd='111111'
		rac_node_num=2
		
		####################Network####################
		#public ip
		public_subnet='10.5.0.0'            <========= modify it
		public_eth='eth0'                   <========= modify it
		rac1_ip='10.5.101.20'               <========= modify it
		rac2_ip='10.5.101.21'               <========= modify it
		#rac3_ip='10.5.101.22'
		#rac4_ip='10.5.101.23'
		
		#priv_ip
		priv_subnet='10.10.11.0'            <========= modify it
		priv_eth='eth1'                     <========= modify it
		rac1_priv_ip='10.10.11.20'          <========= modify it
		rac2_priv_ip='10.10.11.21'          <========= modify it
		#rac3_priv_ip='10.10.10.22'
		#rac4_priv_ip='10.10.10.23'
		
		
		#virtual ip
		rac1_vip='10.5.101.103'             <========= modify it
		rac2_vip='10.5.101.104'             <========= modify it
		#rac3_vip='10.5.101.103'
		#rac4_vip='10.5.101.104'
		
		#scan ip
		racscan_ip='10.5.101.100'           <========= modify it
		#hostname
		rac1_pub_hostname='rac1'             
		rac1_priv_hostname='rac1-priv'          
		rac1_virtual_hostname='rac1-vip'       
		rac2_pub_hostname='rac2'              
		rac2_priv_hostname='rac2-priv'         
		rac2_virtual_hostname='rac2-vip'       
		
		#rac3_pub_hostname='rac3'
		#rac3_priv_hostname='rac3-priv'
		#rac3_virtual_hostname='rac3-vip'
		#rac4_pub_hostname='rac4'
		#rac4_priv_hostname='rac4-priv'
		#rac4_virtual_hostname='rac4-vip'
		scanip_hostname='racscan'
		#################################################
		
		#################### Storage ####################
		raw1='/dev/disk/by-id/scsi-eda75d95bf5'          <========= modify it
		raw2='/dev/disk/by-id/scsi-172221d171a'          <========= modify it
		
		raw3='/dev/disk/by-id/scsi-502c2555dcc'          <========= modify it
		raw4='/dev/disk/by-id/scsi-cbdd54acde8'          <========= modify it
		raw5='/dev/disk/by-id/scsi-a0c82d7bff6'          <========= modify it
		# or 
		#
		#raw1='/dev/mapper/vol-123'
		#raw2='/dev/mapper/vol-112'
		#raw3='/dev/mapper/vol-113'
		#
		#raw4='/dev/mapper/vol-114'
		#raw5='/dev/mapper/vol-115'
		#
		
		##################################################
		
		
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
		
		############ oracle parameter #################
		#for grid
		grid_sysasm_passwd='Oracle_123'
		grid_monitor_passwd='Oracle_123'
		grid_disk_list='/dev/raw/raw1,/dev/raw/raw2,/dev/raw/raw3'
		grid_disk_redunt='NORMAL'
		grid_diskgroup_name='CRS'
		grid_disk_ausize='1'
		
		#for asmca
		asmca_diskstring='/dev/raw/*'
		asmca_groupname='DATA'
		asmca_disklist='/dev/raw/raw4,/dev/raw/raw5'
		asmca_redunt='NORMAL'
		#for db
		
		#for dbca
		dbca_sys_passwd='oracle_123'
		dbca_system_passwd='oracle_123'
		dbca_disk_groupname='DATA'
		dbca_characterset='ZHS16GKB'
			#for English  dbca_characterset='AL32UTF8'
		dbca_national_characterset='UTF8'
     


4. Execute each phase one by one,

        $ cd oracle_deploy

        $ oraInst rac -preOpt
    
        $ oraInst rac -grid
    
        $ oraInst rac -asmca
    
        $ oraInst rac -dbInstall
        
        $ oraInst rac -dbca
        
        if you make sure that 
        your OS system,network ,storage and cfg file configure satifiy the RAC condition. you can only execute this.

        $ oraInst rac -all

To be on the safe side，you can extract grid
    ` ./runcluvfy.sh stage -pre crsinst -n rac1,rac2 -verbose` before  execute script.

##Mess up?

Take it easy<br>
There are many uninstall options
            
      oraInst  rac    -un_dbca      uninstall oracle database instance.
      oraInst  rac    -un_db        uninstall oracle database software
      oraInst  rac    -un_asmca     drop oracle data diskgroup
      oraInst  rac    -un_grid      uninstall grid software
      oraInst  rac    -uninstall    uninstall a complete rac.It will uninstall dbca,db,asmca grid one by one.
        
      oraInst  single -uninstall    uninstall oracle database




##Reference##

[Oracle 11g R2 Official Document]([http://docs.oracle.com/cd/E11882_01/index.htm)

Many blog acticles for trouble shoting.

Docs from hxx

Thanks for mashj's advises.

Thanks for [Google](http://www.google.com.hk) and [StackOverFlow](http://stackoverflow.com)

##END##
