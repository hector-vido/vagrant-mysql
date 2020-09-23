#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e '[client]\nuser=root\npassword=4linux' > /tmp/my.cnf

mysql --defaults-file=/tmp/my.cnf curso -e 'DESCRIBE sales' > /tmp/aula-1-exercicio-01.list
if [ $? -ne 0 ]; then
	echo "Não foi possível se conectar ao MySQL"
	exit 1
fi

for X in id region country type channel priority order_date oid ship_date sold price cost total_revenue total_cost total_profit; do
	FOUND=0
	while read LINE; do
		COLUNA=$(echo $LINE | cut -d' ' -f1)
		if [ $COLUNA == $X ]; then
			FOUND=1
		fi
	done < /tmp/aula-1-exercicio-01.list
	if [ $FOUND -eq 0 ]; then
		echo -e "${RED}Ops... a coluna "$X" não foi encontrada.$NC"
		exit 1
	else
		echo -e "${GREEN}Coluna $X encontrada!$NC"
	fi
done

echo -e "${GREEN}#################################################"
echo -e "# Parabéns! Todas as colunas foram encontradas! #"
echo -e "#################################################${NC}"

echo 'Contando o número de registros...'
sleep 1
N=$(mysql --defaults-file=/tmp/my.cnf curso -e "SELECT COUNT(*) as '' FROM sales" | tr -d '[:space:]')

if [ "$N" -ge "1500000" ]; then
	echo -e "${GREEN}####################################################"
	echo -e "# Um milhão e meio de registros foram encontradas! #"
	echo -e "####################################################${NC}"
else

	echo -e "${RED}Ops... menos de 1.500.000 registros encontrados.$NC"
	exit 1
fi
