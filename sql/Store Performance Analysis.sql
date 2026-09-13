USE BlueMart_Analytics;
GO

SELECT
    st.store_id,
    st.store_name,
    st.city,
    st.store_type,

    COUNT(*) AS total_transactions,
    SUM(s.quantity) AS total_units_sold,
    SUM(s.total_value) AS total_revenue

FROM Sales s

JOIN Stores st
    ON s.store_id = st.store_id

GROUP BY
    st.store_id,
    st.store_name,
    st.city,
    st.store_type

ORDER BY total_revenue DESC;

--Store Profitability
SELECT
    st.store_id,
    st.store_name,
    st.city,
    st.store_type,

    SUM(s.total_value) AS total_revenue,

    SUM(
        s.quantity * k.cost_price
    ) AS total_cost,

    SUM(
        s.total_value -
        (s.quantity * k.cost_price)
    ) AS total_profit,

    ROUND(
        SUM(
            s.total_value -
            (s.quantity * k.cost_price)
        ) * 100.0 /
        NULLIF(SUM(s.total_value), 0),
        2
    ) AS profit_margin_pct

FROM Sales s

JOIN Stores st
    ON s.store_id = st.store_id

JOIN SKUs k
    ON s.sku_id = k.sku_id

GROUP BY
    st.store_id,
    st.store_name,
    st.city,
    st.store_type

ORDER BY total_profit DESC;

--Store Inventory vs Sales

WITH StoreSales AS
(
    SELECT
        store_id,
        SUM(quantity) AS units_sold,
        SUM(total_value) AS revenue
    FROM Sales
    GROUP BY store_id
),

StoreInventory AS
(
    SELECT
        store_id,
        SUM(stock_on_hand) AS stock_units,
        SUM(
            stock_on_hand * k.cost_price
        ) AS inventory_value
    FROM Inventory i
    JOIN SKUs k
        ON i.sku_id = k.sku_id
    GROUP BY store_id
)

SELECT
    st.store_id,
    st.store_name,
    st.city,
    st.store_type,

    ISNULL(ss.units_sold, 0) AS units_sold,
    ISNULL(ss.revenue, 0) AS revenue,

    ISNULL(si.stock_units, 0) AS inventory_units,
    ISNULL(si.inventory_value, 0) AS inventory_value,

    ROUND(
        CAST(ISNULL(ss.units_sold, 0) AS DECIMAL(18,2))
        / NULLIF(si.stock_units, 0),
        2
    ) AS inventory_turnover

FROM Stores st

LEFT JOIN StoreSales ss
    ON st.store_id = ss.store_id

LEFT JOIN StoreInventory si
    ON st.store_id = si.store_id

ORDER BY inventory_turnover ASC;

--Store Ranking

WITH StoreRevenue AS
(
    SELECT
        st.store_id,
        st.store_name,
        st.city,
        st.store_type,
        SUM(s.total_value) AS revenue
    FROM Sales s
    JOIN Stores st
        ON s.store_id = st.store_id
    GROUP BY
        st.store_id,
        st.store_name,
        st.city,
        st.store_type
)

SELECT
    *,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM StoreRevenue
ORDER BY revenue_rank;

--Store Type Performance

SELECT
    st.store_type,

    COUNT(DISTINCT st.store_id) AS number_of_stores,

    COUNT(s.sale_id) AS transactions,

    SUM(s.quantity) AS units_sold,

    SUM(s.total_value) AS revenue,

    SUM(
        s.total_value -
        (s.quantity * k.cost_price)
    ) AS profit

FROM Stores st

JOIN Sales s
    ON st.store_id = s.store_id

JOIN SKUs k
    ON s.sku_id = k.sku_id

GROUP BY
    st.store_type

ORDER BY revenue DESC;

