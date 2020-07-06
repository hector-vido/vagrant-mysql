#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e '[client]\nuser=root\npassword=4linux' > /tmp/my.cnf

mysql --defaults-file=/tmp/my.cnf mysql -e "SELECT COUNT(*) FROM user WHERE user = 'monitor' AND host LIKE '172.27.11.%'" > /tmp/aula-1-exercicio-06.list
if [ $? -ne 0 ]; then
        echo "Não foi possível se conectar ao MySQL"
        exit 1
fi

grep '1' /tmp/aula-1-exercicio-06.list > /dev/null
if [ $? -ne 0 ]; then
	echo -e "${RED}Ops... usuário 'monitor' não encontrado.$NC"
	exit 1
else
  echo -e "${GREEN}Usuário 'monitor' encontrado!$NC"
fi

mysql -e "SHOW GRANTS FOR monitor@'172.27.11.10'" | grep PROCESS > /dev/null
if [ $? -ne 0 ]; then
	echo -e "${RED}Vish... usuário 'monitor@172.27.11.10' não possui a permissão 'PROCESS'.$NC"
	exit 1
else
  echo -e "${GREEN}Usuário 'monitor' está com a permissão 'PROCESS'!$NC"
fi

mysql -e "SHOW DATABASES" | grep monitoring > /dev/null
if [ $? -ne 0 ]; then
	echo -e "${RED}Ué... a base 'monitoring' não foi encontrada.$NC"
	exit 1
else
  echo -e "${GREEN}Base 'monitoring' encontrada!$NC"
fi

mysql mysql -e "SELECT DISTINCT User 'Role Name', if(from_user is NULL,0, 1) Active 
       FROM mysql.user LEFT JOIN role_edges ON from_user=user 
       WHERE account_locked='Y' AND password_expired='Y' AND authentication_string=''" | grep monitoring > /dev/null
if [ $? -ne 0 ]; then
	echo -e "${RED}Vish... a role 'monitoring' não foi encontrada.$NC"
	exit 1
else
  echo -e "${GREEN}Role 'monitoring' encontrada!$NC"
fi

cat > /tmp/aula-1-exercicio-06.sql <<EOF
SELECT CONCAT(user, '@', host) INTO @user FROM user WHERE user = 'monitor' AND host LIKE '172.27.11.%';
SET @query = CONCAT('SHOW GRANTS FOR ', @user);
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
EOF

mysql mysql < /tmp/aula-1-exercicio-06.sql | grep monitoring > /dev/null
if [ $? -ne 0 ]; then
	echo -e "${RED}Oh oh... a role 'monitoring' não foi atribuida ao usuário 'monitor'.$NC"
	exit 1
else
  echo -e "${GREEN}Usuário 'monitor' com a role 'monitoring'!$NC"
fi

IP=$(ip a | grep -Eo 172.27.11.1[0-9])
mysql -h "$IP" -u monitor -p4linux monitoring -e "CREATE TABLE IF NOT EXISTS t$RANDOM (id INT AUTO_INCREMENT PRIMARY KEY)" > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo -e "${RED}Eita... o usuário 'monitor' não conseguiu acessar a base 'monitoring'.$NC"
	exit 1
else
  echo -e "${GREEN}Usuário 'monitor' acessou a base 'monitoring'!$NC"
fi

mysql -h "$IP" -u monitor -p4linux monitoring -e "SHOW PROCESSLIST" > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo -e "${RED}Negativo... o comando 'SHOW PROCESSLIST' não funcionou.$NC"
	exit 1
else
  echo -e "${GREEN}Usuário 'monitor' executou 'SHOW PROCESSLIST'!$NC"
fi

