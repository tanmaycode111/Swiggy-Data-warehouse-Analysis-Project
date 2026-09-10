/*
================================================================================
SWIGGY DATA WAREHOUSE - GOLD LAYER ANALYSIS
FILE: 02_ratings_quality_analysis.sql
================================================================================

Purpose:
--------
Analyze customer ratings and identify restaurants, categories, and locations
that require attention based on rating and record-volume patterns.

Business Questions:
-------------------
1. What is the average rating by category?
2. What is the average rating by location?
3. Which restaurants have high record volume but low average ratings?
4. Does price range appear to be associated with rating?
5. Which restaurants are highly popular according to rating_count but have
   relatively low average ratings?

Source Tables:
--------------
- gold.fact_swiggy_data
- gold.dim_category
- gold.dim_location
- gold.dim_restaurant

Important Data Note:
--------------------
COUNT(*) represents the number of records in the fact table, not necessarily
unique Swiggy customer orders because the source dataset has no genuine order ID.

rating_count should be interpreted carefully because repeated source-level
rating counts may not represent independent ratings.

================================================================================
*/


/*==============================================================================
1. AVERAGE RATING BY CATEGORY
==============================================================================*/

SELECT 
    c.category,
    AVG(s.rating) AS avg_rating,
    COUNT(*) AS record_count
FROM gold.fact_swiggy_data AS s
INNER JOIN gold.dim_category AS c
    ON s.category_id = c.category_id
GROUP BY
    c.category
ORDER BY
    avg_rating DESC;


/*==============================================================================
2. AVERAGE RATING BY LOCATION
==============================================================================*/

SELECT 
    l.state,
    l.city,
    l.location,
    AVG(s.rating) AS avg_rating,
    COUNT(*) AS record_count
FROM gold.fact_swiggy_data AS s
INNER JOIN gold.dim_location AS l
    ON s.location_id = l.location_id
GROUP BY
    l.state,
    l.city,
    l.location
ORDER BY
    avg_rating DESC;


/*==============================================================================
3. RISK LIST
   Restaurants with high record volume but low average rating
==============================================================================*/

SELECT 
    r.restaurant_name,
    AVG(s.rating) AS avg_rating,
    COUNT(*) AS record_count
FROM gold.fact_swiggy_data AS s
INNER JOIN gold.dim_restaurant AS r
    ON s.restaurant_id = r.restaurant_id
GROUP BY
    r.restaurant_name
HAVING
    AVG(s.rating) < 3.5
    AND COUNT(*) > 50
ORDER BY
    record_count DESC,
    avg_rating ASC;


/*==============================================================================
4. PRICE VS RATING ANALYSIS
   Compare average rating across price buckets
==============================================================================*/

SELECT 
    CASE 
        WHEN s.price_inr < 100 THEN 'Under 100'
        WHEN s.price_inr < 300 THEN '100 - 299'
        WHEN s.price_inr < 500 THEN '300 - 499'
        WHEN s.price_inr >= 500 THEN '500+'
        ELSE 'Unknown'
    END AS price_bucket,
    AVG(s.rating) AS avg_rating,
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
    avg_rating DESC;


/*==============================================================================
5. POPULAR BUT DISAPPOINTING RESTAURANTS
   Top quartile by rating_count + bottom quartile by average rating
==============================================================================*/

WITH restaurant_stats AS
(
    SELECT 
        r.restaurant_name,
        AVG(s.rating) AS avg_rating,
        SUM(s.rating_count) AS total_rating_count
    FROM gold.fact_swiggy_data AS s
    INNER JOIN gold.dim_restaurant AS r
        ON s.restaurant_id = r.restaurant_id
    GROUP BY
        r.restaurant_name
),
thresholds AS
(
    SELECT 
        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY total_rating_count)
            OVER () AS popularity_cutoff,

        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY avg_rating)
            OVER () AS rating_cutoff
    FROM restaurant_stats
)
SELECT DISTINCT
    rs.restaurant_name,
    rs.avg_rating,
    rs.total_rating_count
FROM restaurant_stats AS rs
CROSS JOIN thresholds AS t
WHERE
    rs.total_rating_count >= t.popularity_cutoff
    AND rs.avg_rating <= t.rating_cutoff
ORDER BY
    rs.total_rating_count DESC;
