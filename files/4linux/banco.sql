DROP DATABASE IF EXISTS 4linux;

CREATE DATABASE 4linux;

USE 4linux;

CREATE TABLE cursos (
  id SMALLINT UNSIGNED PRIMARY KEY,
  nome VARCHAR(100) NOT NULL DEFAULT '',
  duracao TINYINT NOT NULL DEFAULT 0,
  valor FLOAT NOT NULL DEFAULT 0,
  cadastrado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  alterado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO cursos (id, nome, duracao, valor) VALUES (450, 'Linux Beginners', 0, 0),(451, 'Linux Administrator', 0, 0),(452, 'Linux Engineer', 0, 0),(801, 'MySQL', 0, 0),(802, 'PostgreSQL', 0, 0),(803, 'MongoDB', 0, 0),(500, 'PHP Básico', 0, 0),(501, 'PHP Intermediário', 0, 0),(502, 'PHP Avançado', 0, 0),(520, 'Python Básico', 0, 0),(521, 'Python para Administradores', 0, 0),(522, 'Python para Cientistas de Dados', 0, 0),(525, 'Infraestrutura Ágil', 0, 0),(540, 'Docker', 0, 0),(541, 'Kubernetes', 0, 0),(542, 'Openshift', 0, 0),(543, 'Rancher', 0, 0),(600, 'pfSense', 0, 0),(700, 'OpenLDAP e Samba', 0, 0),(900, 'Segurança em Servidores Linux', 0, 0);

CREATE TABLE professores (
  cpf CHAR(14) PRIMARY KEY,
  nome VARCHAR(100) NOT NULL DEFAULT '',
  email VARCHAR(100) NOT NULL DEFAULT '',
  nascimento DATE NOT NULL DEFAULT '1970-01-01',
  cadastrado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  alterado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE alunos (
  cpf CHAR(14) PRIMARY KEY,
  nome VARCHAR(100) NOT NULL DEFAULT '',
  email VARCHAR(100) NOT NULL DEFAULT '',
  telefone CHAR(17) NOT NULL DEFAULT '',
  nascimento DATE NOT NULL DEFAULT '1970-01-01',
  cadastrado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  alterado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE turmas (
  id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL DEFAULT ''
  inicio DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',
  fim DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',
);

CREATE TABLE turmas_alunos (
  turma_id SMALLINT UNSIGNED NOT NULL,
  aluno_cpf CHAR(14) NOT NULL,
  PRIMARY KEY(turma_id, aluno_cpf)
);

CREATE TABLE alunos_compras (
  curso_id MEDIUMINT UNSIGNED NOT NULL,
  aluno_cpf CHAR(14) NOT NULL,
  turma_id MEDIUMINT UNSIGNED NOT NULL,
  valor FLOAT NOT NULL DEFAULT 0,
  PRIMARY KEY(aluno_cpf, turma_id, curso_id)
);
