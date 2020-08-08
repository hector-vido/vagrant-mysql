#!/bin/bash

# Copia a chave SSH
mkdir -p /root/.ssh
cp /vagrant/files/key /root/.ssh/id_rsa
cp /vagrant/files/key.pub /root/.ssh/id_rsa.pub
cp /vagrant/files/key.pub /root/.ssh/authorized_keys
chmod 400 /root/.ssh/*

if [ "$(swapon -v)" == "" ]; then
  dd if=/dev/zero of=/swapfile bs=1M count=512
  chmod 0600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile       swap    swap    defaults        0       0' >> /etc/fstab
fi

# Atualiza pacotes e prepara a máquina
rm -rf /etc/apt/sources.list.d/mysql.list
apt-get update && apt-get install -y gnupg vim

#apt-get install -y mariadb-server
#exit

# Adiciona chave e repositório
wget -q -O - https://dev.mysql.com/doc/refman/8.0/en/checking-gpg-signature.html | grep -zEo -- '-----BEGIN.*BLOCK-----' | apt-key add -
cat > /etc/apt/sources.list.d/mysql.list <<EOF
deb http://repo.mysql.com/apt/debian/ buster mysql-8.0
deb http://repo.mysql.com/apt/debian/ buster mysql-tools
EOF
apt-get update

# Ajusta para instalação não assistida
debconf-set-selections <<< 'mysql-community-server mysql-community-server/root-pass password 4linux'
debconf-set-selections <<< 'mysql-community-server mysql-community-server/re-root-pass password 4linux'
DEBIAN_FRONTEND='noninteractive' apt-get install -y mysql-community-server mysql-shell mysql-router

# Configura o client
#echo -e '[client]\nuser=root\npassword=4linux' > /root/.my.cnf
mysql -u root -p4linux -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY '4linux'" > /dev/null
echo "export PROMPT_COMMAND='history -a'" > /root/.bashrc

if [ "$(grep report_host /etc/mysql/mysql.conf.d/mysqld.cnf)" == "" ]; then
  echo "report_host = $(ip a | grep -Eo '172.27.11.[0-9]{2}' | grep -v 25)" >> /etc/mysql/mysql.conf.d/mysqld.cnf
fi
systemctl restart mysql
