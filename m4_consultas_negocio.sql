-- Ventas_Tech_DB
-- Modulo 4 - Pre-entrega: Consultas SQL de negocio
-- Magali Gaiani


-- Consulta 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes
SELECT
    EXTRACT(MONTH FROM fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    ROUND(AVG(cantidad * precio_unitario), 2) AS ticket_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;


-- Consulta 2: Ranking de productos
-- Top 5 productos por total facturado
SELECT
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC
LIMIT 5;


-- Consulta 3: Clientes recurrentes
-- Clientes con mas de un pedido, con cantidad de pedidos y total gastado
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- Consulta 4: Meses por encima / por debajo del promedio
-- Comparo el total de cada mes contra el promedio mensual general
SELECT
    EXTRACT(MONTH FROM fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    CASE
        WHEN SUM(cantidad * precio_unitario) >= (
            SELECT AVG(total_mes)
            FROM (
                SELECT SUM(cantidad * precio_unitario) AS total_mes
                FROM ventas
                GROUP BY EXTRACT(MONTH FROM fecha_venta)
            ) AS totales_mensuales
        ) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;


-- Hallazgos
-- 1. El producto 1 (Laptop Pro 15) es el que mas factura: 3600 de un total de 6444,
--    o sea el 56% de la facturacion, con solo 3 unidades vendidas.
-- 2. Todos los clientes son recurrentes: los 5 hicieron 2 pedidos cada uno. El que mas
--    gasto es el cliente 1 con 2640 y el que menos el cliente 2 con 520.
-- 3. Como todas las ventas cargadas son de marzo 2024, la consulta mensual devuelve un
--    solo mes (10 pedidos, ticket promedio de 644,40). Para que la comparacion contra el
--    promedio tenga sentido hay que cargar ventas de mas meses.
