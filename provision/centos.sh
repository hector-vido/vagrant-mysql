#!/bin/bash

# Copia a chave SSH
mkdir -p /root/.ssh
cp /vagrant/files/key /root/.ssh/id_rsa
cp /vagrant/files/key.pub /root/.ssh/id_rsa.pub
cp /vagrant/files/key.pub /root/.ssh/authorized_keys
chmod 400 /root/.ssh/*

#Quando precisar liberar firewall
#cp /vagrant/files/CentOS-Extras.repo /etc/yum.repos.d/CentOS-Extras.repo
#cp /vagrant/files/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
#cp /vagrant/files/CentOS-AppStream.repo /etc/yum.repos.d/CentOS-AppStream.repo

# Habilita repositório e instala o MySQL
rpm -ihv https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

#yum-config-manager --disable 'mysql80-community'
#yum-config-manager --enable 'mysql57-community'

yum install -y mysql-server mysql-shell vim

if [ "$(grep report_host /etc/my.cnf.d/mysql-server.cnf)" == "" ]; then
  echo "report_host = $(ip a | grep -Eo '172.27.11.[0-9]{2}' | grep -v 25)" >> /etc/my.cnf.d/mysql-server.cnf
fi

systemctl enable mysqld
systemctl start mysqld

# Altera a senha do root e configura o client
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY '4linux'"
#echo -e '[client]\nuser=root\npassword=4linux' > /root/.my.cnf
echo "export PROMPT_COMMAND='history -a'" > /root/.bashrc
