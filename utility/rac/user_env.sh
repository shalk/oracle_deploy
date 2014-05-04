
cat >>/home/oracle/.bash_profile <<EOF
ORACLE_SID=+ASM1; export ORACLE_SID 
ORACLE_BASE=/oracle/app/grid; export ORACLE_BASE 
ORACLE_HOME=/home/grid/product/11.2.0; export ORACLE_HOME
PATH=\$ORACLE_HOME/bin:\$PATH; export PATH 
LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
EOF

cat >>/home/grid/.bash_profile <<EOF
ORACLE_BASE=/oracle/app/oracle; export ORACLE_BASE 
ORACLE_HOME=\$ORACLE_BASE/product/11.2.0; export ORACLE_HOME 
ORACLE_SID=rac1; export ORACLE_SID
PATH=\$ORACLE_HOME/bin:\$PATH; export PATH 
LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
EOF

