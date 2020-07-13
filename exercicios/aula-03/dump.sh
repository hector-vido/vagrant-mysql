#!/bin/bash

# SQL

mysqldump employees --compact --tables employees titles | pigz -9 > /root/employees-titles.sql.gz

# CSV

mkdir /var/lib/mysql-files/employees
chown mysql: /var/lib/mysql-files/employees
mysqldump employees --tables titles employees --tab=/var/lib/mysql-files/employees

# SQL

mysql -e "CREATE DATABASE employees_sql"
time zcat employees-titles.sql.gz | mysql employees_sql


# CSV

mysql -e "CREATE DATABASE employees_csv"
cd /var/lib/mysql-files/employees
for X in *.sql; do mysql -f employees_csv < $X; done
mysql -e 'SET GLOBAL foreign_key_checks=0'
time mysqlimport --use-threads=4 employees_csv $PWD/*.txt
mysql -e 'SET GLOBAL foreign_key_checks=1'
