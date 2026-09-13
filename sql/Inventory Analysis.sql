USE BlueMart_Analytics;
GO

--Overall Inventory Position
SELECT
    COUNT(*) AS Inventory_Records,
    SUM(stock_on_hand) AS Total_Stock,
    SUM(reorder_point) AS Total_Reorder_Point,
    SUM(safety_stock) AS Total_Safety_Stock,

    SUM(
        stock_on_hand * k.cost_price
    ) AS Total_Inventory_Value

FROM Inventory i
JOIN SKUs k
    ON i.sku_id = k.sku_id;

--Inventory Status
SELECT
    stock_status,
    COUNT(*) AS Inventory_Records,
    SUM(stock_on_hand) AS Total_Stock,

    SUM(
        stock_on_hand * k.cost_price
    ) AS Inventory_Value

FROM Inventory i
JOIN SKUs k
    ON i.sku_id = k.sku_id

GROUP BY stock_status

ORDER BY Inventory_Value DESC;

--Products Requiring Reorder

SELECT
    i.store_id,
    st.store_name,
    i.sku_id,
    k.sku_name,
    k.category,

    i.stock_on_hand,
    i.reorder_point,
    i.safety_stock,

    (i.reorder_point - i.stock_on_hand) AS Reorder_Quantity,

    k.cost_price,

    (i.reorder_point - i.stock_on_hand)
        * k.cost_price AS Estimated_Reorder_Cost

FROM Inventory i

JOIN SKUs k
    ON i.sku_id = k.sku_id

JOIN Stores st
    ON i.store_id = st.store_id

WHERE i.stock_on_hand <= i.reorder_point

ORDER BY Estimated_Reorder_Cost DESC;

--Out-of-Stock Inventory
SELECT
    i.store_id,
    st.store_name,
    i.sku_id,
    k.sku_name,
    k.category,
    k.brand,
    i.stock_on_hand,
    i.reorder_point

FROM Inventory i

JOIN SKUs k
    ON i.sku_id = k.sku_id

JOIN Stores st
    ON i.store_id = st.store_id

WHERE i.stock_on_hand = 0

ORDER BY k.category, k.sku_name;

--Overstocked Inventory
SELECT
    i.store_id,
    st.store_name,
    i.sku_id,
    k.sku_name,
    k.category,

    i.stock_on_hand,
    i.reorder_point,

    (i.stock_on_hand - i.reorder_point) AS Excess_Stock,

    (i.stock_on_hand - i.reorder_point)
        * k.cost_price AS Excess_Inventory_Value

FROM Inventory i

JOIN SKUs k
    ON i.sku_id = k.sku_id

JOIN Stores st
    ON i.store_id = st.store_id

WHERE i.stock_on_hand > (2 * i.reorder_point)

ORDER BY Excess_Inventory_Value DESC;

--Total Potential Overstock Value
SELECT
    COUNT(*) AS Overstock_Records,

    SUM(
        stock_on_hand - reorder_point
    ) AS Excess_Units,

    SUM(
        (stock_on_hand - reorder_point) * k.cost_price
    ) AS Excess_Inventory_Value

FROM Inventory i

JOIN SKUs k
    ON i.sku_id = k.sku_id

WHERE stock_on_hand > (2 * reorder_point);

--Store-Level Inventory Performance
SELECT
    st.store_id,
    st.store_name,
    st.city,
    st.store_type,

    COUNT(DISTINCT i.sku_id) AS Unique_SKUs,

    SUM(i.stock_on_hand) AS Total_Stock,

    SUM(
        i.stock_on_hand * k.cost_price
    ) AS Inventory_Value,

    SUM(
        CASE
            WHEN i.stock_on_hand <= i.reorder_point
            THEN 1
            ELSE 0
        END
    ) AS Reorder_Required_Count,

    SUM(
        CASE
            WHEN i.stock_on_hand = 0
            THEN 1
            ELSE 0
        END
    ) AS Out_of_Stock_Count

FROM Inventory i

JOIN SKUs k
    ON i.sku_id = k.sku_id

JOIN Stores st
    ON i.store_id = st.store_id

GROUP BY
    st.store_id,
    st.store_name,
    st.city,
    st.store_type

ORDER BY Inventory_Value DESC;