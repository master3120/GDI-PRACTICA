-- 01_crear_base_de_datos.sql: Crea la base, las 12 tablas con soporte para borrado lógico (activo = 1)
-- y la tabla de auditoría para triggers. Ejecutar primero.

SET NAMES utf8mb4;

DROP DATABASE IF EXISTS bd_veterinaria;

CREATE DATABASE bd_veterinaria
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE bd_veterinaria;

CREATE TABLE categoria_producto (
    id_categoria     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre_categoria VARCHAR(50)  NOT NULL,
    activo           TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre_categoria)
) ENGINE=InnoDB;

CREATE TABLE presentacion_producto (
    id_presentacion     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre_presentacion VARCHAR(50)  NOT NULL,
    activo              TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (id_presentacion),
    CONSTRAINT uq_presentacion_nombre UNIQUE (nombre_presentacion)
) ENGINE=InnoDB;

CREATE TABLE veterinaria (
    ruc     CHAR(11)     NOT NULL,
    nombre  VARCHAR(100) NOT NULL,
    correo  VARCHAR(100) NOT NULL,
    calle   VARCHAR(100) NOT NULL,
    numero  VARCHAR(10)  NULL,
    manzana VARCHAR(10)  NULL,
    lote    VARCHAR(10)  NULL,
    PRIMARY KEY (ruc),
    CONSTRAINT chk_veterinaria_ruc CHECK (ruc REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB;

CREATE TABLE proveedor (
    ruc          CHAR(11)     NOT NULL,
    razon_social VARCHAR(100) NOT NULL,
    correo       VARCHAR(100) NOT NULL,
    calle        VARCHAR(100) NOT NULL,
    numero       VARCHAR(10)  NULL,
    manzana      VARCHAR(10)  NULL,
    lote         VARCHAR(10)  NULL,
    activo       TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (ruc),
    CONSTRAINT uq_proveedor_razon_social UNIQUE (razon_social),
    CONSTRAINT chk_proveedor_ruc CHECK (ruc REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB;

CREATE TABLE telefono_veterinaria (
    ruc_veterinaria CHAR(11) NOT NULL,
    telefono        CHAR(9)  NOT NULL,
    PRIMARY KEY (ruc_veterinaria, telefono),
    CONSTRAINT fk_telvet_veterinaria FOREIGN KEY (ruc_veterinaria)
        REFERENCES veterinaria (ruc)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_telvet_telefono CHECK (telefono REGEXP '^[0-9]{9}$')
) ENGINE=InnoDB;

CREATE TABLE telefono_proveedor (
    ruc_proveedor CHAR(11) NOT NULL,
    telefono      CHAR(9)  NOT NULL,
    PRIMARY KEY (ruc_proveedor, telefono),
    CONSTRAINT fk_telprov_proveedor FOREIGN KEY (ruc_proveedor)
        REFERENCES proveedor (ruc)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_telprov_telefono CHECK (telefono REGEXP '^[0-9]{9}$')
) ENGINE=InnoDB;

CREATE TABLE producto (
    codigo_producto     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre              VARCHAR(100) NOT NULL,
    descripcion         VARCHAR(255) NULL,
    cantidad_disponible INT UNSIGNED NOT NULL DEFAULT 0,
    id_categoria        INT UNSIGNED NOT NULL,
    id_presentacion     INT UNSIGNED NOT NULL,
    activo              TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (codigo_producto),
    INDEX idx_producto_nombre (nombre),
    INDEX idx_producto_categoria (id_categoria),
    INDEX idx_producto_presentacion (id_presentacion),
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria_producto (id_categoria)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_producto_presentacion FOREIGN KEY (id_presentacion)
        REFERENCES presentacion_producto (id_presentacion)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE suministra (
    ruc_proveedor   CHAR(11)     NOT NULL,
    codigo_producto INT UNSIGNED NOT NULL,
    PRIMARY KEY (ruc_proveedor, codigo_producto),
    INDEX idx_suministra_producto (codigo_producto),
    CONSTRAINT fk_suministra_proveedor FOREIGN KEY (ruc_proveedor)
        REFERENCES proveedor (ruc)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_suministra_producto FOREIGN KEY (codigo_producto)
        REFERENCES producto (codigo_producto)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE orden_compra (
    codigo_orden_compra INT UNSIGNED NOT NULL AUTO_INCREMENT,
    ruc_veterinaria     CHAR(11)     NOT NULL,
    ruc_proveedor       CHAR(11)     NOT NULL,
    fecha_emision       DATE         NOT NULL DEFAULT (CURRENT_DATE),
    fecha_entrega       DATE         NULL,
    activo              TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (codigo_orden_compra),
    INDEX idx_orden_proveedor (ruc_proveedor),
    INDEX idx_orden_veterinaria (ruc_veterinaria),
    INDEX idx_orden_fecha (fecha_emision),
    CONSTRAINT fk_orden_veterinaria FOREIGN KEY (ruc_veterinaria)
        REFERENCES veterinaria (ruc)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_orden_proveedor FOREIGN KEY (ruc_proveedor)
        REFERENCES proveedor (ruc)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_orden_fechas
        CHECK (fecha_entrega IS NULL OR fecha_entrega >= fecha_emision)
) ENGINE=InnoDB;

CREATE TABLE detalle_orden_compra (
    codigo_orden_compra INT UNSIGNED      NOT NULL,
    numero_linea        SMALLINT UNSIGNED NOT NULL,
    codigo_producto     INT UNSIGNED      NOT NULL,
    cantidad_requerida  INT UNSIGNED      NOT NULL,
    precio_unitario     DECIMAL(10,2)     NOT NULL,
    subtotal            DECIMAL(12,2)
        GENERATED ALWAYS AS (cantidad_requerida * precio_unitario) STORED,
    PRIMARY KEY (codigo_orden_compra, numero_linea),
    INDEX idx_detalle_producto (codigo_producto),
    CONSTRAINT fk_detalle_orden FOREIGN KEY (codigo_orden_compra)
        REFERENCES orden_compra (codigo_orden_compra)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (codigo_producto)
        REFERENCES producto (codigo_producto)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_detalle_linea    CHECK (numero_linea > 0),
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad_requerida > 0),
    CONSTRAINT chk_detalle_precio   CHECK (precio_unitario > 0)
) ENGINE=InnoDB;

CREATE TABLE factura_electronica (
    ruc_proveedor       CHAR(11)      NOT NULL,
    num_factura         VARCHAR(13)   NOT NULL,
    codigo_orden_compra INT UNSIGNED  NOT NULL,
    num_pedido          VARCHAR(20)   NOT NULL,
    num_guia            VARCHAR(20)   NOT NULL,
    nombre_vendedor     VARCHAR(100)  NOT NULL,
    fecha_emision       DATE          NOT NULL,
    condicion_pago      VARCHAR(50)   NOT NULL,
    igv                 DECIMAL(12,2) NULL,
    total               DECIMAL(12,2) NOT NULL,
    activo              TINYINT(1)    NOT NULL DEFAULT 1,
    PRIMARY KEY (ruc_proveedor, num_factura),
    INDEX idx_factura_orden (codigo_orden_compra),
    CONSTRAINT fk_factura_proveedor FOREIGN KEY (ruc_proveedor)
        REFERENCES proveedor (ruc)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_factura_orden FOREIGN KEY (codigo_orden_compra)
        REFERENCES orden_compra (codigo_orden_compra)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_factura_numero CHECK (num_factura REGEXP '^[A-Z0-9]{4}-[0-9]{1,8}$'),
    CONSTRAINT chk_factura_total  CHECK (total > 0)
) ENGINE=InnoDB;

CREATE TABLE registro_control (
    num_linea       INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    codigo_producto INT UNSIGNED  NOT NULL,
    cantidad        INT UNSIGNED  NOT NULL,
    fecha           DATE          NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    total           DECIMAL(12,2)
        GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    activo          TINYINT(1)    NOT NULL DEFAULT 1,
    PRIMARY KEY (num_linea),
    INDEX idx_registro_producto_fecha (codigo_producto, fecha),
    CONSTRAINT fk_registro_producto FOREIGN KEY (codigo_producto)
        REFERENCES producto (codigo_producto)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_registro_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_registro_precio   CHECK (precio_unitario > 0)
) ENGINE=InnoDB;

CREATE TABLE bitacora_bajas (
    id_bitacora     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    tabla_afectada  VARCHAR(50)  NOT NULL,
    id_registro     VARCHAR(50)  NOT NULL,
    accion          VARCHAR(100) NOT NULL,
    fecha_evento    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_bitacora)
) ENGINE=InnoDB;
