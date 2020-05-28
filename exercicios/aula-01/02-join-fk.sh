#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e '[client]\nuser=root\npassword=4linux' > /tmp/my.cnf

mysql --defaults-file=/tmp/my.cnf curso -e 'DESCRIBE usuarios_infos' > /tmp/aula-1-exercicio-02.list
if [ $? -ne 0 ]; then
	echo "Não foi possível se conectar ao MySQL"
	exit 1
fi

for X in usuario_id sexo curriculo; do
	FOUND=0
	while read LINE; do
		COLUNA=$(echo $LINE | cut -d' ' -f1)
		if [ $COLUNA == $X ]; then
			FOUND=1
		fi
	done < /tmp/aula-1-exercicio-02.list
	if [ $FOUND -eq 0 ]; then
		echo -e "${RED}Ops... a coluna '$X' não foi encontrada.$NC"
		exit 1
	else
		echo -e "${GREEN}Coluna $X encontrada!$NC"
	fi
done

mysql --defaults-file=/tmp/my.cnf curso -e 'SHOW CREATE TABLE usuarios_infos' > /tmp/aula-1-exercicio-02.list
if [ $? -ne 0 ]; then
	echo "Não foi possível se conectar ao MySQL"
	exit 1
fi

grep -qE 'FOREIGN KEY.*usuario_id.*REFERENCES.*usuarios.*id.*' /tmp/aula-1-exercicio-02.list

if [ $? -ne 0 ]; then
	echo -e "${RED}Ops... a chave estrangeira de usuarios_infos.usuario_id -> usuario.id não foi encontrada.$NC"
	exit 1
fi

echo -e "${GREEN}##########################################################"
echo -e "# Parabéns! Todas as colunas e chaves foram encontradas! #"
echo -e "##########################################################${NC}"
