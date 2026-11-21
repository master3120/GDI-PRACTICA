-- 03_insertar_datos.sql: Carga inicial ampliada para pruebas completas del aplicativo. Ejecutar tercero.

SET NAMES utf8mb4;
USE bd_veterinaria;

START TRANSACTION;

INSERT INTO categoria_producto (id_categoria, nombre_categoria) VALUES
    (1, 'Antiparasitarios'),
    (2, 'Antibióticos'),
    (3, 'Vitaminas y suplementos'),
    (4, 'Antisépticos y tópicos'),
    (5, 'Alimentos'),
    (6, 'Higiene'),
    (7, 'Material e insumos médicos'),
    (8, 'Analgésicos y antiinflamatorios');

INSERT INTO presentacion_producto (id_presentacion, nombre_presentacion) VALUES
    (1,  'Frasco 500 ml'),
    (2,  'Frasco 250 ml'),
    (3,  'Frasco 100 ml'),
    (4,  'Frasco 30 ml'),
    (5,  'Frasco 20 ml'),
    (6,  'Sobre 50 g'),
    (7,  'Sobre 100 g'),
    (8,  'Pote 50 g'),
    (9,  'Pote 100 g'),
    (10, 'Pote 200 g'),
    (11, 'Pote 1 kg'),
    (12, 'Caja 50 sobres de 10 g'),
    (13, 'Costal 15 kg'),
    (14, 'Bolsa 3 kg'),
    (15, 'Caja 100 unidades'),
    (16, 'Frasco 50 ml');

INSERT INTO veterinaria (ruc, nombre, correo, calle, numero, manzana, lote) VALUES
    ('10248901743', 'Veterinaria Carlos Holguino', 'contacto@vetholguino.example.com',
     'Av. San Martín', '605', NULL, NULL);

INSERT INTO telefono_veterinaria (ruc_veterinaria, telefono) VALUES
    ('10248901743', '941254170');

INSERT INTO proveedor (ruc, razon_social, correo, calle, numero, manzana, lote) VALUES
    ('20112328921', 'Reana - Representaciones Agropecuarias Nacional E.I.R.L.', 'ventas@reana.example.com',
     'Jr. Los Príncipes', NULL, 'X4', '36'),
    ('20495863217', 'Distribuidora Veterinaria Andina S.A.C.', 'pedidos@vetandina.example.com',
     'Av. Collasuyo', '412', NULL, NULL),
    ('20531947268', 'Laboratorios Altiplano del Sur S.A.C.', 'ventas@labaltiplano.example.com',
     'Av. Circunvalación', '1180', NULL, NULL),
    ('20601275493', 'Agropecuaria Los Andes E.I.R.L.', 'contacto@agrolosandes.example.com',
     'Jr. Bolívar', '235', NULL, NULL),
    ('20608841290', 'Insumos Ganaderos del Cusco S.R.L.', 'ventas@insumosganaderos.example.com',
     'Av. El Sol', '890', NULL, NULL);

INSERT INTO telefono_proveedor (ruc_proveedor, telefono) VALUES
    ('20112328921', '956318420'),
    ('20112328921', '984207715'),
    ('20495863217', '084231845'),
    ('20495863217', '974112608'),
    ('20531947268', '051325770'),
    ('20601275493', '962845031'),
    ('20608841290', '984551209');

INSERT INTO producto (codigo_producto, nombre, descripcion, cantidad_disponible, id_categoria, id_presentacion) VALUES
    (1,  'Cintaquantel 10% suspensión oral', 'Suspensión oral al 10%', 4,  1, 1),
    (2,  'Cintaquantel 10% suspensión oral', 'Suspensión oral al 10%', 8,  1, 2),
    (3,  'Cintaquantel 10% suspensión oral', 'Suspensión oral al 10%', 10, 1, 3),
    (4,  'Tintura de yodo 7%',               'Solución tópica al 7%',  12, 4, 4),
    (5,  'Reamicin Super',                   'Polvo oral',             20, 2, 6),
    (6,  'Reamicin Super',                   'Polvo oral',             15, 2, 7),
    (7,  'Entero-Protect',                   'Polvo oral',             9,  3, 6),
    (8,  'Reavit B',                         'Polvo soluble',          18, 3, 7),
    (9,  'Reavit B',                         'Polvo soluble',          7,  3, 6),
    (10, 'Sulfa K',                          'Polvo soluble',          5,  2, 6),
    (11, 'Ubresanol',                        'Ungüento',               10, 4, 9),
    (12, 'Ubresanol',                        'Ungüento',               25, 4, 8),
    (13, 'Ubresanol',                        'Ungüento',               8,  4, 10),
    (14, 'Reavit B',                         'Polvo soluble, caja',    2,  3, 12),
    (15, 'Sulfa K',                          'Polvo soluble, caja',    1,  2, 12),
    (16, 'Entero-Protect',                   'Polvo oral, caja',       2,  3, 12),
    (17, 'Reamicin Super',                   'Polvo oral, caja',       1,  2, 12),
    (18, 'Ubresanol',                        'Ungüento',               4,  4, 11),
    (19, 'Ciclosan Plus',                    'Antiparasitario',        15, 1, 5),
    (20, 'Alimento balanceado para perros adultos', 'Saco premium',    4,  5, 13),
    (21, 'Shampoo antipulgas',               'Uso canino y felino',    8,  6, 2),
    (22, 'Amoxicilina inyectable',           'Antibiótico inyectable', 5,  2, 3),
    (23, 'Vitamina ADE inyectable',          'Suplemento vitamínico',  9,  3, 3),
    (24, 'Ivermectina 1% inyectable',        'Antiparasitario inyectable', 8, 1, 3),
    (25, 'Oxitetraciclina 20% LA',           'Antibiótico de larga acción', 6, 2, 3),
    (26, 'Complejo B inyectable',            'Vitaminas del complejo B', 10, 3, 3),
    (27, 'Alimento balanceado para gatos adultos', 'Control bolas de pelo', 8, 5, 14),
    (28, 'Jeringa descartable 10 ml',        'Estéril, con aguja',     20, 7, 15),
    (29, 'Meloxicam 2% inyectable',          'Antiinflamatorio no esteroideo', 6, 8, 16),
    (30, 'Fenbendazol 10% suspensión',       'Antiparasitario de amplio espectro', 9, 1, 1);

INSERT INTO suministra (ruc_proveedor, codigo_producto) VALUES
    ('20112328921', 1),  ('20112328921', 2),  ('20112328921', 3),  ('20112328921', 4),
    ('20112328921', 5),  ('20112328921', 6),  ('20112328921', 7),  ('20112328921', 8),
    ('20112328921', 9),  ('20112328921', 10), ('20112328921', 11), ('20112328921', 12),
    ('20112328921', 13), ('20112328921', 14), ('20112328921', 15), ('20112328921', 16),
    ('20112328921', 17), ('20112328921', 18),
    ('20495863217', 4),  ('20495863217', 19), ('20495863217', 20), ('20495863217', 21),
    ('20495863217', 27), ('20495863217', 28),
    ('20531947268', 19), ('20531947268', 22), ('20531947268', 23), ('20531947268', 24),
    ('20531947268', 25), ('20531947268', 26), ('20531947268', 29),
    ('20601275493', 21), ('20601275493', 24), ('20601275493', 25), ('20601275493', 28),
    ('20608841290', 1),  ('20608841290', 29), ('20608841290', 30);

INSERT INTO orden_compra (codigo_orden_compra, ruc_veterinaria, ruc_proveedor, fecha_emision, fecha_entrega) VALUES
    (1,  '10248901743', '20112328921', '2025-12-10', '2025-12-22'),
    (2,  '10248901743', '20495863217', '2026-01-15', '2026-01-20'),
    (3,  '10248901743', '20112328921', '2026-03-05', NULL),
    (4,  '10248901743', '20531947268', '2026-04-02', '2026-04-09'),
    (5,  '10248901743', '20601275493', '2026-05-12', '2026-05-15'),
    (6,  '10248901743', '20112328921', '2026-06-10', '2026-06-22'),
    (7,  '10248901743', '20531947268', '2026-08-04', '2026-08-11'),
    (8,  '10248901743', '20495863217', '2026-10-05', NULL),
    (9,  '10248901743', '20608841290', '2026-10-18', '2026-10-23'),
    (10, '10248901743', '20608841290', '2026-11-12', NULL);

INSERT INTO detalle_orden_compra (codigo_orden_compra, numero_linea, codigo_producto, cantidad_requerida, precio_unitario) VALUES
    (1, 1,  1,  13,  45.41),
    (1, 2,  2,  13,  24.99),
    (1, 3,  3,  12,  11.90),
    (1, 4,  4,  72,   7.29),
    (1, 5,  5,  55,   3.99),
    (1, 6,  6,  13,   7.63),
    (1, 7,  7,  13,   6.10),
    (1, 8,  8,  13,   4.52),
    (1, 9,  9,  13,   2.58),
    (1, 10, 10, 13,   6.32),
    (1, 11, 11, 12,   5.85),
    (1, 12, 12, 156,  2.80),
    (1, 13, 13, 12,   8.39),
    (1, 14, 14, 1,   34.96),
    (1, 15, 15, 1,   93.36),
    (1, 16, 16, 1,   91.40),
    (1, 17, 17, 1,   83.71),
    (1, 18, 18, 1,   41.66),
    (2, 1, 19, 10,   4.50),
    (2, 2, 21, 6,   18.50),
    (2, 3, 20, 4,  118.00),
    (3, 1, 1,  6,   46.50),
    (3, 2, 2,  6,   25.30),
    (3, 3, 4,  24,   7.40),
    (3, 4, 11, 12,   5.90),
    (4, 1, 22, 12,  21.00),
    (4, 2, 23, 12,  16.50),
    (5, 1, 24, 10,  38.00),
    (5, 2, 25, 8,   42.50),
    (5, 3, 28, 5,   24.00),
    (6, 1, 14, 2,   36.50),
    (6, 2, 15, 2,   95.00),
    (6, 3, 16, 2,   92.50),
    (6, 4, 17, 2,   85.00),
    (6, 5, 1,  10,  46.00),
    (7, 1, 22, 10,  21.50),
    (7, 2, 23, 10,  17.00),
    (7, 3, 26, 12,  14.00),
    (8, 1, 20, 4,  120.00),
    (8, 2, 27, 4,   98.00),
    (8, 3, 4,  30,   7.20),
    (9, 1, 29, 8,   28.00),
    (9, 2, 30, 6,   41.50),
    (10, 1, 1, 5,   45.80),
    (10, 2, 30, 10, 41.00);

INSERT INTO factura_electronica (ruc_proveedor, num_factura, codigo_orden_compra, num_pedido, num_guia,
                                 nombre_vendedor, fecha_emision, condicion_pago, igv, total) VALUES
    ('20112328921', 'F001-00016306', 1, '00007879', 'T00100420419',
     'Jacob Osorio Advíncula', '2025-12-22', 'Factura 30 días', 559.29, 3666.48),
    ('20495863217', 'F002-00004501', 2, '00001234', 'T00100056789',
     'Rosa Mamani Quispe', '2026-01-20', 'Contado', 113.04, 741.04),
    ('20601275493', 'E001-00000873', 5, '00000412', 'T00200003310',
     'Julio Ccama Huanca', '2026-05-15', 'Contado', 151.20, 991.20),
    ('20112328921', 'F001-00017102', 6, '00008115', 'T00100433276',
     'Jacob Osorio Advíncula', '2026-06-22', 'Factura 30 días', 196.79, 1290.04),
    ('20531947268', 'F003-00007215', 7, '00000931', 'T00300018842',
     'Marisol Condori Huamán', '2026-08-11', 'Crédito 15 días', 99.54, 652.54),
    ('20608841290', 'F001-00001190', 9, '00000518', 'T00100009912',
     'Carlos Quispe Mamani', '2026-10-23', 'Contado', NULL, 558.14);

INSERT INTO registro_control (num_linea, codigo_producto, cantidad, fecha, precio_unitario) VALUES
    (1,  19, 10,  '2021-10-23', 4.50),
    (2,  1,  13,  '2025-12-22', 45.41),
    (3,  2,  13,  '2025-12-22', 24.99),
    (4,  3,  12,  '2025-12-22', 11.90),
    (5,  4,  72,  '2025-12-22',  7.29),
    (6,  12, 156, '2025-12-22',  2.80),
    (7,  18, 1,   '2025-12-22', 41.66),
    (8,  19, 10,  '2026-01-20',  4.50),
    (9,  21, 6,   '2026-01-20', 18.50),
    (10, 20, 4,   '2026-01-20', 118.00),
    (11, 22, 12,  '2026-04-09', 21.00),
    (12, 23, 12,  '2026-04-09', 16.50),
    (13, 24, 10,  '2026-05-15', 38.00),
    (14, 25, 8,   '2026-05-15', 42.50),
    (15, 28, 5,   '2026-05-15', 24.00),
    (16, 14, 2,   '2026-06-22', 36.50),
    (17, 15, 2,   '2026-06-22', 95.00),
    (18, 16, 2,   '2026-06-22', 92.50),
    (19, 17, 2,   '2026-06-22', 85.00),
    (20, 1,  10,  '2026-06-22', 46.00),
    (21, 22, 10,  '2026-08-11', 21.50),
    (22, 23, 10,  '2026-08-11', 17.00),
    (23, 26, 12,  '2026-08-11', 14.00),
    (24, 29, 8,   '2026-10-23', 28.00),
    (25, 30, 6,   '2026-10-23', 41.50);

COMMIT;
