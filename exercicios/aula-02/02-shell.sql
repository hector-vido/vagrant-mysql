CREATE TABLE planetas (
	id INT PRIMARY KEY AUTO_INCREMENT,
	nome VARCHAR(50),
	diametro FLOAT(8,2),
	satelites TINYINT
);

#!/bin/bash

IFS=','
while read NOME DIAMETRO A B C D E F G SATELITES; do
        mysql curso -e "INSERT INTO planetas (nome, diametro, satelites) VALUES ('$NOME', '$DIAMETRO', '$SATELITES')"
        if [ $? -ne 0 ]; then
                echo "INSERT INTO planetas (nome, diametro, satelites) VALUES ('$NOME', '$DIAMETRO', '$SATELITES')"
                exit 1
        fi
done < planetas.csv
