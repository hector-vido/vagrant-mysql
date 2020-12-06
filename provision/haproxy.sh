#!/bin/bash

# Copia a chave SSH
mkdir -p /root/.ssh
cp /vagrant/files/key /root/.ssh/id_rsa
cp /vagrant/files/key.pub /root/.ssh/id_rsa.pub
cp /vagrant/files/key.pub /root/.ssh/authorized_keys
chmod 400 /root/.ssh/*

# Atualiza pacotes e prepara a máquina
rm -rf /etc/apt/sources.list.d/mysql.list
apt-get update && apt-get install -y haproxy vim mariadb-client

cat > /etc/haproxy/haproxy.cfg <<EOF
# Load Balancing for Galera Cluster
defaults
    log         /dev/log local0
    option  tcplog
    option  log-health-checks
    timeout connect 5s
    timeout client 30s
    timeout server 30s

listen galera
     bind    *:3306
     balance source
     mode    tcp
     option  tcpka
     option  mysql-check user haproxy
     server  node1 172.27.11.10:3306 check weight 1
     server  node2 172.27.11.20:3306 check weight 1
     server  node3 172.27.11.30:3306 check weight 1
EOF

systemctl restart haproxy
systemctl enable haproxy
