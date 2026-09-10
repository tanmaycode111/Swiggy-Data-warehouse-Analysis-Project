/*
================================================================================
GOLD LAYER - LOAD PROCEDURE
================================================================================

Purpose:
--------
This procedure loads the Gold layer of the Swiggy Data Warehouse from the
cleansed Silver layer.

The Gold layer follows a STAR SCHEMA design consisting of:

    Dimension Tables:
        1. gold.dim_date
        2. gold.dim_category
        3. gold.dim_location
        4. gold.dim_restaurant
        5. gold.dim_dish

    Fact Table:
        6. gold.fact_swiggy_orders

Process:
--------
1. Truncate existing Gold layer tables.
2. Load unique business values into dimension tables.
3. Generate surrogate keys using IDENTITY columns.
4. Join Silver data with dimension tables.
5. Retrieve surrogate keys for each dimension.
6. Load measures and audit information into the fact table.
7. Record Gold layer loading duration.
8. Handle errors using TRY...CATCH.

Data Flow:
----------
    Silver Layer
          |
          v
    Dimension Tables
          |
          v
    Fact Table
          |
          v
    Analytical Views / Power BI

Important:
----------
- This implementation uses a FULL REFRESH strategy using TRUNCATE TABLE.
- It is suitable for this portfolio project and development environment.
- In a production environment, incremental loading or MERGE-based strategies
  would normally be considered.
- The order_id in the fact table is a warehouse-generated surrogate key.
  It is NOT a real Swiggy order identifier because the source dataset does
  not contain a unique order ID.

================================================================================
*/


CREATE OR ALTER PROCEDURE gold.load_gold
AS
BEGIN

    DECLARE @gold_start_time DATETIME,
            @gold_end_time   DATETIME;

    BEGIN TRY

        SET @gold_start_time = GETDATE();

        PRINT '=========================================';
        PRINT '===== EXTRACT AND LOAD GOLD LAYER =======';
        PRINT '=========================================';
        PRINT '>> Starting Gold Layer Load';
        PRINT '';


        /*====================================================================
          LOAD DATE DIMENSION
        ====================================================================*/

        PRINT '>> Loading gold.dim_date';

        TRUNCATE TABLE gold.dim_date;

        INSERT INTO gold.dim_date
        (
            date,
            year_number,
            month_number,
            month_name,
            quarter_number,
            week_number,
            day_number,
            day_name
        )
        SELECT DISTINCT
            order_date,
            YEAR(order_date),
            MONTH(order_date),
            DATENAME(MONTH, order_date),
            DATEPART(QUARTER, order_date),
            DATEPART(WEEK, order_date),
            DAY(order_date),
            DATENAME(WEEKDAY, order_date)
        FROM silver.swiggy_data
        WHERE order_date IS NOT NULL;


        /*====================================================================
          LOAD CATEGORY DIMENSION
        ====================================================================*/

        PRINT '>> Loading gold.dim_category';

        TRUNCATE TABLE gold.dim_category;

        INSERT INTO gold.dim_category
        (
            category
        )
        SELECT DISTINCT
            TRIM(category)
        FROM silver.swiggy_data
        WHERE category IS NOT NULL
          AND TRIM(category) <> '';


        /*====================================================================
          LOAD LOCATION DIMENSION
        ====================================================================*/

        PRINT '>> Loading gold.dim_location';

        TRUNCATE TABLE gold.dim_location;

        INSERT INTO gold.dim_location
        (
            state,
            city,
            location
        )
        SELECT DISTINCT
            TRIM(state),
            TRIM(city),
            TRIM(location)
        FROM silver.swiggy_data
        WHERE state IS NOT NULL
          AND city IS NOT NULL
          AND location IS NOT NULL
          AND TRIM(state) <> ''
          AND TRIM(city) <> ''
          AND TRIM(location) <> '';


        /*====================================================================
          LOAD RESTAURANT DIMENSION
        ====================================================================*/

        PRINT '>> Loading gold.dim_restaurant';

        TRUNCATE TABLE gold.dim_restaurant;

        INSERT INTO gold.dim_restaurant
        (
            restaurant_name
        )
        SELECT DISTINCT
            TRIM(restaurant_name)
        FROM silver.swiggy_data
        WHERE restaurant_name IS NOT NULL
          AND TRIM(restaurant_name) <> '';


        /*====================================================================
          LOAD DISH DIMENSION
        ====================================================================*/

        PRINT '>> Loading gold.dim_dish';

        TRUNCATE TABLE gold.dim_dish;

        INSERT INTO gold.dim_dish
        (
            dish_name
        )
        SELECT DISTINCT
            TRIM(dish_name)
        FROM silver.swiggy_data
        WHERE dish_name IS NOT NULL
          AND TRIM(dish_name) <> '';


        /*====================================================================
          LOAD FACT TABLE
        ====================================================================*/

        PRINT '>> Loading gold.fact_swiggy_orders';

        TRUNCATE TABLE gold.fact_swiggy_orders;

        INSERT INTO gold.fact_swiggy_orders
        (
            date_id,
            location_id,
            restaurant_id,
            category_id,
            dish_id,
            price_inr,
            rating,
            rating_count,
            dwh_bronze_ingestion,
            dwh_silver_ingestion
        )
        SELECT
            d.date_id,
            l.location_id,
            r.restaurant_id,
            c.category_id,
            ds.dish_id,
            s.price,
            s.rating,
            s.rating_count,
            s.dwh_bronze_ingestion,
            s.dwh_silver_ingestion

        FROM silver.swiggy_data AS s

        /* Date Dimension */
        LEFT JOIN gold.dim_date AS d
            ON s.order_date = d.date

        /* Location Dimension */
        LEFT JOIN gold.dim_location AS l
            ON TRIM(s.state) = l.state
           AND TRIM(s.city) = l.city
           AND TRIM(s.location) = l.location

        /* Restaurant Dimension */
        LEFT JOIN gold.dim_restaurant AS r
            ON TRIM(s.restaurant_name) = r.restaurant_name

        /* Category Dimension */
        LEFT JOIN gold.dim_category AS c
            ON TRIM(s.category) = c.category

        /* Dish Dimension */
        LEFT JOIN gold.dim_dish AS ds
            ON TRIM(s.dish_name) = ds.dish_name;


        /*====================================================================
          LOAD COMPLETION INFORMATION
        ====================================================================*/

        SET @gold_end_time = GETDATE();

        PRINT '';
        PRINT '>> Gold Layer Rows Loaded: '
              + CAST(@@ROWCOUNT AS NVARCHAR);

        PRINT '>> Gold Layer Loading Duration: '
              + CAST(
                    DATEDIFF(
                        SECOND,
                        @gold_start_time,
                        @gold_end_time
                    ) AS NVARCHAR
                )
              + ' Seconds';

        PRINT '>> Gold Layer Loaded Successfully.';

        PRINT '=========================================';
        PRINT '===== GOLD LAYER LOAD COMPLETED ========';
        PRINT '=========================================';


    END TRY


    BEGIN CATCH

        PRINT '=========================================';
        PRINT 'ERROR OCCURRED DURING GOLD LAYER LOAD';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR STATE  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================';

    END CATCH

END;
GO


/*====================================================================
  EXECUTE GOLD LAYER LOAD
====================================================================*/

EXEC gold.load_gold;
GO


                


