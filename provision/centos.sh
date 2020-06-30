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
yum install -y mysql-server vim
systemctl enable mysqld
systemctl start mysqld

# Afrouxa as políticas de senha
grep 'validate_password_policy' /etc/my.cnf > /dev/null
if [ "$?" -ne "0" ]; then
  echo 'validate_password_policy=LOW' >> /etc/my.cnf
  echo 'validate_password_length=6' >> /etc/my.cnf
fi
systemctl restart mysqld
sleep 10

# Altera a senha do root e configura o client
mysql -u root -e "ALTER USER root@localhost IDENTIFIED BY '4linux'"
echo -e '[client]\nuser=root\npassword=4linux' > /root/.my.cnf
echo "export PROMPT_COMMAND='history -a'" > /root/.bashrc
