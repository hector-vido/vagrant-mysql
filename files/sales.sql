-- Hector Vido Silva - versão 0.1
-- Tabela de testes e execução de comando de carga de dados dentro do banco
-- O arquivo original está presente neste endereço
-- http://eforexcel.com/wp/wp-content/uploads/2017/07/1500000%20Sales%20Records.zip
-- DROP TABLE IF EXISTS sales;
-- CREATE TABLE IF NOT EXISTS sales (
-- 	id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
-- 	region VARCHAR(100) NOT NULL DEFAULT '',
-- 	country VARCHAR(50) NOT NULL DEFAULT '',
-- 	type VARCHAR(20) NOT NULL DEFAULT '',
-- 	channel ENUM('Online', 'Offline') NOT NULL DEFAULT 'Online',
-- 	priority CHAR(1) NOT NULL DEFAULT 'M',
-- 	order_date DATE NULL,
-- 	oid INT UNSIGNED NOT NULL DEFAULT 0,
-- 	ship_date DATE NULL,
-- 	sold SMALLINT UNSIGNED NOT NULL DEFAULT 0,
-- 	price FLOAT(10,2) UNSIGNED NOT NULL DEFAULT 0.0,
-- 	cost FLOAT(10,2) UNSIGNED NOT NULL DEFAULT 0.0,
-- 	total_revenue FLOAT(10,2) UNSIGNED NOT NULL DEFAULT 0.0,
-- 	total_cost FLOAT(10,2) UNSIGNED NOT NULL DEFAULT 0.0,
-- 	total_profit FLOAT(10,2) UNSIGNED NOT NULL DEFAULT 0.0
-- );

LOAD DATA INFILE '/var/lib/mysql-files/sales.csv'
	INTO TABLE sales
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\r\n'
	IGNORE 1 LINES -- Pula o cabeçalho do CSV
	(region, country, type, channel, priority, @odate, oid, @sdate, sold, price, cost, total_revenue, total_cost, total_profit)
SET order_date = STR_TO_DATE(@odate, '%m/%d/%Y'), ship_date = STR_TO_DATE(@sdate, '%m/%d/%Y');
