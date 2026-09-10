
```sql
/*
=============================================================
SILVER LAYER – TABLE CREATION
=============================================================

Script Purpose:
    This script creates the Silver layer table used to store
    cleaned, standardized, and validated data transformed from
    the Bronze layer.

Data Flow:
    Bronze Layer
        ↓
    Silver Layer
        ↓
    Gold Layer

Table:
    silver.swiggy_data

Key Responsibilities:
    - Recreate the Silver table during development/reprocessing.
    - Store standardized Swiggy data.
    - Maintain appropriate data types for analytical processing.
    - Preserve Bronze ingestion information for data lineage.
    - Record the Silver layer ingestion timestamp for auditing.

Data Transformation:
    The actual data cleansing and transformation logic is
    performed during the Bronze-to-Silver loading process.
    Typical Silver-layer transformations include:
    - Removing leading/trailing spaces.
    - Standardizing text values.
    - Handling NULL values.
    - Validating dates and numeric values.
    - Identifying and handling duplicate records.
    - Applying appropriate business rules.

Audit Columns:
    dwh_bronze_ingestion
        Stores the timestamp associated with the Bronze layer
        record/load.

    dwh_silver_ingestion
        Stores the timestamp when the record is loaded into
        the Silver layer.

Development Note:
    The DROP TABLE statement is intentionally used during
    development so the Silver layer can be recreated and
    reprocessed from the Bronze layer.

=============================================================
*/

IF OBJECT_ID('silver.swiggy_data', 'U') IS NOT NULL 
    DROP TABLE silver.swiggy_data;

CREATE TABLE silver.swiggy_data
(
    state                    VARCHAR(100),
    city                     VARCHAR(100),
    order_date               DATE,
    restaurant_name          VARCHAR(255),
    location                 VARCHAR(255),
    category                 VARCHAR(100),
    dish_name                VARCHAR(255),
    price                    DECIMAL(10,2),
    rating                   DECIMAL(3,1),
    rating_count             INT,
    dwh_bronze_ingestion     DATETIME2,
    dwh_silver_ingestion     DATETIME2 DEFAULT GETDATE()
);
GO
```
