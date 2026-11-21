-- 02_triggers_y_procedimientos.sql: Triggers automáticos, CRUD completo con borrado lógico
-- y las 10 consultas/reportes encapsuladas en Stored Procedures. Ejecutar segundo.

USE bd_veterinaria;

DELIMITER $$

CREATE TRIGGER trg_registro_control_ai
AFTER INSERT ON registro_control
FOR EACH ROW
BEGIN
    IF NEW.activo = 1 THEN
        UPDATE producto
        SET cantidad_disponible = cantidad_disponible + NEW.cantidad
        WHERE codigo_producto = NEW.codigo_producto;
    END IF;
END$$

CREATE TRIGGER trg_registro_control_au
AFTER UPDATE ON registro_control
FOR EACH ROW
BEGIN
    IF OLD.activo = 1 AND NEW.activo = 0 THEN
        UPDATE producto
        SET cantidad_disponible = IF(cantidad_disponible >= OLD.cantidad, cantidad_disponible - OLD.cantidad, 0)
        WHERE codigo_producto = OLD.codigo_producto;

        INSERT INTO bitacora_bajas (tabla_afectada, id_registro, accion)
        VALUES ('registro_control', CAST(NEW.num_linea AS CHAR), 'Borrado lógico y descuento de stock');
    END IF;
END$$

CREATE TRIGGER trg_detalle_orden_bi
BEFORE INSERT ON detalle_orden_compra
FOR EACH ROW
BEGIN
    DECLARE v_ruc_prov CHAR(11);
    DECLARE v_existe INT;

    SELECT ruc_proveedor INTO v_ruc_prov
    FROM orden_compra
    WHERE codigo_orden_compra = NEW.codigo_orden_compra;

    SELECT COUNT(*) INTO v_existe
    FROM suministra
    WHERE ruc_proveedor = v_ruc_prov AND codigo_producto = NEW.codigo_producto;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de integridad: El proveedor de esta orden no suministra el producto seleccionado.';
    END IF;
END$$

CREATE TRIGGER trg_factura_bi
BEFORE INSERT ON factura_electronica
FOR EACH ROW
BEGIN
    IF NEW.igv IS NULL THEN
        SET NEW.igv = ROUND(NEW.total - (NEW.total / 1.18), 2);
    END IF;
END$$

CREATE TRIGGER trg_producto_baja_au
AFTER UPDATE ON producto
FOR EACH ROW
BEGIN
    IF OLD.activo = 1 AND NEW.activo = 0 THEN
        INSERT INTO bitacora_bajas (tabla_afectada, id_registro, accion)
        VALUES ('producto', CAST(NEW.codigo_producto AS CHAR), CONCAT('Baja lógica producto: ', NEW.nombre));
    END IF;
END$$

CREATE TRIGGER trg_orden_baja_au
AFTER UPDATE ON orden_compra
FOR EACH ROW
BEGIN
    IF OLD.activo = 1 AND NEW.activo = 0 THEN
        INSERT INTO bitacora_bajas (tabla_afectada, id_registro, accion)
        VALUES ('orden_compra', CAST(NEW.codigo_orden_compra AS CHAR), 'Anulación (borrado lógico) de orden de compra');
    END IF;
END$$

CREATE PROCEDURE sp_insertar_proveedor(
    IN p_ruc CHAR(11),
    IN p_razon_social VARCHAR(100),
    IN p_correo VARCHAR(100),
    IN p_calle VARCHAR(100),
    IN p_numero VARCHAR(10),
    IN p_manzana VARCHAR(10),
    IN p_lote VARCHAR(10),
    IN p_telefono CHAR(9)
)
BEGIN
    INSERT INTO proveedor (ruc, razon_social, correo, calle, numero, manzana, lote, activo)
    VALUES (p_ruc, p_razon_social, p_correo, p_calle, NULLIF(p_numero,''), NULLIF(p_manzana,''), NULLIF(p_lote,''), 1);

    IF p_telefono IS NOT NULL AND p_telefono <> '' THEN
        INSERT INTO telefono_proveedor (ruc_proveedor, telefono)
        VALUES (p_ruc, p_telefono);
    END IF;
END$$

CREATE PROCEDURE sp_actualizar_proveedor(
    IN p_ruc CHAR(11),
    IN p_razon_social VARCHAR(100),
    IN p_correo VARCHAR(100),
    IN p_calle VARCHAR(100),
    IN p_numero VARCHAR(10),
    IN p_manzana VARCHAR(10),
    IN p_lote VARCHAR(10)
)
BEGIN
    UPDATE proveedor
    SET razon_social = p_razon_social,
        correo = p_correo,
        calle = p_calle,
        numero = NULLIF(p_numero,''),
        manzana = NULLIF(p_manzana,''),
        lote = NULLIF(p_lote,'')
    WHERE ruc = p_ruc AND activo = 1;
END$$

CREATE PROCEDURE sp_eliminar_logico_proveedor(IN p_ruc CHAR(11))
BEGIN
    UPDATE proveedor SET activo = 0 WHERE ruc = p_ruc;
    INSERT INTO bitacora_bajas (tabla_afectada, id_registro, accion)
    VALUES ('proveedor', p_ruc, 'Borrado lógico de proveedor');
END$$

CREATE PROCEDURE sp_listar_proveedores(IN p_filtro VARCHAR(100))
BEGIN
    SELECT p.ruc, p.razon_social, p.correo, p.calle,
           COALESCE(p.numero, '') AS numero,
           COALESCE(p.manzana, '') AS manzana,
           COALESCE(p.lote, '') AS lote,
           COALESCE(GROUP_CONCAT(t.telefono SEPARATOR ', '), 'Sin teléfono') AS telefonos
    FROM proveedor p
    LEFT JOIN telefono_proveedor t ON t.ruc_proveedor = p.ruc
    WHERE p.activo = 1
      AND (p.razon_social LIKE CONCAT('%', p_filtro, '%') OR p.ruc LIKE CONCAT('%', p_filtro, '%'))
    GROUP BY p.ruc, p.razon_social, p.correo, p.calle, p.numero, p.manzana, p.lote
    ORDER BY p.razon_social;
END$$

CREATE PROCEDURE sp_insertar_producto(
    IN p_nombre VARCHAR(100),
    IN p_descripcion VARCHAR(255),
    IN p_cantidad_disponible INT UNSIGNED,
    IN p_id_categoria INT UNSIGNED,
    IN p_id_presentacion INT UNSIGNED,
    IN p_ruc_proveedor CHAR(11)
)
BEGIN
    DECLARE v_nuevo_id INT UNSIGNED;
    INSERT INTO producto (nombre, descripcion, cantidad_disponible, id_categoria, id_presentacion, activo)
    VALUES (p_nombre, NULLIF(p_descripcion,''), p_cantidad_disponible, p_id_categoria, p_id_presentacion, 1);

    SET v_nuevo_id = LAST_INSERT_ID();

    IF p_ruc_proveedor IS NOT NULL AND p_ruc_proveedor <> '' THEN
        INSERT IGNORE INTO suministra (ruc_proveedor, codigo_producto)
        VALUES (p_ruc_proveedor, v_nuevo_id);
    END IF;
END$$

CREATE PROCEDURE sp_actualizar_producto(
    IN p_codigo_producto INT UNSIGNED,
    IN p_nombre VARCHAR(100),
    IN p_descripcion VARCHAR(255),
    IN p_cantidad_disponible INT UNSIGNED,
    IN p_id_categoria INT UNSIGNED,
    IN p_id_presentacion INT UNSIGNED
)
BEGIN
    UPDATE producto
    SET nombre = p_nombre,
        descripcion = NULLIF(p_descripcion,''),
        cantidad_disponible = p_cantidad_disponible,
        id_categoria = p_id_categoria,
        id_presentacion = p_id_presentacion
    WHERE codigo_producto = p_codigo_producto AND activo = 1;
END$$

CREATE PROCEDURE sp_eliminar_logico_producto(IN p_codigo_producto INT UNSIGNED)
BEGIN
    UPDATE producto SET activo = 0 WHERE codigo_producto = p_codigo_producto;
END$$

CREATE PROCEDURE sp_listar_productos(IN p_filtro VARCHAR(100))
BEGIN
    SELECT pr.codigo_producto, pr.nombre, COALESCE(pr.descripcion, '') AS descripcion,
           pr.cantidad_disponible, c.id_categoria, c.nombre_categoria,
           pp.id_presentacion, pp.nombre_presentacion
    FROM producto pr
    JOIN categoria_producto c ON c.id_categoria = pr.id_categoria
    JOIN presentacion_producto pp ON pp.id_presentacion = pr.id_presentacion
    WHERE pr.activo = 1
      AND (pr.nombre LIKE CONCAT('%', p_filtro, '%') OR c.nombre_categoria LIKE CONCAT('%', p_filtro, '%'))
    ORDER BY pr.codigo_producto;
END$$

CREATE PROCEDURE sp_listar_categorias()
BEGIN
    SELECT id_categoria, nombre_categoria FROM categoria_producto WHERE activo = 1 ORDER BY nombre_categoria;
END$$

CREATE PROCEDURE sp_listar_presentaciones()
BEGIN
    SELECT id_presentacion, nombre_presentacion FROM presentacion_producto WHERE activo = 1 ORDER BY nombre_presentacion;
END$$

CREATE PROCEDURE sp_insertar_orden_compra(
    IN p_ruc_proveedor CHAR(11),
    IN p_fecha_emision DATE,
    IN p_fecha_entrega DATE,
    OUT p_codigo_generado INT UNSIGNED
)
BEGIN
    INSERT INTO orden_compra (ruc_veterinaria, ruc_proveedor, fecha_emision, fecha_entrega, activo)
    VALUES ('10248901743', p_ruc_proveedor, p_fecha_emision, p_fecha_entrega, 1);
    SET p_codigo_generado = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_insertar_detalle_orden(
    IN p_codigo_orden INT UNSIGNED,
    IN p_numero_linea SMALLINT UNSIGNED,
    IN p_codigo_producto INT UNSIGNED,
    IN p_cantidad_requerida INT UNSIGNED,
    IN p_precio_unitario DECIMAL(10,2)
)
BEGIN
    INSERT INTO detalle_orden_compra (codigo_orden_compra, numero_linea, codigo_producto, cantidad_requerida, precio_unitario)
    VALUES (p_codigo_orden, p_numero_linea, p_codigo_producto, p_cantidad_requerida, p_precio_unitario);
END$$

CREATE PROCEDURE sp_actualizar_fecha_entrega_orden(
    IN p_codigo_orden INT UNSIGNED,
    IN p_fecha_entrega DATE
)
BEGIN
    UPDATE orden_compra
    SET fecha_entrega = p_fecha_entrega
    WHERE codigo_orden_compra = p_codigo_orden AND activo = 1;
END$$

CREATE PROCEDURE sp_eliminar_logico_orden(IN p_codigo_orden INT UNSIGNED)
BEGIN
    UPDATE orden_compra SET activo = 0 WHERE codigo_orden_compra = p_codigo_orden;
END$$

CREATE PROCEDURE sp_listar_ordenes()
BEGIN
    SELECT o.codigo_orden_compra, o.ruc_proveedor, p.razon_social,
           o.fecha_emision, COALESCE(CAST(o.fecha_entrega AS CHAR), 'Pendiente') AS estado_entrega,
           COUNT(d.numero_linea) AS total_lineas,
           COALESCE(ROUND(SUM(d.subtotal), 2), 0.00) AS monto_total
    FROM orden_compra o
    JOIN proveedor p ON p.ruc = o.ruc_proveedor
    LEFT JOIN detalle_orden_compra d ON d.codigo_orden_compra = o.codigo_orden_compra
    WHERE o.activo = 1
    GROUP BY o.codigo_orden_compra, o.ruc_proveedor, p.razon_social, o.fecha_emision, o.fecha_entrega
    ORDER BY o.codigo_orden_compra DESC;
END$$

CREATE PROCEDURE sp_listar_productos_por_proveedor(IN p_ruc_proveedor CHAR(11))
BEGIN
    SELECT pr.codigo_producto, CONCAT(pr.nombre, ' (', pp.nombre_presentacion, ')') AS producto_completo
    FROM suministra s
    JOIN producto pr ON pr.codigo_producto = s.codigo_producto
    JOIN presentacion_producto pp ON pp.id_presentacion = pr.id_presentacion
    WHERE s.ruc_proveedor = p_ruc_proveedor AND pr.activo = 1
    ORDER BY pr.nombre;
END$$

CREATE PROCEDURE sp_insertar_factura(
    IN p_ruc_proveedor CHAR(11),
    IN p_num_factura VARCHAR(13),
    IN p_codigo_orden INT UNSIGNED,
    IN p_num_pedido VARCHAR(20),
    IN p_num_guia VARCHAR(20),
    IN p_nombre_vendedor VARCHAR(100),
    IN p_fecha_emision DATE,
    IN p_condicion_pago VARCHAR(50),
    IN p_total DECIMAL(12,2)
)
BEGIN
    INSERT INTO factura_electronica (ruc_proveedor, num_factura, codigo_orden_compra, num_pedido, num_guia,
                                     nombre_vendedor, fecha_emision, condicion_pago, igv, total, activo)
    VALUES (p_ruc_proveedor, p_num_factura, p_codigo_orden, p_num_pedido, p_num_guia,
            p_nombre_vendedor, p_fecha_emision, p_condicion_pago, NULL, p_total, 1);
END$$

CREATE PROCEDURE sp_eliminar_logico_factura(
    IN p_ruc_proveedor CHAR(11),
    IN p_num_factura VARCHAR(13)
)
BEGIN
    UPDATE factura_electronica
    SET activo = 0
    WHERE ruc_proveedor = p_ruc_proveedor AND num_factura = p_num_factura;

    INSERT INTO bitacora_bajas (tabla_afectada, id_registro, accion)
    VALUES ('factura_electronica', CONCAT(p_ruc_proveedor, '-', p_num_factura), 'Borrado lógico de factura');
END$$

CREATE PROCEDURE sp_listar_facturas()
BEGIN
    SELECT f.num_factura, f.ruc_proveedor, p.razon_social, f.codigo_orden_compra,
           f.num_pedido, f.num_guia, f.nombre_vendedor, f.fecha_emision,
           f.condicion_pago, f.igv, f.total
    FROM factura_electronica f
    JOIN proveedor p ON p.ruc = f.ruc_proveedor
    WHERE f.activo = 1
    ORDER BY f.fecha_emision DESC;
END$$

CREATE PROCEDURE sp_insertar_registro_control(
    IN p_codigo_producto INT UNSIGNED,
    IN p_cantidad INT UNSIGNED,
    IN p_fecha DATE,
    IN p_precio_unitario DECIMAL(10,2)
)
BEGIN
    INSERT INTO registro_control (codigo_producto, cantidad, fecha, precio_unitario, activo)
    VALUES (p_codigo_producto, p_cantidad, p_fecha, p_precio_unitario, 1);
END$$

CREATE PROCEDURE sp_eliminar_logico_registro_control(IN p_num_linea INT UNSIGNED)
BEGIN
    UPDATE registro_control SET activo = 0 WHERE num_linea = p_num_linea;
END$$

CREATE PROCEDURE sp_listar_registro_control()
BEGIN
    SELECT rc.num_linea, rc.fecha, pr.nombre AS producto, pp.nombre_presentacion AS presentacion,
           rc.cantidad, rc.precio_unitario, rc.total
    FROM registro_control rc
    JOIN producto pr ON pr.codigo_producto = rc.codigo_producto
    JOIN presentacion_producto pp ON pp.id_presentacion = pr.id_presentacion
    WHERE rc.activo = 1
    ORDER BY rc.fecha DESC, rc.num_linea DESC;
END$$

CREATE PROCEDURE sp_reporte_01_stock_critico()
BEGIN
    SELECT pr.codigo_producto AS Codigo, pr.nombre AS Producto,
           pp.nombre_presentacion AS Presentacion,
           c.nombre_categoria AS Categoria, pr.cantidad_disponible AS Stock_Actual
    FROM producto pr
    JOIN categoria_producto c     ON c.id_categoria = pr.id_categoria
    JOIN presentacion_producto pp ON pp.id_presentacion = pr.id_presentacion
    WHERE pr.activo = 1 AND pr.cantidad_disponible <= 10
    ORDER BY pr.cantidad_disponible ASC, pr.nombre ASC;
END$$

CREATE PROCEDURE sp_reporte_02_proveedores_producto(IN p_nombre_producto VARCHAR(100))
BEGIN
    SELECT pr.nombre AS Producto, p.ruc AS RUC, p.razon_social AS Proveedor,
           COALESCE(t.telefono, 'Sin teléfono') AS Telefono
    FROM producto pr
    JOIN suministra s               ON s.codigo_producto = pr.codigo_producto
    JOIN proveedor p                ON p.ruc = s.ruc_proveedor
    LEFT JOIN telefono_proveedor t  ON t.ruc_proveedor = p.ruc
    WHERE pr.activo = 1 AND p.activo = 1
      AND pr.nombre LIKE CONCAT('%', p_nombre_producto, '%')
    ORDER BY p.razon_social, t.telefono;
END$$

CREATE PROCEDURE sp_reporte_03_stock_bajo_por_proveedor()
BEGIN
    SELECT p.razon_social AS Proveedor, pr.codigo_producto AS Codigo,
           pr.nombre AS Producto, pp.nombre_presentacion AS Presentacion,
           pr.cantidad_disponible AS Stock
    FROM producto pr
    JOIN suministra s             ON s.codigo_producto = pr.codigo_producto
    JOIN proveedor p              ON p.ruc = s.ruc_proveedor
    JOIN presentacion_producto pp ON pp.id_presentacion = pr.id_presentacion
    WHERE pr.activo = 1 AND p.activo = 1 AND pr.cantidad_disponible <= 10
    ORDER BY p.razon_social, pr.cantidad_disponible, pr.nombre;
END$$

CREATE PROCEDURE sp_reporte_04_historial_precios(IN p_codigo_producto INT UNSIGNED)
BEGIN
    SELECT pr.nombre AS Producto, pp.nombre_presentacion AS Presentacion,
           o.codigo_orden_compra AS Nro_Orden, o.fecha_emision AS Fecha,
           p.razon_social AS Proveedor, d.cantidad_requerida AS Cantidad,
           d.precio_unitario AS Precio_Unitario
    FROM detalle_orden_compra d
    JOIN orden_compra o           ON o.codigo_orden_compra = d.codigo_orden_compra
    JOIN proveedor p              ON p.ruc = o.ruc_proveedor
    JOIN producto pr              ON pr.codigo_producto = d.codigo_producto
    JOIN presentacion_producto pp ON pp.id_presentacion = pr.id_presentacion
    WHERE o.activo = 1 AND d.codigo_producto = p_codigo_producto
    ORDER BY o.fecha_emision ASC;
END$$

CREATE PROCEDURE sp_reporte_05_detalle_orden(IN p_codigo_orden INT UNSIGNED)
BEGIN
    SELECT d.numero_linea AS Linea, pr.nombre AS Producto,
           pp.nombre_presentacion AS Presentacion,
           d.cantidad_requerida AS Cantidad, d.precio_unitario AS Precio_Unit,
           d.subtotal AS Subtotal
    FROM detalle_orden_compra d
    JOIN orden_compra o           ON o.codigo_orden_compra = d.codigo_orden_compra
    JOIN producto pr              ON pr.codigo_producto = d.codigo_producto
    JOIN presentacion_producto pp ON pp.id_presentacion = pr.id_presentacion
    WHERE o.activo = 1 AND d.codigo_orden_compra = p_codigo_orden
    ORDER BY d.numero_linea ASC;
END$$

CREATE PROCEDURE sp_reporte_06_ordenes_pendientes()
BEGIN
    SELECT o.codigo_orden_compra AS Nro_Orden, p.razon_social AS Proveedor,
           o.fecha_emision AS Fecha_Emision, COUNT(d.numero_linea) AS Items,
           ROUND(SUM(d.subtotal), 2) AS Monto_Total
    FROM orden_compra o
    JOIN proveedor p            ON p.ruc = o.ruc_proveedor
    JOIN detalle_orden_compra d ON d.codigo_orden_compra = o.codigo_orden_compra
    WHERE o.activo = 1 AND o.fecha_entrega IS NULL
    GROUP BY o.codigo_orden_compra, p.razon_social, o.fecha_emision
    ORDER BY o.fecha_emision ASC;
END$$

CREATE PROCEDURE sp_reporte_07_tiempo_entrega_ordenes()
BEGIN
    SELECT o.codigo_orden_compra AS Nro_Orden, p.razon_social AS Proveedor,
           o.fecha_emision AS Emision, o.fecha_entrega AS Entrega,
           DATEDIFF(o.fecha_entrega, o.fecha_emision) AS Dias_Demora
    FROM orden_compra o
    JOIN proveedor p ON p.ruc = o.ruc_proveedor
    WHERE o.activo = 1 AND o.fecha_entrega IS NOT NULL
    ORDER BY Dias_Demora DESC;
END$$

CREATE PROCEDURE sp_reporte_08_cuadre_orden_factura()
BEGIN
    SELECT o.codigo_orden_compra AS Nro_Orden, f.num_factura AS Factura,
           ROUND(t.monto, 2) AS Gravado_Orden,
           ROUND(t.monto * 1.18, 2) AS Total_Orden_IGV,
           f.total AS Total_Factura,
           ROUND(f.total - t.monto * 1.18, 2) AS Diferencia,
           CASE WHEN ABS(f.total - t.monto * 1.18) <= 2.00
                THEN 'Conforme' ELSE 'Revisar Discrepancia' END AS Estado_Auditoria
    FROM orden_compra o
    JOIN (SELECT codigo_orden_compra, SUM(subtotal) AS monto
          FROM detalle_orden_compra
          GROUP BY codigo_orden_compra) t ON t.codigo_orden_compra = o.codigo_orden_compra
    JOIN factura_electronica f          ON f.codigo_orden_compra = o.codigo_orden_compra
    WHERE o.activo = 1 AND f.activo = 1
    ORDER BY o.codigo_orden_compra;
END$$

CREATE PROCEDURE sp_reporte_09_entregadas_sin_factura()
BEGIN
    SELECT o.codigo_orden_compra AS Nro_Orden, p.razon_social AS Proveedor,
           o.fecha_entrega AS Fecha_Entrega, ROUND(SUM(d.subtotal), 2) AS Monto_Gravado
    FROM orden_compra o
    JOIN proveedor p              ON p.ruc = o.ruc_proveedor
    JOIN detalle_orden_compra d   ON d.codigo_orden_compra = o.codigo_orden_compra
    LEFT JOIN factura_electronica f ON f.codigo_orden_compra = o.codigo_orden_compra AND f.activo = 1
    WHERE o.activo = 1 AND o.fecha_entrega IS NOT NULL AND f.num_factura IS NULL
    GROUP BY o.codigo_orden_compra, p.razon_social, o.fecha_entrega;
END$$

CREATE PROCEDURE sp_reporte_10_monto_por_proveedor()
BEGIN
    SELECT p.ruc AS RUC, p.razon_social AS Proveedor,
           COUNT(DISTINCT o.codigo_orden_compra) AS Total_Ordenes,
           ROUND(SUM(d.subtotal), 2) AS Monto_Total_Comprado
    FROM proveedor p
    JOIN orden_compra o         ON o.ruc_proveedor = p.ruc
    JOIN detalle_orden_compra d ON d.codigo_orden_compra = o.codigo_orden_compra
    WHERE p.activo = 1 AND o.activo = 1
    GROUP BY p.ruc, p.razon_social
    ORDER BY Monto_Total_Comprado DESC;
END$$

DELIMITER ;
