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

apt-get install -y software-properties-common dirmngr apt-transport-https gnupg2 vim
echo 'deb [arch=amd64] https://mirror1.cl.netactuate.com/mariadb/repo/10.5/debian buster main' > /etc/apt/sources.list.d/mariadb.list
apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
apt-get update
apt-get install -y mariadb-server
systemctl start mariadb
systemctl enable mariadb

# Bases de exemplo
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

cat > /etc/mysql/mariadb.conf.d/60-galera.cnf <<EOF
[mysqld]

bind_address           = 0.0.0.0

# wsrep
wsrep_on               = ON
wsrep_sst_method       = rsync
wsrep_cluster_name     = 4linux
wsrep_node_address     = $(ip a | grep -Eo '172.27.11.[0-9]+/' | tr -d '/')
wsrep_provider         = /usr/lib/galera/libgalera_smm.so
wsrep_provider_options = "gcache.size=300M; gcache.page_size=300M"
wsrep_cluster_address  = "gcomm://172.27.11.10,172.27.11.20,172.27.11.30"

# Replicacao
binlog_format = ROW

# InnoDB
default_storage_engine         = InnoDB # padrão
innodb_buffer_pool_size        = 256M
innodb_autoinc_lock_mode       = 2 # padrão na versão 8+
innodb_flush_log_at_trx_commit = 0
EOF
