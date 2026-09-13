USE BlueMart_Analytics;
GO

SELECT
    COUNT(*) AS Total_Transactions,
    SUM(quantity) AS Total_Units_Sold,
    SUM(total_value) AS Total_Revenue,
    AVG(total_value) AS Average_Order_Value,

    COUNT(DISTINCT s.sku_id) AS Active_SKUs,
    COUNT(DISTINCT store_id) AS Active_Stores,

    SUM(
        total_value - (quantity * k.cost_price)
    ) AS Total_Profit,

    ROUND(
        SUM(
            total_value - (quantity * k.cost_price)
        ) * 100.0 /
        NULLIF(SUM(total_value), 0),
        2
    ) AS Profit_Margin_Percentage

FROM Sales s
JOIN SKUs k
    ON s.sku_id = k.sku_id;

--Category-Level Business Performance
SELECT
    k.category,

    SUM(s.quantity) AS Units_Sold,

    SUM(s.total_value) AS Revenue,

    SUM(
        s.total_value -
        (s.quantity * k.cost_price)
    ) AS Profit,

    ROUND(
        SUM(
            s.total_value -
            (s.quantity * k.cost_price)
        ) * 100.0 /
        NULLIF(SUM(s.total_value), 0),
        2
    ) AS Profit_Margin

FROM Sales s
JOIN SKUs k
    ON s.sku_id = k.sku_id

GROUP BY k.category

ORDER BY Revenue DESC;

--Inventory Risk Summary

SELECT
    COUNT(*) AS Total_Inventory_Records,

    SUM(stock_on_hand) AS Total_Stock,

    SUM(
        stock_on_hand * k.cost_price
    ) AS Total_Inventory_Value,

    SUM(
        CASE
            WHEN stock_on_hand = 0 THEN 1
            ELSE 0
        END
    ) AS Out_of_Stock_Records,

    SUM(
        CASE
            WHEN stock_on_hand <= reorder_point
            THEN 1
            ELSE 0
        END
    ) AS Reorder_Required_Records,

    SUM(
        CASE
            WHEN stock_on_hand > (2 * reorder_point)
            THEN 1
            ELSE 0
        END
    ) AS Potential_Overstock_Records

FROM Inventory i
JOIN SKUs k
    ON i.sku_id = k.sku_id;

--Top 10 Revenue Products
SELECT TOP 10
    k.sku_id,
    k.sku_name,
    k.category,
    SUM(s.quantity) AS Units_Sold,
    SUM(s.total_value) AS Revenue

FROM Sales s
JOIN SKUs k
    ON s.sku_id = k.sku_id

GROUP BY
    k.sku_id,
    k.sku_name,
    k.category

ORDER BY Revenue DESC;

