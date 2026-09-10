```sql
/*
=============================================================
GOLD LAYER – DIMENSION & FACT TABLE CREATION
=============================================================

Script Purpose:
    This script creates the Gold layer of the Swiggy Data
    Warehouse using a Star Schema.

    The Gold layer contains business-ready data organized into
    dimension and fact tables for analytical reporting and
    business intelligence.

Data Flow:
    
    Bronze Layer
          ↓
    Silver Layer
          ↓
    Gold Layer
          ↓
    Analytical Views / Power BI


GOLD LAYER DATA MODEL:
    
    Dimensions:
        1. dim_date
        2. dim_category
        3. dim_location
        4. dim_restaurant
        5. dim_dish

    Fact:
        1. fact_swiggy_orders


STAR SCHEMA:
    
                    dim_date
                       |
                       |
dim_location ---- fact_swiggy_orders ---- dim_restaurant
                       |
                       |
                dim_category
                       |
                       |
                    dim_dish


DESIGN PRINCIPLES:
    - Dimension tables store descriptive business attributes.
    - The fact table stores measurable business data.
    - Surrogate keys are generated using IDENTITY.
    - Foreign keys establish relationships between the fact
      table and dimension tables.
    - The model is designed for efficient analytical queries
      and reporting.
    - Raw and cleansing activities are handled in Bronze and
      Silver layers respectively.


DIMENSION TABLES:
    
    dim_date:
        Stores calendar-related information such as year,
        month, quarter, week, and day.

    dim_category:
        Stores unique food categories.

    dim_location:
        Stores geographic information including state, city,
        and restaurant location.

    dim_restaurant:
        Stores restaurant information.

    dim_dish:
        Stores dish information.


FACT TABLE:

    fact_swiggy_orders:
        Stores the measurable data associated with each
        warehouse-generated fact record.

    Measures:
        - price_inr
        - rating
        - rating_count

    Foreign Keys:
        - date_id
        - location_id
        - restaurant_id
        - category_id
        - dish_id


SURROGATE KEYS:

    Each dimension uses an IDENTITY-based surrogate key.
    These keys are referenced by the fact table as foreign keys.

    Example:
        dim_restaurant.restaurant_id
              ↓
        fact_swiggy_orders.restaurant_id


AUDIT / DATA LINEAGE COLUMNS:

    dwh_bronze_ingestion:
        Timestamp associated with the Bronze layer record.

    dwh_silver_ingestion:
        Timestamp associated with the Silver layer record.

    dwh_gold_ingestion:
        Timestamp when the record is loaded into the Gold layer.
        Defaults to GETDATE().


DEVELOPMENT NOTE:

    DROP TABLE is used before table creation so that the Gold
    layer can be recreated during development and testing.

    This approach is suitable for a learning and portfolio
    project. In a production environment, table recreation
    would normally be replaced with controlled ETL/ELT and
    incremental loading strategies.

=============================================================
*/


USE SwiggyDataWarehouse;
GO


/*=============================================================
  DIMENSION : DATE
=============================================================*/

IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL 
    DROP TABLE gold.dim_date;

CREATE TABLE gold.dim_date
(
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    date DATE NOT NULL,
    year_number INT,
    month_number INT,
    month_name VARCHAR(20),
    quarter_number INT,
    week_number INT,
    day_number INT,
    day_name VARCHAR(20)
);


/*=============================================================
  DIMENSION : CATEGORY
=============================================================*/

IF OBJECT_ID('gold.dim_category', 'U') IS NOT NULL 
    DROP TABLE gold.dim_category;

CREATE TABLE gold.dim_category
(
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category VARCHAR(100) NOT NULL
);


/*=============================================================
  DIMENSION : LOCATION
=============================================================*/

IF OBJECT_ID('gold.dim_location', 'U') IS NOT NULL 
    DROP TABLE gold.dim_location;

CREATE TABLE gold.dim_location
(
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    state VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL
);


/*=============================================================
  DIMENSION : RESTAURANT
=============================================================*/

IF OBJECT_ID('gold.dim_restaurant', 'U') IS NOT NULL 
    DROP TABLE gold.dim_restaurant;

CREATE TABLE gold.dim_restaurant
(
    restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
    restaurant_name VARCHAR(255) NOT NULL
);


/*=============================================================
  DIMENSION : DISH
=============================================================*/

IF OBJECT_ID('gold.dim_dish', 'U') IS NOT NULL 
    DROP TABLE gold.dim_dish;

CREATE TABLE gold.dim_dish
(
    dish_id INT IDENTITY(1,1) PRIMARY KEY,
    dish_name VARCHAR(255) NOT NULL
);


/*=============================================================
  FACT TABLE : SWIGGY ORDERS
=============================================================*/

IF OBJECT_ID('gold.fact_swiggy_data', 'U') IS NOT NULL 
    DROP TABLE gold.fact_swiggy_data;

CREATE TABLE gold.fact_swiggy_data
(
    order_id INT IDENTITY(1,1) PRIMARY KEY,

    date_id INT NOT NULL,
    location_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    category_id INT NOT NULL,
    dish_id INT NOT NULL,

    price_inr DECIMAL(10,2),
    rating DECIMAL(3,1),
    rating_count INT,

    dwh_bronze_ingestion DATETIME2,
    dwh_silver_ingestion DATETIME2,
    dwh_gold_ingestion DATETIME2 DEFAULT GETDATE(),


    /*=========================================================
      FOREIGN KEY CONSTRAINTS
    =========================================================*/

    CONSTRAINT FK_fact_date
        FOREIGN KEY (date_id)
        REFERENCES gold.dim_date(date_id),

    CONSTRAINT FK_fact_location
        FOREIGN KEY (location_id)
        REFERENCES gold.dim_location(location_id),

    CONSTRAINT FK_fact_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES gold.dim_restaurant(restaurant_id),

    CONSTRAINT FK_fact_category
        FOREIGN KEY (category_id)
        REFERENCES gold.dim_category(category_id),

    CONSTRAINT FK_fact_dish
        FOREIGN KEY (dish_id)
        REFERENCES gold.dim_dish(dish_id)
);

GO
```
