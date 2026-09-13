USE BlueMart_Analytics;
GO

SELECT 'Customers' AS Table_Name, COUNT(*) AS Row_Count
FROM Customers

UNION ALL

SELECT 'Stores', COUNT(*)
FROM Stores

UNION ALL

SELECT 'SKUs', COUNT(*)
FROM SKUs

UNION ALL

SELECT 'Promotions', COUNT(*)
FROM Promotions

UNION ALL

SELECT 'Inventory', COUNT(*)
FROM Inventory

UNION ALL

SELECT 'Sales', COUNT(*)
FROM Sales;


SELECT
    COUNT(*) AS Total_Sales,

    COUNT(DISTINCT sku_id) AS Unique_SKUs,

    COUNT(DISTINCT store_id) AS Unique_Stores,

    COUNT(DISTINCT customer_id) AS Unique_Customers,

    SUM(quantity) AS Total_Units_Sold,

    SUM(total_value) AS Total_Revenue
FROM Sales;

SELECT COUNT(*) AS Invalid_SKU_Records
FROM Sales s
LEFT JOIN SKUs k
    ON s.sku_id = k.sku_id
WHERE k.sku_id IS NULL;

SELECT COUNT(*) AS Invalid_Store_Records
FROM Sales s
LEFT JOIN Stores st
    ON s.store_id = st.store_id
WHERE st.store_id IS NULL;

SELECT COUNT(*) AS Invalid_Customer_Records
FROM Sales s
LEFT JOIN Customers c
    ON s.customer_id = c.cust_id
WHERE s.customer_id IS NOT NULL
AND c.cust_id IS NULL;

SELECT COUNT(*) AS Invalid_Inventory_SKUs
FROM Inventory i
LEFT JOIN SKUs s
    ON i.sku_id = s.sku_id
WHERE s.sku_id IS NULL;

SELECT COUNT(*) AS Invalid_Inventory_Stores
FROM Inventory i
LEFT JOIN Stores st
    ON i.store_id = st.store_id
WHERE st.store_id IS NULL;

SELECT 'Customers' AS Table_Name, COUNT(*) AS Row_Count
FROM Customers
UNION ALL
SELECT 'Stores', COUNT(*) FROM Stores
UNION ALL
SELECT 'SKUs', COUNT(*) FROM SKUs
UNION ALL
SELECT 'Promotions', COUNT(*) FROM Promotions
UNION ALL
SELECT 'Inventory', COUNT(*) FROM Inventory
UNION ALL
SELECT 'Sales', COUNT(*) FROM Sales;

SELECT
    COUNT(*) AS Total_Sales,
    COUNT(DISTINCT sku_id) AS Unique_SKUs,
    COUNT(DISTINCT store_id) AS Unique_Stores,
    COUNT(DISTINCT customer_id) AS Unique_Customers,
    SUM(quantity) AS Total_Units_Sold,
    SUM(total_value) AS Total_Revenue
FROM Sales;

--Overall Sales performance

SELECT
    SUM(total_value) AS Total_Revenue
FROM Sales;

SELECT
    SUM(quantity) AS Total_Units_Sold
FROM Sales;

SELECT
    COUNT(*) AS Total_Transactions
FROM Sales;

SELECT
    AVG(total_value) AS Average_Order_Value
FROM Sales;

SELECT
    SUM(total_value * discount_pct / 100) AS Total_Discount
FROM Sales;

SELECT
    SUM(
        s.total_value -
        (s.quantity * k.cost_price)
    ) AS Total_Profit
FROM Sales s
JOIN SKUs k
    ON s.sku_id = k.sku_id;

SELECT
    SUM(
        s.total_value -
        (s.quantity * k.cost_price)
    ) / NULLIF(SUM(s.total_value), 0) * 100
        AS Profit_Margin_Percentage
FROM Sales s
JOIN SKUs k
    ON s.sku_id = k.sku_id;

SELECT
    COUNT(*) AS Total_Transactions,
    SUM(quantity) AS Total_Units_Sold,
    SUM(total_value) AS Total_Revenue,
    AVG(total_value) AS Average_Order_Value,

    SUM(total_value * discount_pct / 100)
        AS Total_Discount,

    SUM(
        total_value -
        (quantity * k.cost_price)
    ) AS Total_Profit,

    (
        SUM(
            total_value -
            (quantity * k.cost_price)
        )
        / NULLIF(SUM(total_value), 0)
    ) * 100 AS Profit_Margin_Percentage

FROM Sales s
JOIN SKUs k
    ON s.sku_id = k.sku_id;

--Product Performance Analysis

SELECT
    k.sku_id,
    k.sku_name,
    k.category,
    k.subcategory,
    k.brand,

    SUM(s.quantity) AS total_units_sold,
    SUM(s.total_value) AS total_revenue

FROM Sales s
JOIN SKUs k
    ON s.sku_id = k.sku_id

GROUP BY
    k.sku_id,
    k.sku_name,
    k.category,
    k.subcategory,
    k.brand

ORDER BY total_revenue DESC;

SELECT TOP 10
    k.sku_id,
    k.sku_name,
    k.category,
    k.brand,

    SUM(s.quantity) AS total_units_sold,
    SUM(s.total_value) AS total_revenue

FROM Sales s
JOIN SKUs k
    ON s.sku_id = k.sku_id

GROUP BY
    k.sku_id,
    k.sku_name,
    k.category,
    k.brand

ORDER BY total_revenue DESC;

SELECT
    k.sku_id,
    k.sku_name,
    k.category,
    k.brand,

    SUM(s.quantity) AS total_units_sold,

    SUM(s.total_value) AS revenue,

    SUM(s.quantity * k.cost_price) AS total_cost,

    SUM(
        s.total_value -
        (s.quantity * k.cost_price)
    ) AS profit,

    (
        SUM(
            s.total_value -
            (s.quantity * k.cost_price)
        )
        / NULLIF(SUM(s.total_value), 0)
    ) * 100 AS profit_margin_pct

FROM Sales s
JOIN SKUs k
    ON s.sku_id = k.sku_id

GROUP BY
    k.sku_id,
    k.sku_name,
    k.category,
    k.brand

ORDER BY profit DESC;


SELECT
    k.category,

    SUM(s.quantity) AS total_units_sold,

    SUM(s.total_value) AS total_revenue,

    SUM(
        s.total_value -
        (s.quantity * k.cost_price)
    ) AS total_profit,

    (
        SUM(
            s.total_value -
            (s.quantity * k.cost_price)
        )
        / NULLIF(SUM(s.total_value), 0)
    ) * 100 AS profit_margin_pct

FROM Sales s
JOIN SKUs k
    ON s.sku_id = k.sku_id

GROUP BY k.category

ORDER BY total_revenue DESC;


WITH ProductRevenue AS
(
    SELECT
        k.sku_id,
        k.sku_name,
        SUM(s.total_value) AS revenue
    FROM Sales s
    JOIN SKUs k
        ON s.sku_id = k.sku_id
    GROUP BY
        k.sku_id,
        k.sku_name
),

RankedProducts AS
(
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM ProductRevenue
),

Top15 AS
(
    SELECT *
    FROM RankedProducts
    WHERE revenue_rank <= 30
)

SELECT
    SUM(revenue) AS Top_30_Product_Revenue,

    (SELECT SUM(revenue)
     FROM ProductRevenue) AS Total_Revenue,

    (
        SUM(revenue)
        /
        NULLIF(
            (SELECT SUM(revenue)
             FROM ProductRevenue), 0
        )
    ) * 100 AS Top_15_Percent_Revenue_Share

FROM Top15;



SELECT TOP 10
    k.sku_id,
    k.sku_name,
    k.category,
    k.subcategory,
    k.brand,
    SUM(s.quantity) AS total_units_sold,
    SUM(s.total_value) AS total_revenue
FROM Sales s
JOIN SKUs k
    ON s.sku_id = k.sku_id
GROUP BY
    k.sku_id,
    k.sku_name,
    k.category,
    k.subcategory,
    k.brand
ORDER BY total_revenue DESC;