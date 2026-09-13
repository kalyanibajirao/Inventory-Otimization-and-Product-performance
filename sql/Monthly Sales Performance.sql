USE BlueMart_Analytics;
GO

SELECT
    year,
    month,
    month_name,

    COUNT(*) AS total_transactions,

    SUM(quantity) AS total_units_sold,

    SUM(total_value) AS total_revenue,

    AVG(total_value) AS average_order_value

FROM Sales

GROUP BY
    year,
    month,
    month_name

ORDER BY
    year,
    month;

--Monthly Profit

SELECT
    s.year,
    s.month,
    s.month_name,

    SUM(s.total_value) AS revenue,

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

JOIN SKUs k
    ON s.sku_id = k.sku_id

GROUP BY
    s.year,
    s.month,
    s.month_name

ORDER BY
    s.year,
    s.month;

--Best and Worst Sales Months
SELECT TOP 3
    year,
    month,
    month_name,
    SUM(total_value) AS total_revenue
FROM Sales
GROUP BY
    year,
    month,
    month_name
ORDER BY total_revenue DESC;

SELECT TOP 3
    year,
    month,
    month_name,
    SUM(total_value) AS total_revenue
FROM Sales
GROUP BY
    year,
    month,
    month_name
ORDER BY total_revenue ASC;



--Monthly Growth %

WITH MonthlySales AS
(
    SELECT
        year,
        month,
        month_name,
        SUM(total_value) AS revenue
    FROM Sales
    GROUP BY
        year,
        month,
        month_name
),

PreviousMonth AS
(
    SELECT
        *,
        LAG(revenue) OVER (
            ORDER BY year, month
        ) AS previous_month_revenue
    FROM MonthlySales
)

SELECT
    year,
    month,
    month_name,
    revenue,
    previous_month_revenue,

    ROUND(
        (revenue - previous_month_revenue)
        * 100.0
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS revenue_growth_pct

FROM PreviousMonth

ORDER BY
    year,
    month;

--Monthly Revenue Share

WITH MonthlySales AS
(
    SELECT
        year,
        month,
        month_name,
        SUM(total_value) AS revenue
    FROM Sales
    GROUP BY
        year,
        month,
        month_name
)

SELECT
    year,
    month,
    month_name,
    revenue,

    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct

FROM MonthlySales

ORDER BY
    year,
    month;