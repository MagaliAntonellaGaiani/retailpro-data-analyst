-- Ventas_Tech_DB
-- Modulo 5 - Pre-entrega: Consultas con JOINs
-- Magali Gaiani

-- Nota: para esta entrega agregue al script del modulo 3 la tabla territorios
-- (region de cada cliente), un cliente y un producto sin ventas.


-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Una fila por venta con los datos del cliente, producto, categoria y region
SELECT
    v.id_venta,
    v.fecha_venta,
    c.nombre AS cliente,
    c.ciudad,
    t.region,
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN territorios t ON c.id_territorio = t.id_territorio
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;


-- Consulta 2: Clientes sin ventas (LEFT JOIN)
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;


-- Consulta 3: Productos sin ventas (LEFT JOIN)
SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;


-- Consulta 4: Consolidado por canal (UNION ALL)
-- No tengo columna canal, la genero: las ventas de la primera quincena
-- las tomo como Online y las de la segunda como Presencial
SELECT
    canal,
    COUNT(*) AS cantidad_ventas,
    SUM(total) AS total_facturado
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Online' AS canal
    FROM ventas
    WHERE fecha_venta < '2024-03-11'
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Presencial' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-11'
) AS ventas_por_canal
GROUP BY canal
ORDER BY total_facturado DESC;
