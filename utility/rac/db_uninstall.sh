#su - oracle  
#exit 1;


> /tmp/db_uninstall.sh
cat >> /tmp/db_uninstall.sh <<EOF
cd  \${ORACLE_HOME}/deinstall
mkdir -p abc
echo -e '\n' | ./deinstall -checkonly -o \${ORACLE_HOME}/deinstall/abc
Filename=\`ls abc/*\`
./deinstall -silent -paramFile \${ORACLE_HOME}/deinstall/\${Filename}
EOF
chmod 777 /tmp/db_uninstall.sh

su - oracle -c '/tmp/db_uninstall.sh'
