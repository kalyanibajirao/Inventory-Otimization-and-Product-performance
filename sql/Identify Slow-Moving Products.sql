--Identify Slow-Moving Products
USE BlueMart_Analytics;
GO

WITH ProductSales AS
(
    SELECT
        sku_id,
        SUM(quantity) AS total_units_sold,
        SUM(total_value) AS total_revenue
    FROM Sales
    GROUP BY sku_id
),

ProductInventory AS
(
    SELECT
        sku_id,
        SUM(stock_on_hand) AS total_stock
    FROM Inventory
    GROUP BY sku_id
)

SELECT
    k.sku_id,
    k.sku_name,
    k.category,
    k.subcategory,
    k.brand,

    ISNULL(ps.total_units_sold, 0) AS total_units_sold,
    ISNULL(ps.total_revenue, 0) AS total_revenue,

    ISNULL(pi.total_stock, 0) AS total_stock,

    k.cost_price,

    ISNULL(pi.total_stock, 0) * k.cost_price
        AS inventory_value

FROM SKUs k

LEFT JOIN ProductSales ps
    ON k.sku_id = ps.sku_id

LEFT JOIN ProductInventory pi
    ON k.sku_id = pi.sku_id

ORDER BY inventory_value DESC;

--Calculate Inventory Turnover
WITH ProductSales AS
(
    SELECT
        sku_id,
        SUM(quantity) AS total_units_sold
    FROM Sales
    GROUP BY sku_id
),

ProductInventory AS
(
    SELECT
        sku_id,
        SUM(stock_on_hand) AS total_stock
    FROM Inventory
    GROUP BY sku_id
)

SELECT
    k.sku_id,
    k.sku_name,
    k.category,

    ISNULL(ps.total_units_sold, 0) AS units_sold,
    ISNULL(pi.total_stock, 0) AS inventory_units,

    ROUND(
        CAST(ISNULL(ps.total_units_sold, 0) AS DECIMAL(18,2))
        / NULLIF(pi.total_stock, 0),
        2
    ) AS inventory_turnover

FROM SKUs k

LEFT JOIN ProductSales ps
    ON k.sku_id = ps.sku_id

LEFT JOIN ProductInventory pi
    ON k.sku_id = pi.sku_id

ORDER BY inventory_turnover ASC;

--Identify Potential Slow-Moving Inventory

WITH ProductSales AS
(
    SELECT
        sku_id,
        SUM(quantity) AS total_units_sold
    FROM Sales
    GROUP BY sku_id
),

ProductInventory AS
(
    SELECT
        sku_id,
        SUM(stock_on_hand) AS total_stock
    FROM Inventory
    GROUP BY sku_id
),

ProductAnalysis AS
(
    SELECT
        k.sku_id,
        k.sku_name,
        k.category,
        k.brand,

        ISNULL(ps.total_units_sold, 0) AS units_sold,
        ISNULL(pi.total_stock, 0) AS inventory_units,

        k.cost_price,

        ISNULL(pi.total_stock, 0) * k.cost_price
            AS inventory_value,

        CAST(ISNULL(ps.total_units_sold, 0) AS DECIMAL(18,2))
        / NULLIF(pi.total_stock, 0)
            AS inventory_turnover

    FROM SKUs k

    LEFT JOIN ProductSales ps
        ON k.sku_id = ps.sku_id

    LEFT JOIN ProductInventory pi
        ON k.sku_id = pi.sku_id
)

SELECT
    *,
    CASE
        WHEN units_sold = 0 AND inventory_units > 0
            THEN 'No Sales'
        WHEN inventory_turnover < 1
            THEN 'Slow Moving'
        ELSE 'Normal'
    END AS Inventory_Movement_Status

FROM ProductAnalysis

WHERE inventory_units > 0

ORDER BY inventory_value DESC;

--Quantify Slow-Moving Inventory

WITH ProductSales AS
(
    SELECT
        sku_id,
        SUM(quantity) AS units_sold
    FROM Sales
    GROUP BY sku_id
),

ProductInventory AS
(
    SELECT
        sku_id,
        SUM(stock_on_hand) AS inventory_units
    FROM Inventory
    GROUP BY sku_id
),

ProductAnalysis AS
(
    SELECT
        k.sku_id,
        k.sku_name,

        ISNULL(ps.units_sold, 0) AS units_sold,

        ISNULL(pi.inventory_units, 0) AS inventory_units,

        k.cost_price,

        ISNULL(pi.inventory_units, 0) * k.cost_price
            AS inventory_value,

        CAST(ISNULL(ps.units_sold, 0) AS DECIMAL(18,2))
        / NULLIF(pi.inventory_units, 0)
            AS turnover

    FROM SKUs k

    LEFT JOIN ProductSales ps
        ON k.sku_id = ps.sku_id

    LEFT JOIN ProductInventory pi
        ON k.sku_id = pi.sku_id
)

SELECT

    COUNT(*) AS Slow_Moving_SKUs,

    SUM(inventory_units) AS Slow_Moving_Units,

    SUM(inventory_value) AS Slow_Moving_Inventory_Value,

    (
        SUM(inventory_value) /
        NULLIF(
            (SELECT SUM(inventory_value)
             FROM ProductAnalysis
             WHERE inventory_units > 0),
            0
        )
    ) * 100 AS Slow_Moving_Inventory_Value_Percentage

FROM ProductAnalysis

WHERE inventory_units > 0
AND (
        turnover < 1
        OR units_sold = 0
    );

--Top Slow-Moving Products
WITH ProductSales AS
(
    SELECT
        sku_id,
        SUM(quantity) AS units_sold
    FROM Sales
    GROUP BY sku_id
),

ProductInventory AS
(
    SELECT
        sku_id,
        SUM(stock_on_hand) AS inventory_units
    FROM Inventory
    GROUP BY sku_id
)

SELECT TOP 20

    k.sku_id,
    k.sku_name,
    k.category,
    k.brand,

    ISNULL(ps.units_sold, 0) AS units_sold,

    pi.inventory_units,

    k.cost_price,

    pi.inventory_units * k.cost_price
        AS inventory_value,

    ROUND(
        CAST(ISNULL(ps.units_sold, 0) AS DECIMAL(18,2))
        / NULLIF(pi.inventory_units, 0),
        2
    ) AS inventory_turnover

FROM SKUs k

LEFT JOIN ProductSales ps
    ON k.sku_id = ps.sku_id

JOIN ProductInventory pi
    ON k.sku_id = pi.sku_id

WHERE pi.inventory_units > 0

AND (
    ISNULL(ps.units_sold, 0) = 0
    OR
    CAST(ISNULL(ps.units_sold, 0) AS DECIMAL(18,2))
        / NULLIF(pi.inventory_units, 0) < 1
)

ORDER BY inventory_value DESC;

