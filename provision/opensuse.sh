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
sleep 10

PASS=$(grep password /var/log/mysql/mysqld.log | awk '{print $NF}')

if [ "$(grep report_host /etc/my.cnf)" == "" ]; then
  echo "report_host = $(ip a | grep -Eo '172.27.11.[0-9]{2}' | grep -v 25)" >> /etc/my.cnf
fi

systemctl start mysql
systemctl enable mysql
sleep 10

# Afrouxa as políticas de senha
grep 'validate_password_policy' /etc/my.cnf > /dev/null
if [ "$?" -ne "0" ]; then
  echo 'validate_password.policy=LOW' >> /etc/my.cnf
  echo 'validate_password.length=6' >> /etc/my.cnf
fi
systemctl restart mysql
sleep 10

mysql -u root -p$PASS --connect-expired-password -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY '4linux'"

zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
zypper --gpg-auto-import-keys refresh
zypper dup --from snappy
zypper install -y snapd
systemctl enable snapd
systemctl start snapd
systemctl enable snapd.apparmor
systemctl start snapd.apparmor
snap install mysql-shell
