#!/bin/bash

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

rm -rf /etc/apt/sources.list.d/mysql.list
apt-get update && apt-get install -y gnupg vim

wget -q -O - https://dev.mysql.com/doc/refman/8.0/en/checking-gpg-signature.html | grep -zEo -- '-----BEGIN.*BLOCK-----' | apt-key add -
cat > /etc/apt/sources.list.d/mysql.list <<EOF
deb http://repo.mysql.com/apt/debian/ buster mysql-apt-config
deb http://repo.mysql.com/apt/debian/ buster mysql-cluster-8.0
deb http://repo.mysql.com/apt/debian/ buster mysql-tools
#deb http://repo.mysql.com/apt/debian/ buster mysql-tools-preview
deb-src http://repo.mysql.com/apt/debian/ buster mysql-cluster-8.0
EOF

apt-get update

mkdir /var/lib/mysql-cluster

if [ -n "$(echo $HOSTNAME | grep -i data)" ]; then
  apt-get install -y mysql-cluster-community-data-node
  cat > /etc/my.cnf <<EOF
[ndbd]
connect-string=nodeid=$(ip a | grep -Eo '172.27.11.[0-9]{2}' | cut -d. -f4 | head -n1),172.27.11.20
EOF
elif [ -n "$(echo $HOSTNAME | grep -i mgm)" ]; then
  apt-get install -y mysql-cluster-community-management-server
  cp /vagrant/files/config.ini /var/lib/mysql-cluster
else
  debconf-set-selections <<< 'mysql-cluster-community-server mysql-community-server/root-pass password 4linux'
  debconf-set-selections <<< 'mysql-cluster-community-server mysql-community-server/re-root-pass password 4linux'
  DEBIAN_FRONTEND='noninteractive' apt-get install -y mysql-cluster-community-server
  echo -e '[client]\nuser=root\npassword=4linux' > /root/.my.cnf
  cat >> /etc/mysql/mysql.cnf <<EOF
[mysqld]
ndbcluster
ndb-connectstring=nodeid=30,172.27.11.20
EOF
fi
