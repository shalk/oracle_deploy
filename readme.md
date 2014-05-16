rac 安装
=======

1. 填写好ip_map

        12.12.12.1	node1
        12.12.12.2	node2
        12.12.12.3	node1-vip
        12.12.12.4	node2-vip
        10.10.10.1	node1-priv
        10.10.10.2	node2-priv
        12.12.12.5	racsan
2.  网络通畅


3， node1上执行 
        
        $./install

    即完成准备工作

4

单机安装
=====

1. 执行

        cd utility/standalone/; sh oracle_deploy.sh

2. 安装数据库软件

        su - oracle
        cd /home/oracle
        unzip p10404530_112030_Linux-x86-64_1of7.zip
        unzip p10404530_112030_Linux-x86-64_2of7.zip
        chown –R oracle:oinstall database/
        cd  database
         ./runInstaller

3. 配置监听 GUI

        netca

4. 创建数据库 GUI

        dbca

5. 执行

        sqlplus / as sysdba <<EOF
        select instance_name,status from v\$instance;
        create user tpcc identified by tpcc;
        grant dba to tpcc;
        drop user tpcc;
        EOF

