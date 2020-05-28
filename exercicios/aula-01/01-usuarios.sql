CREATE DATABASE curso;

USE curso;

CREATE TABLE usuarios (
	id INT AUTO_INCREMENT PRIMARY KEY,
	nome VARCHAR(255),
	email VARCHAR(255),
	nascimento DATE,
	profissao VARCHAR(255),
	status TINYINT
);

INSERT INTO usuarios (nome, email, nascimento, profissao, status) VALUES ('Paramahansa Yogananda', 'paramahansa@yogananda.in', '1983-01-05', 'Yogi', 1);
INSERT INTO usuarios (nome, email, nascimento, profissao, status) VALUES ('Jiddu Krishnamurti', 'jiddu@krishnamurti.in', '1985-05-11', 'Professor do Mundo', 1);
