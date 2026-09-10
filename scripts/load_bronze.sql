/*

```
                BRONZE LAYER – DATA LOADING INFORMATION
```

================================================================================

## Purpose:

The source Swiggy dataset is provided as a raw CSV file containing approximately
50,000 records. The dataset intentionally contains various data-quality issues
such as NULL values, inconsistent formatting, extra spaces, zero values, and
other forms of messy/raw data.

## Data Loading Approach:

The raw CSV file should first be imported into SQL Server using the
"Import Flat File" / "Import Data" functionality available in SQL Server
Management Studio (SSMS).

After importing the raw data, the source table can be moved/copied into the
appropriate database and Bronze schema created for this Data Warehouse project.

## Recommended Process:

1. Import the raw CSV file using the Import Flat File / Import Data wizard.
2. Verify the imported table and its column data types.
3. Create the required Bronze schema in the target Data Warehouse database.
4. Create the final Bronze table according to the Data Warehouse structure.
5. Insert the data from the imported/source table into the newly created
   Bronze table.
6. Preserve the raw data as much as possible in the Bronze layer.
7. Data cleansing and transformation should be performed in the Silver layer.

## Example:

The imported source table may initially exist under the default "dbo" schema.
The data is then transferred into the dedicated Bronze schema:

```
Source:
SwiggyDataWarehouse.dbo.bronze.swiggy_data1

Target:
SwiggyDataWarehouse.bronze.swiggy_data
```

The target Bronze table also contains a DWH audit column:

```
dwh_create_date DATETIME2 DEFAULT GETDATE()
```

This column records the date and time when the record is loaded into the
Data Warehouse.

## Important Disclaimer:

The provided dataset is intentionally raw and contains significant data-quality
issues. Therefore, users are advised to use the SQL Server Import Flat File /
Import Data functionality for the initial data ingestion rather than manually
creating individual INSERT statements.

The Bronze layer is designed to retain the source data in its raw form.
Cleaning, standardization, validation, handling of NULL values, and other
transformations should be performed during the Silver layer processing.

This dataset is intended for learning, portfolio development, and Data
Warehouse practice purposes.

================================================================================
*/

INSERT INTO bronze.swiggy_data
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
    rating_count
)
SELECT
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
FROM SwiggyDataWarehouse.dbo.[bronze.swiggy_data1];
