CREATE DATABASE pitr;

CREATE TABLE pitr.chunks (
  id int(11) NOT NULL AUTO_INCREMENT,
  region varchar(255) DEFAULT NULL,
  country varchar(255) DEFAULT NULL,
  type varchar(255) DEFAULT NULL,
  channel varchar(255) DEFAULT NULL,
  priority varchar(255) DEFAULT NULL,
  order_date varchar(255) DEFAULT NULL,
  oid varchar(255) DEFAULT NULL,
  ship_date varchar(255) DEFAULT NULL,
  sold varchar(255) DEFAULT NULL,
  price varchar(255) DEFAULT NULL,
  cost varchar(255) DEFAULT NULL,
  total_revenue varchar(255) DEFAULT NULL,
  total_cost varchar(255) DEFAULT NULL,
  total_profit varchar(255) DEFAULT NULL,
  PRIMARY KEY (id)
);
