-- =============================================================================
--  Proyecto  : Ventas_Tech_DB  (TechStore / RetailPro)
--  Módulo    : 3 - Checkpoint: Script SQL de Ingeniería de Datos
--  Autora    : Magali Antonella Gaiani
--  Motor     : PostgreSQL (compatible con SQL Server salvo la creación de la BD)
--  Objetivo  : Crear el back-end del proyecto final: una base de datos limpia,
--              normalizada (3NF) y cargada con datos iniciales.
--
--  El script es REPETIBLE: puede ejecutarse varias veces sin errores porque
--  elimina las tablas existentes antes de volver a crearlas.
--
--  Modelo de datos:
--    categorias (1) ---- (N) productos (1) ---- (N) ventas (N) ---- (1) clientes
-- =============================================================================


-- =============================================================================
--  PASO 1: CREAR LA BASE DE DATOS
--  Ejecutar una sola vez, conectado a la base "postgres". Luego conectarse a
--  Ventas_Tech_DB y ejecutar el resto del script.
-- =============================================================================
-- CREATE DATABASE ventas_tech_db;
-- \c ventas_tech_db


-- =============================================================================
--  SECCIÓN 1: DEFINICIÓN DEL ESQUEMA (DDL)
-- =============================================================================

-- -----------------------------------------------------------------------------
--  1.1 DROP TABLES
--  Orden INVERSO a las dependencias: primero la tabla de hechos (ventas), que
--  referencia a productos y clientes; luego productos, que referencia a
--  categorias; por último las tablas sin dependencias.
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;


-- -----------------------------------------------------------------------------
--  1.2 CREATE TABLES
--  Orden: primero las dimensiones (categorias, clientes), después productos
--  (depende de categorias) y al final la tabla de hechos (ventas).
-- -----------------------------------------------------------------------------

-- Dimensión: categorías de producto.
-- Se separa de productos para cumplir la 3NF: el nombre de la categoría depende
-- de id_categoria y no del producto, así se evita repetir texto en cada fila.
CREATE TABLE categorias (
    id_categoria      INT           NOT NULL,
    nombre_categoria  VARCHAR(50)   NOT NULL,
    descripcion       VARCHAR(200),
    CONSTRAINT pk_categorias PRIMARY KEY (id_categoria)
);

-- Dimensión: clientes.
CREATE TABLE clientes (
    id_cliente        INT           NOT NULL,
    nombre            VARCHAR(100)  NOT NULL,
    email             VARCHAR(100),
    ciudad            VARCHAR(50),
    fecha_registro    DATE          NOT NULL,
    CONSTRAINT pk_clientes  PRIMARY KEY (id_cliente),
    CONSTRAINT uq_clientes_email UNIQUE (email)
);

-- Dimensión: productos. Depende de categorias.
-- precio usa DECIMAL(10,2): nunca FLOAT ni texto para valores monetarios.
-- activo usa SMALLINT en lugar de TINYINT(1) porque PostgreSQL no tiene TINYINT.
CREATE TABLE productos (
    id_producto       INT           NOT NULL,
    nombre_producto   VARCHAR(100)  NOT NULL,
    id_categoria      INT           NOT NULL,
    precio            DECIMAL(10,2) NOT NULL,
    stock             INT           DEFAULT 0,
    activo            SMALLINT      DEFAULT 1,
    CONSTRAINT pk_productos PRIMARY KEY (id_producto),
    CONSTRAINT fk_productos_categoria
        FOREIGN KEY (id_categoria) REFERENCES categorias (id_categoria),
    CONSTRAINT ck_productos_precio CHECK (precio >= 0),
    CONSTRAINT ck_productos_activo CHECK (activo IN (0, 1))
);

-- Tabla de hechos: ventas. Conecta clientes y productos.
-- Las FOREIGN KEYS garantizan la integridad referencial: no se puede registrar
-- una venta de un producto o de un cliente que no existen.
CREATE TABLE ventas (
    id_venta          INT           NOT NULL,
    id_cliente        INT           NOT NULL,
    id_producto       INT           NOT NULL,
    cantidad          INT           NOT NULL,
    precio_unitario   DECIMAL(10,2) NOT NULL,
    fecha_venta       DATE          NOT NULL,
    CONSTRAINT pk_ventas PRIMARY KEY (id_venta),
    CONSTRAINT fk_ventas_cliente
        FOREIGN KEY (id_cliente)  REFERENCES clientes (id_cliente),
    CONSTRAINT fk_ventas_producto
        FOREIGN KEY (id_producto) REFERENCES productos (id_producto),
    CONSTRAINT ck_ventas_cantidad CHECK (cantidad > 0)
);


-- =============================================================================
--  SECCIÓN 2: RESTRICCIONES DE INTEGRIDAD (resumen)
--  Todas fueron definidas dentro de los CREATE TABLE anteriores:
--    PRIMARY KEY : categorias.id_categoria, clientes.id_cliente,
--                  productos.id_producto, ventas.id_venta
--    FOREIGN KEY : productos.id_categoria -> categorias.id_categoria
--                  ventas.id_cliente      -> clientes.id_cliente
--                  ventas.id_producto     -> productos.id_producto
--    NOT NULL    : nombres, precios, cantidades y fechas (campos críticos)
--    UNIQUE      : clientes.email
--    CHECK       : precio >= 0, cantidad > 0, activo en (0,1)
--    DEFAULT     : stock = 0, activo = 1
-- =============================================================================


-- =============================================================================
--  SECCIÓN 3: CARGA INICIAL DE DATOS (DML)
--  Orden: primero las tablas sin dependencias (categorias, clientes), luego
--  productos y al final ventas.
-- =============================================================================

-- 3.1 categorias — 4 registros
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
    (1, 'Computación',    'Laptops, PCs y monitores'),
    (2, 'Accesorios',     'Periféricos y complementos'),
    (3, 'Audio',          'Auriculares y parlantes'),
    (4, 'Almacenamiento', 'Discos y memorias');

-- 3.2 clientes — 5 registros
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
    (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
    (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
    (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
    (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
    (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

-- 3.3 productos — 6 registros
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
    (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
    (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
    (3, 'Monitor 4K 27"',     1,  450.00, 12, 1),
    (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
    (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
    (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

-- 3.4 ventas — 10 registros
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
    ( 2, 2, 2, 5,   28.00, '2024-03-06'),
    ( 3, 3, 3, 1,  450.00, '2024-03-07'),
    ( 4, 1, 4, 2,  120.00, '2024-03-08'),
    ( 5, 4, 5, 3,  130.00, '2024-03-10'),
    ( 6, 2, 6, 4,   95.00, '2024-03-11'),
    ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
    ( 8, 3, 2, 8,   28.00, '2024-03-13'),
    ( 9, 4, 4, 1,  120.00, '2024-03-14'),
    (10, 5, 3, 2,  450.00, '2024-03-15');


-- =============================================================================
--  PASO 3: VERIFICACIÓN DE INTEGRIDAD
-- =============================================================================

-- Confirmar que cada tabla se cargó correctamente
SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;

-- Conteo de registros por tabla (esperado: 4, 5, 6, 10)
SELECT 'categorias' AS tabla, COUNT(*) AS registros FROM categorias
UNION ALL
SELECT 'clientes',   COUNT(*) FROM clientes
UNION ALL
SELECT 'productos',  COUNT(*) FROM productos
UNION ALL
SELECT 'ventas',     COUNT(*) FROM ventas;

-- Total facturado (cantidad * precio_unitario) — comprobación rápida de que
-- los tipos numéricos permiten hacer cálculos
SELECT SUM(cantidad * precio_unitario) AS total_facturado FROM ventas;

-- Prueba de integridad referencial (debe FALLAR: el producto 99 no existe).
-- Descomentar para verificar que la FK protege los datos:
-- INSERT INTO ventas VALUES (11, 1, 99, 1, 10.00, '2024-03-16');
