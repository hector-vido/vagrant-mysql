CREATE USER 'monitor'@'172.27.11.10' IDENTIFIED BY '4linux';
GRANT PROCESS ON *.* TO 'monitor'@'172.27.11.10';
CREATE DATABASE monitoring;
CREATE ROLE monitoring;
GRANT ALL ON monitoring.* TO monitoring;
GRANT monitoring TO monitor@'172.27.11.10';
SET DEFAULT ROLE ALL TO monitor@'172.27.11.10';
