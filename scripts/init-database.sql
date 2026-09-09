/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'SwiggyDataWarehouse' after 
    checking if it already exists. If the database exists, it is dropped 
    and recreated. The script then sets up three schemas within the 
    database: 'bronze', 'silver', and 'gold', following Medallion 
    Architecture principles.

    Swiggy-Data-Warehouse/
├── datasets/              # raw CSV source files
├── scripts/
│   ├── init_database.sql  # ← this script goes here
│   ├── bronze/
│   ├── silver/
│   └── gold/
├── docs/
│   ├── data_architecture.drawio
│   └── data_flow.drawio
└── README.md

WARNING:
    Running this script will drop the entire 'SwiggyDataWarehouse' database 
    if it exists. All data in the database will be permanently deleted. 
    Proceed with caution and ensure you have proper backups before 
    running this script.
=============================================================
*/

USE MASTER;
GO
-- Drop if already existed
IF EXISTS ( SELECT 1 FROM sys.databases WHERE name = 'SwiggyDataWarehouse')
BEGIN
	ALTER DATABASE SwiggyDataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP  DATABASE SwiggyDataWarehouse;
END;
GO
-- Create the Database
CREATE DATABASE SwiggyDataWarehouse;
GO

USE SwiggyDataWarehouse;
GO

-- Create the Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO


