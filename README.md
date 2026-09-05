# RetailPro - Proyecto Final Data Analyst (Coderhouse)

Autora: Magali Gaiani

## Descripción

RetailPro es una empresa ficticia que vende productos de tecnología. Este proyecto es el
trabajo final del curso Data Analyst de Coderhouse y va desde el brief de negocio hasta el
modelo en Power BI, pasando por SQL, ETL y validación estadística.

La pregunta que guía todo el proyecto es: **¿por qué dos regiones con una cantidad similar
de clientes presentan una diferencia del 40 % en facturación en el último año, y qué
categorías de producto y tipos de cliente explican esa brecha?** (el 40 % es la hipótesis
del brief, que se valida con los datos).

## Herramientas utilizadas

- PostgreSQL 16 (pgAdmin)
- Power BI Desktop
- Power Query (lenguaje M)
- DAX
- GitHub
- ChatGPT (versión gratuita) como apoyo para revisar SQL y documentar, ver módulo 9

## Estructura del repositorio

```
modulo-1-brief/       Brief analítico del proyecto (DOCX) y primer boceto
modulo-2-modelo/      Modelo relacional y diagrama entidad-relación
sql/
  ventas_tech_db.sql              M3: crea la base Ventas_Tech_DB y carga datos de ejemplo
  m4_consultas_negocio.sql        M4: consultas de agregación
  m5_consultas_joins.sql          M5: consultas con JOINs
  m10_validacion_estadistica.sql  M10: media, mediana, desvío y outliers (IQR)
modulo-6-etl/         Pipeline ETL en Power BI (Power Query) + guía
modulo-7-dashboard/   Boceto del dashboard (patrón Z)
modulo-8-modelo/      Modelo de datos en Power BI, tabla calendario y medidas DAX
modulo-9-ia/          Prompts usados con IA y documentación del módulo 9
```

## Base de datos

La base `Ventas_Tech_DB` tiene 5 tablas: `territorios`, `categorias`, `clientes`,
`productos` y `ventas`. El script de M3 crea las tablas y carga datos de ejemplo.

Aclaración: los scripts de M3, M4 y M5 trabajan sobre esa base chica (10 ventas). El script
de M10 usa un dataset distinto, las 50 ventas del Excel `Pipeline_ETL_Dataset.xlsx` que se
cargaron en Power BI en M6, porque el objetivo era validar los KPIs del dashboard. Por eso
el M10 crea su propia tabla `ventas_retailpro` y no depende de los scripts anteriores.

## Contenido analítico

- **M4 - Consultas de negocio:** `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING`, `CASE WHEN`.
- **M5 - JOINs:** `INNER JOIN` (vista base con 5 tablas), `LEFT JOIN` (clientes y productos
  sin ventas) y `UNION ALL`.
- **M10 - Validación estadística:** media vs. mediana, desvío estándar muestral y detección
  de outliers con el método IQR.

## ETL y modelado en Power BI

- **M6:** limpieza en Power Query (duplicados, nulos, tipos) y tablas `Dim_Clientes`,
  `Dim_Productos`, `Dim_Categorias` y `Fact_Ventas`.
- **M8:** relaciones 1:N, tabla `Dim_Fechas` con `CALENDAR`, tabla `_Medidas` con
  `Total Ventas`, `Ventas Online`, `Ventas YTD`, `Ventas LY` y `% Crecimiento Anual`.

## Cómo ejecutar los scripts SQL

Primero hay que crear la base, porque el script de M3 no la crea:

```sql
CREATE DATABASE ventas_tech_db;
```

**Opción 1: pgAdmin**

1. Conectarse al servidor y abrir la base `ventas_tech_db`.
2. Abrir Query Tool y ejecutar los archivos en este orden:
   `sql/ventas_tech_db.sql` → `sql/m4_consultas_negocio.sql` → `sql/m5_consultas_joins.sql`.
3. `sql/m10_validacion_estadistica.sql` se puede correr en cualquier momento (es independiente).

**Opción 2: psql**

```
psql -U postgres -d ventas_tech_db
\i sql/ventas_tech_db.sql
\i sql/m4_consultas_negocio.sql
\i sql/m5_consultas_joins.sql
\i sql/m10_validacion_estadistica.sql
```

Los scripts usan `PERCENTILE_CONT` y `STDDEV_SAMP`, que son de PostgreSQL. En SQL Server
habría que cambiar `STDDEV_SAMP` por `STDEV`.
