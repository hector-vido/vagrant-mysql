#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e '[client]\nuser=root\npassword=4linux' > /tmp/my.cnf

mysql --defaults-file=/tmp/my.cnf curso -e 'DESCRIBE planetas' > /tmp/aula-2-exercicio-02.list
if [ $? -ne 0 ]; then
	echo "Não foi possível se conectar ao MySQL"
	exit 1
fi

for X in id nome diametro satelites; do
	FOUND=0
	while read LINE; do
		COLUNA=$(echo $LINE | cut -d' ' -f1)
		if [ $COLUNA == $X ]; then
			FOUND=1
		fi
	done < /tmp/aula-2-exercicio-02.list
	if [ $FOUND -eq 0 ]; then
		echo -e "${RED}Ops... a coluna "$X" não foi encontrada.$NC"
		exit 1
	else
		echo -e "${GREEN}Coluna $X encontrada!$NC"
	fi
done

echo -e "${GREEN}#################################################"
echo -e "# Parabéns! Todas as colunas foram encontradas! #"
echo -e "#################################################${NC}\n"


mysql --defaults-file=/tmp/my.cnf curso -e 'SELECT nome FROM planetas' > /tmp/aula-2-exercicio-02.list
for X in Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto; do
	FOUND=0
	while read LINE; do
		COLUNA=$(echo $LINE | cut -d' ' -f1)
		if [ $COLUNA == $X ]; then
			FOUND=1
		fi
	done < /tmp/aula-2-exercicio-02.list
	if [ $FOUND -eq 0 ]; then
		echo -e "${RED}Ops... o planeta '$X' não foi encontrada.$NC"
		exit 1
	else
		echo -e "${GREEN}Planeta $X encontrada!$NC"
	fi
done

echo -e "${GREEN}#########################################"
echo -e "# Parabéns! Todas os planetas estão aí! #"
echo -e "#########################################${NC}"
