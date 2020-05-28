#!/bin/bash

# Copia a chave SSH
mkdir -p /root/.ssh
cp /vagrant/files/key /root/.ssh/id_rsa
cp /vagrant/files/key.pub /root/.ssh/id_rsa.pub
cp /vagrant/files/key.pub /root/.ssh/authorized_keys
chmod 400 /root/.ssh/*

# Atualiza pacotes e prepara a máquina
rm -rf /etc/apt/sources.list.d/mysql.list
apt-get update && apt-get install -y gnupg vim

# Adiciona chave e repositório
apt-key add /vagrant/files/mysql.asc
echo 'deb http://repo.mysql.com/apt/debian/ buster mysql-8.0' > /etc/apt/sources.list.d/mysql.list
apt-get update

# Ajusta para instalação não assistida
debconf-set-selections <<< 'mysql-community-server mysql-community-server/root-pass password 4linux'
debconf-set-selections <<< 'mysql-community-server mysql-community-server/re-root-pass password 4linux'
DEBIAN_FRONTEND='noninteractive' apt-get install -y mysql-community-server

# Configura o client
echo -e '[client]\nuser=root\npassword=4linux' > /root/.my.cnf
echo "export PROMPT_COMMAND='history -a'" > /root/.bashrc
