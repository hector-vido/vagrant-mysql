#!/bin/bash
# Hector Vido Silva - versão 0.1
# Script para facilitar o teste e a recuperação PITR - Point in Time - no MySQL
# Cadastra 10 registros extraídos de um CSV a cada 1 minuto, escrevendo o evento na tela
# O intuíto é anotar as faixas de tempo para cortar os logs binários com exatidão

OIFS=$IFS
IFS=','

R=0
REGIONS=('Osasco' 'Acre' 'Amazonas' 'Barretos' 'Belo Horizonte' 'Distrito Federal' 'Porto Velho' 'Sorocaba' 'Araras' 'Limeira')

I=0
while read REGION COUNTRY TYPE CHANNEL PRIORITY ORDER_DATE OID SHIP_DATE SOLD PRICE COST TOTAL_REVENUE TOTAL_COST TOTAL_PROFIT; do
	mysql pitr -e "INSERT INTO chunks (region, country, type, channel, priority, order_date, oid, ship_date, sold, price, cost, total_revenue, total_cost, total_profit)
	VALUES ('${REGIONS[$R]}', '$COUNTRY', '$TYPE', '$CHANNEL', '$PRIORITY', '$ORDER_DATE', $OID, '$SHIP_DATE', $SOLD, $PRICE, $COST, $TOTAL_REVENUE, $TOTAL_COST, $TOTAL_PROFIT)"
	I=$((I+1))
	if [ $I -eq 10 ]; then
		echo "$(date +'%Y-%m-%d %H:%M:%S') -> ${REGIONS[$R]}"
		sleep 60;
		R=$((R+1))
		I=0
	fi
done < chunks.csv
echo $I

IFS=$OIFS
