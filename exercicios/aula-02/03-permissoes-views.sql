CREATE USER admin@localhost IDENTIFIED BY 'Abc123!';
GRANT ALL ON *.* TO admin@localhost;
CREATE USER app@'%' IDENTIFIED BY '@plicacao';
GRANT SELECT on ti.* TO app@'%';
GRANT SELECT on curso.* TO app@'%';
CREATE VIEW top_5 AS SELECT COUNT(*) qtd, artista FROM musicas GROUP BY artista ORDER BY qtd DESC LIMIT 5;
