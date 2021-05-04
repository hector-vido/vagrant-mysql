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

apt-get update && apt-get install -y gnupg2 vim

if [ "$1" == 'mariadb' ]; then # MariaDB
	apt-get install -y software-properties-common dirmngr apt-transport-https
	echo 'deb [arch=amd64] https://mirror1.cl.netactuate.com/mariadb/repo/10.5/debian buster main' > /etc/apt/sources.list.d/mariadb.list
	apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
	apt-get update
	apt-get install -y mariadb-server
	systemctl start mariadb
	systemctl enable mariadb
elif [ "$1" == 'percona' ]; then # Percona
	wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
	dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
	percona-release setup ps80
	debconf-set-selections <<< 'percona-server-server percona-server-server/root-pass password 4linux'
	debconf-set-selections <<< 'percona-server-server percona-server-server/re-root-pass password 4linux'
	DEBIAN_FRONTEND=noninteractive apt-get install -y percona-server-server
else # MySQL
	apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5
	echo 'deb http://repo.mysql.com/apt/debian/ buster mysql-8.0 mysql-tools' > /etc/apt/sources.list.d/mysql.list

	apt-get update
	
	debconf-set-selections <<< 'mysql-community-server mysql-community-server/root-pass password 4linux'
	debconf-set-selections <<< 'mysql-community-server mysql-community-server/re-root-pass password 4linux'
	DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-community-server mysql-shell mysql-router
	
	grep report_host /etc/mysql/mysql.conf.d/mysqld.cnf > /dev/null
	if [ "$?" -ne 0 ]; then
		IP=$(ip a | grep -Eo '172.27.11.[0-9]{2}' | grep -v 25)
		echo "report_host = $IP" >> /etc/mysql/mysql.conf.d/mysqld.cnf
	fi
	systemctl restart mysql
fi

if [ "$2" -eq 1 ]; then
	apt-get install -y git
	git clone --depth 1 https://github.com/datacharmer/test_db.git ~/employees-db
	wget -q https://downloads.mysql.com/docs/sakila-db.tar.gz -O - | tar -xzv -C ~/
	cd ~/employees-db
	mysql -u root -p4linux < employees.sql
	cd ~/sakila-db
	mysql -u root -p4linux < sakila-schema.sql
	mysql -u root -p4linux < sakila-data.sql
fi
