# 🍔 Swiggy Data Warehouse & Business Analytics

## 📌 Project Overview

This project builds an end-to-end **Data Warehouse and Business Analytics solution** using Swiggy food-ordering data.

The project follows a modern **Medallion Architecture** consisting of:

**Bronze → Silver → Gold**

Raw Swiggy data is ingested into the Bronze layer, cleaned and validated in the Silver layer, and transformed into a business-ready **Star Schema** in the Gold layer.

The final Gold layer is used to perform business-focused SQL analysis and can be connected to **Power BI** for interactive dashboards and reporting.

---

## 🎯 Project Objectives

The main objectives of this project are to:

* Build an end-to-end Data Warehouse using SQL Server.
* Implement Bronze, Silver, and Gold data layers.
* Clean, standardize, and validate raw data.
* Design a dimensional **Star Schema**.
* Create reusable analytical SQL queries and views.
* Analyze revenue, pricing, ratings, geography, and time trends.
* Generate meaningful business insights from food-ordering data.
* Prepare the Gold layer for Power BI reporting and visualization.

---

## 🏗️ Data Warehouse Architecture

```text
                    ┌─────────────────────┐
                    │     Raw CSV Data    │
                    │    50,000 Records   │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │    🥉 Bronze Layer  │
                    │      Raw Data       │
                    └──────────┬──────────┘
                               │
                     Data Cleaning &
                       Validation
                               │
                               ▼
                    ┌─────────────────────┐
                    │    🥈 Silver Layer  │
                    │  Cleaned & Validated│
                    │        Data         │
                    └──────────┬──────────┘
                               │
                     Dimensional Modeling
                               │
                               ▼
                    ┌─────────────────────┐
                    │     🥇 Gold Layer   │
                    │    Star Schema      │
                    └──────────┬──────────┘
                               │
                 ┌─────────────┴─────────────┐
                 ▼                           ▼
        ┌──────────────────┐       ┌──────────────────┐
        │   SQL Analysis   │       │     Power BI     │
        │ Business Insights│       │    Dashboard     │
        └──────────────────┘       └──────────────────┘
```

---

# 📊 Dataset

The project uses a synthetic Swiggy dataset containing approximately **50,000 records**.

### Dataset Columns

| Column            | Description                           |
| ----------------- | ------------------------------------- |
| `state`           | State where the restaurant is located |
| `city`            | City where the restaurant is located  |
| `order_date`      | Date associated with the record       |
| `restaurant_name` | Restaurant name                       |
| `location`        | Locality/location                     |
| `category`        | Food category                         |
| `dish_name`       | Name of the dish                      |
| `price`           | Price of the dish in INR              |
| `rating`          | Restaurant/dish rating                |
| `rating_count`    | Number of ratings                     |

> **Note:** The source dataset does not contain a true transaction/order identifier. Therefore, the Gold fact table uses a warehouse-generated surrogate key for each loaded record.

---

# 🥉 Bronze Layer

The Bronze layer stores the source data with minimal transformation.

### Purpose

* Preserve raw source data.
* Maintain source-level values for traceability.
* Provide a reliable starting point for transformation.
* Avoid modifying the original source data.

### Bronze Table

```text
bronze.swiggy_data
```

### Bronze Columns

```text
state
city
order_date
restaurant_name
location
category
dish_name
price
rating
rating_count
dwh_create_date
```

Data is initially loaded from the CSV source and retained in its raw form.

---

# 🥈 Silver Layer

The Silver layer contains cleaned, standardized, and validated data.

### Data Cleaning Performed

The transformation process includes:

* Removing leading and trailing spaces.
* Standardizing text fields.
* Validating price values.
* Validating rating values.
* Handling invalid rating counts.
* Preserving NULL values where appropriate.
* Carrying Bronze ingestion timestamps for data lineage.

### Silver Table

```text
silver.swiggy_data
```

### Important Business Rules

#### Price

```text
price <= 0       → NULL
price > 5000     → NULL
valid price      → retained
```

#### Rating

```text
rating < 0       → NULL
rating > 5       → NULL
valid rating     → retained
```

#### Rating Count

```text
rating_count <= 0 → NULL
valid rating_count → retained
```

---

# 🥇 Gold Layer

The Gold layer contains business-ready data designed using a **Star Schema**.

The model consists of:

### Dimension Tables

1. `gold.dim_date`
2. `gold.dim_category`
3. `gold.dim_location`
4. `gold.dim_restaurant`
5. `gold.dim_dish`

### Fact Table

6. `gold.fact_swiggy_orders`

---

## ⭐ Star Schema

```text
                         ┌───────────────────┐
                         │    dim_date       │
                         │───────────────────│
                         │ date_id (PK)      │
                         │ date              │
                         │ year_number       │
                         │ month_number      │
                         │ month_name        │
                         │ quarter_number    │
                         │ week_number       │
                         │ day_name          │
                         └─────────┬─────────┘
                                   │
                                   │
┌───────────────────┐              │              ┌────────────────────┐
│  dim_category     │              │              │  dim_location      │
│───────────────────│              │              │────────────────────│
│ category_id (PK)  │              │              │ location_id (PK)   │
│ category          │              │              │ state              │
└─────────┬─────────┘              │              │ city               │
          │                        │              │ location           │
          │                        │              └──────────┬─────────┘
          │                        │                         │
          │              ┌─────────▼─────────┐              │
          └─────────────►│ fact_swiggy_orders│◄─────────────┘
                         │───────────────────│
                         │ order_id (PK)     │
                         │ date_id (FK)      │
                         │ location_id (FK)  │
                         │ restaurant_id (FK)│
                         │ category_id (FK)  │
                         │ dish_id (FK)      │
                         │ price_inr         │
                         │ rating            │
                         │ rating_count      │
                         └─────────┬─────────┘
                                   │
                         ┌─────────┴─────────┐
                         │                   │
              ┌──────────▼─────────┐ ┌───────▼──────────┐
              │ dim_restaurant     │ │    dim_dish      │
              │────────────────────│ │──────────────────│
              │ restaurant_id (PK) │ │ dish_id (PK)     │
              │ restaurant_name    │ │ dish_name        │
              └────────────────────┘ └──────────────────┘
```

---

# 🔄 ETL / ELT Workflow

```text
CSV File
   │
   ▼
Import into SQL Server
   │
   ▼
Bronze Layer
   │
   │  Raw Data
   ▼
Silver Transformation
   │
   │  Cleaning + Validation
   ▼
Gold Layer
   │
   │  Dimensional Modeling
   ▼
Business Analysis
   │
   ├── Revenue Analysis
   ├── Pricing Analysis
   ├── Rating Analysis
   ├── Geographic Analysis
   └── Time Trend Analysis
   │
   ▼
Power BI Dashboard
```

---

# 🔍 Data Quality Checks

Several data quality checks are performed during the Bronze-to-Silver transformation.

### Checks include:

* Duplicate records
* NULL values
* Leading/trailing spaces
* Invalid prices
* Invalid ratings
* Invalid rating counts
* Data type consistency
* Business-rule validation

The Bronze layer remains unchanged, while corrections are applied during Silver transformation.

---

# 📈 Business Analysis

The Gold layer is used to answer important business questions.

## 💰 Revenue & Pricing Analysis

Analysis includes:

* Total price value by category.
* Average price by category.
* Revenue distribution by state and city.
* Price bucket distribution.
* Top restaurant and dish combinations by total price value.

### Price Buckets

```text
Under 100
100 - 299
300 - 499
500+
```

---

## ⭐ Ratings & Quality Analysis

Analysis includes:

* Average rating by category.
* Average rating by location.
* Restaurants with low ratings and high record volume.
* Relationship between price ranges and average ratings.
* Popular restaurants with high rating counts but relatively low ratings.

---

## 🌍 Geographic Analysis

Analysis includes:

* Revenue by city.
* Record volume by city.
* City ranking within each state.
* Restaurant coverage by locality.
* Records per restaurant.
* Identification of potentially underserved locations.
* Identification of potentially oversupplied locations.

---

## 📅 Time Trend Analysis

Analysis includes:

* Monthly record trends.
* Quarterly trends.
* Weekday vs weekend comparison.
* Monthly revenue trends.
* Month-over-month growth.
* Month-over-month revenue growth using `LAG()`.

---

# 🛠️ Technologies Used

| Technology                              | Purpose                        |
| --------------------------------------- | ------------------------------ |
| **SQL Server**                          | Database & Data Warehouse      |
| **T-SQL**                               | Data transformation & analysis |
| **SQL Server Management Studio (SSMS)** | Database development           |
| **Git & GitHub**                        | Version control                |
| **CSV**                                 | Source data                    |
| **Power BI**                            | Data visualization             |
| **Dimensional Modeling**                | Data Warehouse design          |
| **Star Schema**                         | Analytical data model          |

---

# 📁 Project Structure

```text
SWIGGY-DATA-WAREHOUSE/
│
├── datasets/
│   └── sdata.csv
│
├── scripts/
│   │
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   └── load_bronze.sql
│   │
│   ├── silver/
│   │   ├── ddl_silver.sql
│   │   └── load_silver.sql
│   │
│   ├── gold/
│   │   ├── ddl_gold.sql
│   │   ├── load_dimensions.sql
│   │   ├── load_fact.sql
│   │   └── views/
│   │
│   └── analysis/
│       ├── 01_revenue_pricing_analysis.sql
│       ├── 02_ratings_quality_analysis.sql
│       ├── 03_geography_analysis.sql
│       └── 04_time_trend_analysis.sql
│
└── README.md
```

---

# 🚀 How to Run the Project

## Step 1 — Clone the Repository

```bash
git clone https://github.com/tanmaycode111/SWIGGY-DATA-WAREHOUSE.git
```

Navigate to the project directory:

```bash
cd SWIGGY-DATA-WAREHOUSE
```

---

## Step 2 — Create Database

Create a SQL Server database for the project.

Example:

```sql
CREATE DATABASE Swiggy_DWH;
```

Then create the required schemas:

```sql
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
```

---

## Step 3 — Load Bronze Data

Place the CSV dataset in an accessible location for SQL Server.

Run the Bronze DDL script:

```text
scripts/bronze/ddl_bronze.sql
```

Then load the source data using the Bronze load process.

---

## Step 4 — Transform Bronze → Silver

Run:

```text
scripts/silver/ddl_silver.sql
scripts/silver/load_silver.sql
```

This performs data cleaning, validation, and standardization.

---

## Step 5 — Build Gold Layer

Run:

```text
scripts/gold/ddl_gold.sql
scripts/gold/load_dimensions.sql
scripts/gold/load_fact.sql
```

This creates and populates the Star Schema.

---

## Step 6 — Run SQL Analysis

Execute the analysis scripts:

```text
scripts/analysis/
```

The scripts cover:

```text
01 → Revenue & Pricing
02 → Ratings & Quality
03 → Geography
04 → Time Trends
```

---

## Step 7 — Connect to Power BI

The Gold layer can be connected to Power BI for dashboard development.

Recommended dashboard areas:

* Revenue Overview
* Restaurant Performance
* Category Performance
* Location Analysis
* Ratings & Quality
* Time Trends

---

# 📊 Potential Dashboard KPIs

The following KPIs can be presented in Power BI:

```text
Total Records
Total Price Value
Average Price
Average Rating
Top Restaurant
Top Category
Top City
Top Dish
Weekend vs Weekday Records
Monthly Growth
```

---

# 💡 Key Business Questions

This project is designed to answer questions such as:

1. Which food categories generate the highest total price value?
2. Which cities contribute the most to overall business value?
3. Which restaurants and dishes have the highest price value?
4. Which price range contains the largest number of records?
5. Which categories have the highest average ratings?
6. Which restaurants have high volume but low ratings?
7. Does price appear to be associated with higher ratings?
8. Which cities have the highest demand?
9. Which localities have high demand relative to restaurant coverage?
10. How does business activity change month over month?
11. Are weekends different from weekdays?
12. Which locations may represent growth opportunities?

---

# 🧠 Data Modeling Concepts Demonstrated

This project demonstrates practical understanding of:

* Data Warehousing
* Medallion Architecture
* ETL / ELT concepts
* Data Cleaning
* Data Validation
* Data Quality Checks
* Dimensional Modeling
* Star Schema
* Fact Tables
* Dimension Tables
* Surrogate Keys
* Primary Keys
* Foreign Keys
* Data Lineage
* SQL Joins
* CTEs
* Subqueries
* Window Functions
* `LAG()`
* `RANK()`
* Aggregations
* Stored Procedures
* Views
* SQL Server

---

# ⚠️ Project Notes

### Synthetic Dataset

The dataset used in this project is **synthetically generated** for educational and portfolio purposes.

It should not be interpreted as actual Swiggy operational or customer data.

### Fact Table

The source dataset does not provide a genuine transaction/order identifier. Therefore:

```text
order_id
```

in the Gold fact table is a **warehouse-generated surrogate key** used to uniquely identify loaded records.

### Rating Count

`rating_count` originates from the source-level data and may be repeated across multiple records. Therefore, aggregating it across records should be interpreted carefully and should not automatically be treated as unique customer ratings.

### Development vs Production

The current project uses full-refresh techniques such as `TRUNCATE` and `DROP TABLE` during development and reprocessing.

A production implementation would typically use:

* Incremental loading
* Change Data Capture
* Slowly Changing Dimensions
* Incremental fact loading
* Automated orchestration
* Data quality monitoring

---

# 🔮 Future Enhancements

Future improvements may include:

* Build an interactive Power BI dashboard.
* Add automated ETL orchestration.
* Implement incremental loading.
* Implement Slowly Changing Dimensions (SCD).
* Add more advanced analytical views.
* Add data quality monitoring.
* Add automated testing.
* Add scheduled pipeline execution.
* Deploy the solution to a cloud platform.
* Integrate cloud storage and compute services.
* Add business-level KPI reporting.

---

# 📚 Learning Outcomes

Through this project, I practiced building a complete analytics workflow from raw data to business insights.

The project helped strengthen my skills in:

* SQL Server
* Data Cleaning
* Data Warehousing
* Dimensional Modeling
* Star Schema Design
* Data Analysis
* Business Problem Solving
* Git & GitHub
* Power BI preparation

---

# 👨‍💻 Author

## Tanmay Giri

Aspiring **Data Analyst** focused on SQL, Data Analytics, Data Warehousing, and Business Intelligence.

I am continuously improving my technical and communication skills while building practical, end-to-end data projects.

## 🔗 Connect with me

[![GitHub](https://img.shields.io/badge/GitHub-tanmaycode111-181717?style=for-the-badge\&logo=github)](https://github.com/tanmaycode111)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Tanmay%20Giri-0A66C2?style=for-the-badge\&logo=linkedin)](https://www.linkedin.com/in/tanmay-giri-01b718204/)

---

⭐ **If you found this project useful, feel free to star the repository!**
