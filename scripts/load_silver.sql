```sql
/*
=============================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=============================================================

Script Purpose:
    This stored procedure loads and transforms data from the
    Bronze layer into the Silver layer.

Transformation Responsibilities:
    - Removes leading and trailing spaces from text columns.
    - Validates and cleans price values.
    - Validates rating values between 0 and 5.
    - Handles invalid and zero rating counts.
    - Preserves the Bronze ingestion timestamp.
    - Records the Silver layer ingestion timestamp automatically.

Data Flow:
    Bronze Layer
        ↓
    Cleaning & Validation
        ↓
    Silver Layer

Processing Steps:
    1. Truncate the existing Silver table.
    2. Read raw data from bronze.swiggy_data.
    3. Apply cleansing and validation rules.
    4. Insert the transformed data into silver.swiggy_data.
    5. Display the number of rows loaded.
    6. Display the total processing duration.

Error Handling:
    If an error occurs during the loading process, the procedure
    captures and displays the error message, error number, and
    error state.

Usage Example:
    EXEC silver.load_silver;

=============================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN

    DECLARE 
        @silver_start_time DATETIME,
        @silver_end_time DATETIME;

    BEGIN TRY

        SET @silver_start_time = GETDATE();

        PRINT '=========================================';
        PRINT '===== EXTRACT AND LOAD SILVER LAYER =====';
        PRINT '=========================================';
        PRINT '>> Truncate & Load Table: silver.swiggy_data';

        TRUNCATE TABLE silver.swiggy_data;

        INSERT INTO silver.swiggy_data
        (
            state,
            city,
            order_date,
            restaurant_name,
            location,
            category,
            dish_name,
            price,
            rating,
            rating_count,
            dwh_bronze_ingestion
        )
        SELECT 
            TRIM(state) AS state,
            TRIM(city) AS city,
            order_date,
            TRIM(restaurant_name) AS restaurant_name,
            TRIM(location) AS location,
            TRIM(category) AS category,
            TRIM(dish_name) AS dish_name,

            CASE
                WHEN price <= 0 THEN NULL
                WHEN price > 5000 THEN NULL
                ELSE price
            END AS price,

            CASE 
                WHEN rating < 0.0 THEN NULL
                WHEN rating > 5.0 THEN NULL
                ELSE rating
            END AS rating,

            CASE 
                WHEN rating_count <= 0 THEN NULL
                ELSE rating_count
            END AS rating_count,

            dwh_create_date AS dwh_bronze_ingestion

        FROM bronze.swiggy_data;

        PRINT '>> Rows Loaded: ' + CAST(@@ROWCOUNT AS NVARCHAR);

        SET @silver_end_time = GETDATE();

        PRINT '>> Loading Silver Layer Duration: '
            + CAST(
                DATEDIFF(
                    SECOND,
                    @silver_start_time,
                    @silver_end_time
                ) AS NVARCHAR
              )
            + ' Seconds';

        PRINT '>> Silver Layer Loaded Successfully.';

    END TRY

    BEGIN CATCH

        PRINT '=========================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR STATE  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================';

    END CATCH

END;
GO

EXEC silver.load_silver;
```
