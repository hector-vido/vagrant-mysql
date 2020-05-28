#!/bin/bash

mkdir -p /root/.ssh
cp /vagrant/files/key /root/.ssh/id_rsa
cp /vagrant/files/key.pub /root/.ssh/id_rsa.pub
cp /vagrant/files/key.pub /root/.ssh/authorized_keys
chmod 400 /root/.ssh/*

rm -rf /etc/apt/sources.list.d/mysql.list
apt-get update && apt-get install -y gnupg vim

apt-key add /vagrant/files/mysql.asc
cat > /etc/apt/sources.list.d/mysql.list <<EOF
deb http://repo.mysql.com/apt/debian/ buster mysql-apt-config
deb http://repo.mysql.com/apt/debian/ buster mysql-cluster-8.0
deb http://repo.mysql.com/apt/debian/ buster mysql-tools
#deb http://repo.mysql.com/apt/debian/ buster mysql-tools-preview
deb-src http://repo.mysql.com/apt/debian/ buster mysql-cluster-8.0
EOF

apt-get update

if [ -n "$(echo $HOSTNAME | grep -i data)" ]; then
  apt-get install -y mysql-cluster-community-data-node
elif [ -n "$(echo $HOSTNAME | grep -i mgm)" ]; then
  apt-get install -y mysql-cluster-community-management-server
else
  debconf-set-selections <<< 'mysql-cluster-community-server mysql-community-server/root-pass password 4linux'
  debconf-set-selections <<< 'mysql-cluster-community-server mysql-community-server/re-root-pass password 4linux'
  DEBIAN_FRONTEND='noninteractive' apt-get install -y mysql-cluster-community-server
  echo -e '[client]\nuser=root\npassword=4linux' > /root/.my.cnf
fi
