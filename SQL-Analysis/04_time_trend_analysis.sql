/*
================================================================================
SWIGGY DATA WAREHOUSE - GOLD LAYER ANALYSIS
FILE: 04_time_trend_analysis.sql
================================================================================

Purpose:
--------
Analyze time-based patterns and trends using the Gold date dimension.

Business Questions:
-------------------
1. How does record volume change month by month?
2. How does price value change quarter by quarter?
3. Are weekdays or weekends associated with higher record volume?
4. What is the month-over-month growth rate?
5. How does the previous month's performance compare with the current month?

SQL Concepts Demonstrated:
--------------------------
- Date dimension
- GROUP BY
- CASE expressions
- CTEs
- LAG() window function
- Percentage growth calculations

Important Data Note:
--------------------
Record counts represent fact-table records. Price value is based on price_inr
and should not automatically be described as actual Swiggy revenue.

================================================================================
*/


/*==============================================================================
1. MONTHLY RECORD AND PRICE-VALUE TREND
==============================================================================*/

SELECT 
    d.year_number,
    d.month_number,
    d.month_name,
    COUNT(*) AS record_count,
    SUM(s.price_inr) AS total_price_value
FROM gold.fact_swiggy_data AS s
INNER JOIN gold.dim_date AS d
    ON s.date_id = d.date_id
GROUP BY
    d.year_number,
    d.month_number,
    d.month_name
ORDER BY
    d.year_number,
    d.month_number;


/*==============================================================================
2. QUARTERLY RECORD AND PRICE-VALUE TREND
==============================================================================*/

SELECT 
    d.year_number,
    d.quarter_number,
    COUNT(*) AS record_count,
    SUM(s.price_inr) AS total_price_value
FROM gold.fact_swiggy_data AS s
INNER JOIN gold.dim_date AS d
    ON s.date_id = d.date_id
GROUP BY
    d.year_number,
    d.quarter_number
ORDER BY
    d.year_number,
    d.quarter_number;


/*==============================================================================
3. WEEKDAY VS WEEKEND COMPARISON
==============================================================================*/

SELECT 
    CASE 
        WHEN d.day_name IN ('Saturday', 'Sunday')
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS record_count,
    SUM(s.price_inr) AS total_price_value,
    AVG(s.price_inr) AS avg_price
FROM gold.fact_swiggy_data AS s
INNER JOIN gold.dim_date AS d
    ON s.date_id = d.date_id
GROUP BY
    CASE 
        WHEN d.day_name IN ('Saturday', 'Sunday')
            THEN 'Weekend'
        ELSE 'Weekday'
    END;


/*==============================================================================
4. MONTH-OVER-MONTH GROWTH USING LAG()
==============================================================================*/

WITH monthly_stats AS
(
    SELECT 
        d.year_number,
        d.month_number,
        d.month_name,
        COUNT(*) AS record_count,
        SUM(s.price_inr) AS total_price_value
    FROM gold.fact_swiggy_data AS s
    INNER JOIN gold.dim_date AS d
        ON s.date_id = d.date_id
    GROUP BY
        d.year_number,
        d.month_number,
        d.month_name
),
with_lag AS
(
    SELECT 
        *,
        LAG(record_count) OVER
        (
            ORDER BY year_number, month_number
        ) AS previous_month_records,

        LAG(total_price_value) OVER
        (
            ORDER BY year_number, month_number
        ) AS previous_month_price_value
    FROM monthly_stats
)
SELECT 
    year_number,
    month_number,
    month_name,
    record_count,
    total_price_value,
    previous_month_records,
    previous_month_price_value,

    ROUND
    (
        100.0 *
        (record_count - previous_month_records)
        / NULLIF(previous_month_records, 0),
        2
    ) AS record_growth_pct,

    ROUND
    (
        100.0 *
        (total_price_value - previous_month_price_value)
        / NULLIF(previous_month_price_value, 0),
        2
    ) AS price_value_growth_pct

FROM with_lag
ORDER BY
    year_number,
    month_number;
