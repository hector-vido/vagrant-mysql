#!/bin/bash

# Copia a chave SSH
mkdir -p /root/.ssh
cp /vagrant/files/key /root/.ssh/id_rsa
cp /vagrant/files/key.pub /root/.ssh/id_rsa.pub
cp /vagrant/files/key.pub /root/.ssh/authorized_keys
chmod 400 /root/.ssh/*

rpm -ivh https://dev.mysql.com/get/mysql80-community-release-sl15-3.noarch.rpm
rpm --import /etc/RPM-GPG-KEY-mysql
zypper install -y mysql-community-server

systemctl start mysql
systemctl enable mysql

PASS=$(grep password /var/log/mysql/mysqld.log | awk '{print $NF}')

# Afrouxa as políticas de senha
grep 'validate_password_policy' /etc/my.cnf > /dev/null
if [ "$?" -ne "0" ]; then
  echo 'validate_password.policy=LOW' >> /etc/my.cnf
  echo 'validate_password.length=6' >> /etc/my.cnf
fi
systemctl restart mysql
sleep 10

mysql -u root -p$PASS --connect-expired-password -e "ALTER USER root@localhost IDENTIFIED BY '4linux'"
