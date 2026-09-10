```sql
USE SwiggyDataWarehouse;
GO

/*
=============================================================
SILVER LAYER – DATA QUALITY CHECKS & PREPROCESSING
=============================================================

Script Purpose:
    This script performs data-quality checks on the Bronze layer
    before loading the data into the Silver layer.

Checks Performed:
    1. Duplicate records
    2. NULL values
    3. Unwanted leading/trailing spaces
    4. Price validation
    5. Rating validation
    6. Rating count validation

IMPORTANT:
    The Bronze layer is treated as the raw source and is not
    modified. Identified data-quality issues are handled during
    the Bronze-to-Silver transformation.

=============================================================
*/


/*=============================================================
  1. DUPLICATE ROWS
=============================================================*/

SELECT *
FROM
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                state,
                city,
                order_date,
                restaurant_name,
                location,
                category,
                dish_name,
                price,
                rating,
                rating_count
            ORDER BY dwh_create_date
        ) AS rn
    FROM bronze.swiggy_data
) AS t
WHERE rn > 1;


/*=============================================================
  2. NULL VALUES
=============================================================*/

-- Check NULL rating_count values

SELECT
    rating_count
FROM bronze.swiggy_data
WHERE rating_count IS NULL;

-- Check NULL values across important columns

SELECT
    COUNT(*) AS null_rating_count
FROM bronze.swiggy_data
WHERE rating_count IS NULL;


/*=============================================================
  3. UNWANTED LEADING / TRAILING SPACES
=============================================================*/

SELECT state
FROM bronze.swiggy_data
WHERE state <> TRIM(state);


SELECT city
FROM bronze.swiggy_data
WHERE city <> TRIM(city);


SELECT restaurant_name
FROM bronze.swiggy_data
WHERE restaurant_name <> TRIM(restaurant_name);


SELECT location
FROM bronze.swiggy_data
WHERE location <> TRIM(location);


SELECT category
FROM bronze.swiggy_data
WHERE category <> TRIM(category);


SELECT dish_name
FROM bronze.swiggy_data
WHERE dish_name <> TRIM(dish_name);


/*=============================================================
  4. PRICE VALIDATION
=============================================================*/

-- Check negative prices

SELECT price
FROM bronze.swiggy_data
WHERE price < 0;


-- Check zero prices

SELECT price
FROM bronze.swiggy_data
WHERE price = 0;


-- Check prices outside the expected business range

SELECT price
FROM bronze.swiggy_data
WHERE price > 5000;


/*=============================================================
  5. RATING VALIDATION
=============================================================*/

-- Check negative ratings

SELECT rating
FROM bronze.swiggy_data
WHERE rating < 0;


-- Check ratings greater than the maximum allowed value

SELECT rating
FROM bronze.swiggy_data
WHERE rating > 5;


/*=============================================================
  6. RATING COUNT VALIDATION
=============================================================*/

-- Check negative rating counts

SELECT rating_count
FROM bronze.swiggy_data
WHERE rating_count < 0;


-- Check zero rating counts

SELECT rating_count
FROM bronze.swiggy_data
WHERE rating_count = 0;


/*
=============================================================
PREPROCESSING SUMMARY

The identified issues are handled during the Bronze-to-Silver
transformation:

- TRIM() is used to remove unwanted spaces.
- Invalid prices are converted to NULL.
- Invalid ratings are converted to NULL.
- Invalid/zero rating counts are converted to NULL.
- Duplicate records are identified for handling.
- Bronze data remains unchanged.

=============================================================
*/
```
