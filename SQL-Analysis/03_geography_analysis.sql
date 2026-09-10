/*
================================================================================
SWIGGY DATA WAREHOUSE - GOLD LAYER ANALYSIS
FILE: 03_geography_analysis.sql
================================================================================

Purpose:
--------
Analyze geographic performance across states, cities, and localities.

Business Questions:
-------------------
1. Which cities generate the highest total price value?
2. How does each city rank within its state?
3. Which localities have high demand relative to restaurant coverage?
4. Which localities may be oversupplied with restaurants relative to demand?

Source Tables:
--------------
- gold.fact_swiggy_data
- gold.dim_location

Important Data Note:
--------------------
COUNT(*) represents fact-table record volume. It should not be described as
unique customer orders unless a true transaction/order identifier is available.

================================================================================
*/


/*==============================================================================
1. CITY PERFORMANCE AND RANKING WITHIN EACH STATE
==============================================================================*/

WITH city_stats AS
(
    SELECT 
        l.state,
        l.city,
        SUM(s.price_inr) AS total_price_value,
        COUNT(*) AS record_count
    FROM gold.fact_swiggy_data AS s
    INNER JOIN gold.dim_location AS l
        ON s.location_id = l.location_id
    GROUP BY
        l.state,
        l.city
)
SELECT 
    state,
    city,
    total_price_value,
    record_count,
    RANK() OVER
    (
        PARTITION BY state
        ORDER BY total_price_value DESC
    ) AS price_value_rank_in_state
FROM city_stats
ORDER BY
    state,
    price_value_rank_in_state;


/*==============================================================================
2. UNDER-SERVED LOCALITIES
   High demand with relatively few restaurants
==============================================================================*/

SELECT TOP 10
    l.state,
    l.city,
    l.location,
    COUNT(DISTINCT s.restaurant_id) AS restaurant_count,
    COUNT(*) AS record_count,
    CAST(COUNT(*) AS FLOAT)
        / NULLIF(COUNT(DISTINCT s.restaurant_id), 0)
        AS records_per_restaurant
FROM gold.fact_swiggy_data AS s
INNER JOIN gold.dim_location AS l
    ON s.location_id = l.location_id
GROUP BY
    l.state,
    l.city,
    l.location
HAVING
    COUNT(*) > 50
ORDER BY
    records_per_restaurant DESC;


/*==============================================================================
3. POTENTIALLY OVERSUPPLIED LOCALITIES
   Many restaurants with relatively low demand per restaurant
==============================================================================*/

SELECT TOP 10
    l.state,
    l.city,
    l.location,
    COUNT(DISTINCT s.restaurant_id) AS restaurant_count,
    COUNT(*) AS record_count,
    CAST(COUNT(*) AS FLOAT)
        / NULLIF(COUNT(DISTINCT s.restaurant_id), 0)
        AS records_per_restaurant
FROM gold.fact_swiggy_data AS s
INNER JOIN gold.dim_location AS l
    ON s.location_id = l.location_id
GROUP BY
    l.state,
    l.city,
    l.location
HAVING
    COUNT(DISTINCT s.restaurant_id) > 5
ORDER BY
    records_per_restaurant ASC;
