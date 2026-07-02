WITH sku_sales AS (
    SELECT
        sku,

        -- Monthly Sales
        SUM(CASE WHEN MONTH(order_date) = 1 THEN units_sold ELSE 0 END) AS jan_unit_sales,
        SUM(CASE WHEN MONTH(order_date) = 2 THEN units_sold ELSE 0 END) AS feb_unit_sales,
        SUM(CASE WHEN MONTH(order_date) = 3 THEN units_sold ELSE 0 END) AS mar_unit_sales,

        SUM(units_sold) AS q1_unit_sales
    FROM sales
    WHERE YEAR(order_date) = 2024
      AND MONTH(order_date) BETWEEN 1 AND 3
    GROUP BY sku
),

totals AS (
    SELECT
        SUM(jan_unit_sales) AS total_jan,
        SUM(feb_unit_sales) AS total_feb,
        SUM(mar_unit_sales) AS total_mar,
        SUM(q1_unit_sales) AS total_q1
    FROM sku_sales
)

SELECT
    s.sku,

    s.jan_unit_sales,
    s.feb_unit_sales,
    s.mar_unit_sales,
    s.q1_unit_sales,

    ROUND(100.0 * s.jan_unit_sales / t.total_jan,2) AS jan_unit_sales_share,
    ROUND(100.0 * s.feb_unit_sales / t.total_feb,2) AS feb_unit_sales_share,
    ROUND(100.0 * s.mar_unit_sales / t.total_mar,2) AS mar_unit_sales_share,
    ROUND(100.0 * s.q1_unit_sales / t.total_q1,2) AS q1_unit_sales_share,

    RANK() OVER (ORDER BY s.q1_unit_sales DESC) AS Rank

FROM sku_sales s
CROSS JOIN totals t
ORDER BY Rank;