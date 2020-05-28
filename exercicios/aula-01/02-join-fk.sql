CREATE TABLE usuarios_infos (usuario_id PRIMARY KEY, sexo ENUM('M','F'), curriculo TEXT);

ALTER TABLE usuarios_infos ADD CONSTRAINT fk_usuario_id FOREIGN KEY (usuario_id) REFERENCES usuarios(id);
