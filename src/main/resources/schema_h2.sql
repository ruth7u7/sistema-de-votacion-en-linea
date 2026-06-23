DROP TABLE IF EXISTS auditoria_admin;
DROP TABLE IF EXISTS votos;
DROP TABLE IF EXISTS registro_participacion;
DROP TABLE IF EXISTS opciones;
DROP TABLE IF EXISTS encuesta;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS usuario;

CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    rol VARCHAR(20) NOT NULL DEFAULT 'VOTANTE',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL
);

CREATE TABLE encuesta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NULL,
    titulo VARCHAR(200) NOT NULL,
    descripcion VARCHAR(500) NULL,
    activa BOOLEAN NOT NULL DEFAULT true,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMP NULL,
    FOREIGN KEY (categoria_id) REFERENCES categoria(id) ON DELETE SET NULL
);

CREATE TABLE opciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    encuesta_id INT NOT NULL,
    texto VARCHAR(200) NOT NULL,
    orden INT NOT NULL DEFAULT 0,
    FOREIGN KEY (encuesta_id) REFERENCES encuesta(id) ON DELETE CASCADE
);

CREATE TABLE registro_participacion (
    usuario_id INT NOT NULL,
    encuesta_id INT NOT NULL,
    fecha_voto TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, encuesta_id),
    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (encuesta_id) REFERENCES encuesta(id) ON DELETE CASCADE
);

CREATE TABLE votos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    encuesta_id INT NOT NULL,
    opcion_id INT NOT NULL,
    FOREIGN KEY (usuario_id, encuesta_id) REFERENCES registro_participacion(usuario_id, encuesta_id) ON DELETE CASCADE,
    FOREIGN KEY (opcion_id) REFERENCES opciones(id) ON DELETE CASCADE
);

CREATE TABLE auditoria_admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    accion VARCHAR(100) NOT NULL,
    detalles TEXT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
);

INSERT INTO categoria (nombre, descripcion) VALUES
    ('Programación', 'Encuestas relacionadas con lenguajes, frameworks y desarrollo de software'),
    ('Deportes', 'Fútbol, básquetbol, tenis y actividades deportivas locales o mundiales'),
    ('Cultura General', 'Preguntas sobre ciencia, historia, geografía y temas de interés general');

INSERT INTO usuario (username, password_hash, email, rol) VALUES
    ('admin', '$2a$10$N.6PY9AFggIZvwxXfbpmRO4e8KnWIn3PZMCzcJTzvLLyy6HP0F9Cu', 'admin@votacion.com', 'ADMIN'),
    ('juan', '$2a$10$8WdnbQQZq5HkG2f4O0vLG.JzqXRteCd4J6gSsZTusx.nDB3Sy.Rdi', 'juan@gmail.com', 'VOTANTE'),
    ('maria', '$2a$10$Ex14DXjA86yIXuIhGHtIEO7zR.rT4fM.M6fNukT/qXbJu98WOnmU2', 'maria@gmail.com', 'VOTANTE'),
    ('ana', '$2a$10$8WdnbQQZq5HkG2f4O0vLG.JzqXRteCd4J6gSsZTusx.nDB3Sy.Rdi', 'ana@gmail.com', 'VOTANTE'),
    ('luis', '$2a$10$8WdnbQQZq5HkG2f4O0vLG.JzqXRteCd4J6gSsZTusx.nDB3Sy.Rdi', 'luis@gmail.com', 'VOTANTE'),
    ('marta', '$2a$10$8WdnbQQZq5HkG2f4O0vLG.JzqXRteCd4J6gSsZTusx.nDB3Sy.Rdi', 'marta@gmail.com', 'VOTANTE');

INSERT INTO encuesta (categoria_id, titulo, descripcion)
VALUES (
    (SELECT id FROM categoria WHERE nombre = 'Programación'),
    '¿Cuál es tu framework web favorito?',
    'Vota por el framework que más utilizas en tus proyectos de desarrollo web.'
);

INSERT INTO opciones (encuesta_id, texto, orden) VALUES
    ((SELECT MAX(id) FROM encuesta), 'Spring',  1),
    ((SELECT MAX(id) FROM encuesta), 'Django',  2),
    ((SELECT MAX(id) FROM encuesta), 'Laravel', 3),
    ((SELECT MAX(id) FROM encuesta), 'Rails',   4);

INSERT INTO registro_participacion (usuario_id, encuesta_id) VALUES
    ((SELECT id FROM usuario WHERE username = 'ana'), (SELECT MAX(id) FROM encuesta)),
    ((SELECT id FROM usuario WHERE username = 'luis'), (SELECT MAX(id) FROM encuesta)),
    ((SELECT id FROM usuario WHERE username = 'marta'), (SELECT MAX(id) FROM encuesta));

INSERT INTO votos (usuario_id, encuesta_id, opcion_id) VALUES
    ((SELECT id FROM usuario WHERE username = 'ana'), (SELECT MAX(id) FROM encuesta), (SELECT id FROM opciones WHERE texto = 'Spring' AND encuesta_id = (SELECT MAX(id) FROM encuesta))),
    ((SELECT id FROM usuario WHERE username = 'luis'), (SELECT MAX(id) FROM encuesta), (SELECT id FROM opciones WHERE texto = 'Django' AND encuesta_id = (SELECT MAX(id) FROM encuesta))),
    ((SELECT id FROM usuario WHERE username = 'marta'), (SELECT MAX(id) FROM encuesta), (SELECT id FROM opciones WHERE texto = 'Spring' AND encuesta_id = (SELECT MAX(id) FROM encuesta)));
