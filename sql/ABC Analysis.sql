USE BlueMart_Analytics;
GO

WITH ProductRevenue AS
(
    SELECT
        k.sku_id,
        k.sku_name,
        k.category,
        k.brand,
        SUM(s.total_value) AS revenue
    FROM Sales s
    INNER JOIN SKUs k
        ON s.sku_id = k.sku_id
    GROUP BY
        k.sku_id,
        k.sku_name,
        k.category,
        k.brand
),

RevenueWithPercentage AS
(
    SELECT
        *,
        SUM(revenue) OVER () AS total_revenue,

        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM ProductRevenue
)

SELECT
    sku_id,
    sku_name,
    category,
    brand,
    revenue,

    ROUND(
        revenue * 100.0 / total_revenue,
        2
    ) AS revenue_percentage,

    ROUND(
        cumulative_revenue * 100.0 / total_revenue,
        2
    ) AS cumulative_revenue_percentage,

    CASE
        WHEN cumulative_revenue * 100.0 / total_revenue <= 80
            THEN 'A'
        WHEN cumulative_revenue * 100.0 / total_revenue <= 95
            THEN 'B'
        ELSE 'C'
    END AS ABC_Category

FROM RevenueWithPercentage

ORDER BY revenue DESC;


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

RevenueWithPercentage AS
(
    SELECT
        *,
        SUM(revenue) OVER () AS total_revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM ProductRevenue
),

ABC AS
(
    SELECT
        *,
        CASE
            WHEN cumulative_revenue * 100.0 / total_revenue <= 80
                THEN 'A'
            WHEN cumulative_revenue * 100.0 / total_revenue <= 95
                THEN 'B'
            ELSE 'C'
        END AS ABC_Category
    FROM RevenueWithPercentage
)

SELECT
    ABC_Category,
    COUNT(*) AS Number_of_SKUs,
    SUM(revenue) AS Revenue,
    ROUND(
        SUM(revenue) * 100.0 /
        (SELECT SUM(revenue) FROM ProductRevenue),
        2
    ) AS Revenue_Share_Percentage
FROM ABC
GROUP BY ABC_Category
ORDER BY ABC_Category;

--