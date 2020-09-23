#!/bin/bash

history -a

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e '[client]\nuser=root\npassword=4linux' > /tmp/my.cnf

mysql --defaults-file=/tmp/my.cnf curso -e 'DESCRIBE usuarios' > /tmp/aula-1-exercicio-01.list
if [ $? -ne 0 ]; then
	echo "Não foi possível se conectar ao MySQL"
	exit 1
fi

for X in 'id,int' 'nome,varchar' 'email,varchar' 'nascimento,date' 'profissao,varchar'; do
  COLUNA=$(echo "$X" | cut -d, -f1)
  TIPO=$(echo "$X" | cut -d, -f2)
  grep -E "^$COLUNA.*$TIPO" /tmp/aula-1-exercicio-01.list > /dev/null  
	if [ "$?" -ne "0"  ]; then
		echo -e "${RED}Ops... a coluna $COLUNA não foi encontrada.$NC"
		exit 1
	else
		echo -e "${GREEN}Coluna $COLUNA encontrada!$NC"
	fi
done

grep -Ei 'ALTER.*TABLE.*usuarios.*COLUMN.*status.*INT' /root/.mysql_history > /dev/null
MH="$?"
grep -Ei 'ALTER.*TABLE.*usuarios.*COLUMN.*status.*INT' /root/.bash_history > /dev/null
BH="$?"

if [ "$MH" -ne "0" ] && [ "$BH" -ne "0" ]; then
	echo -e "${RED}Ops... o comando para criação da coluna status não foi encontrado.$NC"
	exit 1
else
	echo -e "${GREEN}Comando para criação da coluna encontrado!$NC"
fi

grep -E "^status.*int" /tmp/aula-1-exercicio-01.list > /dev/null  
if [ "$?" -ne "0"  ]; then
	echo -e "${RED}Ops... a coluna status não foi encontrada.$NC"
	exit 1
else
	echo -e "${GREEN}Coluna status encontrada!$NC"
fi

mysql --defaults-file=/tmp/my.cnf curso -e \
"SELECT * FROM usuarios WHERE nome = 'Paramahansa Yogananda' AND email = 'paramahansa@yogananda.in' AND nascimento = '1893-01-05' AND profissao = 'Yogi' AND status = 1" | \
grep -i paramahansa > /dev/null 2>&1
if [ "$?" -ne "0"  ]; then
	echo -e "${RED}Ops... o usuário Paramahansa Yogananda não foi encontrado.$NC"
	exit 1
else
	echo -e "${GREEN}Usuário Paramahansa Yogananda encontrada!$NC"
fi

mysql --defaults-file=/tmp/my.cnf curso -e \
"SELECT * FROM usuarios WHERE nome = 'Jiddu Krishnamurti' AND email = 'jiddu@krishnamurti.in' AND nascimento = '1895-05-11' AND profissao = 'Professor do Mundo' AND status = 1" | \
grep -i jiddu > /dev/null 2>&1
if [ "$?" -ne "0"  ]; then
	echo -e "${RED}Ops... o usuário Jiddu Krishnamurti não foi encontrado.$NC"
	exit 1
else
	echo -e "${GREEN}Usuário Jiddu Krishnamurti encontrada!$NC"
fi

echo -e "\n${GREEN}Parabéns! Todas as colunas e registros foram encontrados!$NC"
