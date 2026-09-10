/*
================================================================================
SWIGGY DATA WAREHOUSE - GOLD LAYER ANALYSIS
FILE: 01_revenue_pricing_analysis.sql
================================================================================

Purpose:
--------
Analyze pricing and price-value patterns across categories, locations,
restaurants, and dishes using the Gold layer star schema.

Business Questions:
-------------------
1. What is the total and average price value by category and location?
2. How are records distributed across different price ranges?
3. Which restaurant-dish combinations have the highest price value?

Source Tables:
--------------
- gold.fact_swiggy_data
- gold.dim_category
- gold.dim_location
- gold.dim_restaurant
- gold.dim_dish

Important Data Note:
--------------------
The source dataset does not contain a genuine Swiggy transaction amount or
unique order ID. Therefore, SUM(price_inr) is interpreted as total price value
unless the project explicitly defines each source record as an order.

================================================================================
*/


/*==============================================================================
1. TOTAL AND AVERAGE PRICE VALUE BY CATEGORY, STATE AND CITY
==============================================================================*/

SELECT 
    c.category,
    l.state,
    l.city,
    SUM(s.price_inr) AS total_price_value,
    AVG(s.price_inr) AS avg_price
FROM gold.fact_swiggy_data AS s
INNER JOIN gold.dim_category AS c
    ON s.category_id = c.category_id
INNER JOIN gold.dim_location AS l
    ON s.location_id = l.location_id
GROUP BY
    c.category,
    l.state,
    l.city
ORDER BY
    total_price_value DESC;


/*==============================================================================
2. PRICE DISTRIBUTION
==============================================================================*/

SELECT 
    CASE 
        WHEN s.price_inr < 100 THEN 'Under 100'
        WHEN s.price_inr < 300 THEN '100 - 299'
        WHEN s.price_inr < 500 THEN '300 - 499'
        WHEN s.price_inr >= 500 THEN '500+'
        ELSE 'Unknown'
    END AS price_bucket,
    COUNT(*) AS record_count
FROM gold.fact_swiggy_data AS s
GROUP BY
    CASE 
        WHEN s.price_inr < 100 THEN 'Under 100'
        WHEN s.price_inr < 300 THEN '100 - 299'
        WHEN s.price_inr < 500 THEN '300 - 499'
        WHEN s.price_inr >= 500 THEN '500+'
        ELSE 'Unknown'
    END
ORDER BY
    record_count DESC;


/*==============================================================================
3. TOP 10 RESTAURANT-DISH COMBINATIONS BY PRICE VALUE
==============================================================================*/

SELECT TOP 10
    r.restaurant_name,
    ds.dish_name,
    SUM(s.price_inr) AS total_price_value
FROM gold.fact_swiggy_data AS s
INNER JOIN gold.dim_restaurant AS r
    ON s.restaurant_id = r.restaurant_id
INNER JOIN gold.dim_dish AS ds
    ON s.dish_id = ds.dish_id
GROUP BY
    r.restaurant_name,
    ds.dish_name
ORDER BY
    total_price_value DESC;
