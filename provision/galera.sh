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

apt-get install -y mariadb-server

cat > /etc/mysql/mariadb.conf.d/60-galera.cnf <<EOF
[mysqld]

bind_address=0.0.0.0

# wsrep
wsrep_on=ON
wsrep_sst_method=rsync
wsrep_cluster_name="4linux"
wsrep_node_address=$(ip a | grep -Eo '172.27.11.[0-9]+/' | tr -d '/')
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_provider_options="gcache.size=300M; gcache.page_size=300M"
wsrep_cluster_address="gcomm://172.27.11.10,172.27.11.20,172.27.11.30"

# Replicacao
binlog_format=ROW

# InnoDB
innodb_autoinc_lock_mode=2 # padrão na versão >= 8.0, evita lock
innodb_buffer_pool_size=768M
innodb_flush_log_at_trx_commit=0
default_storage_engine=InnoDB
EOF
