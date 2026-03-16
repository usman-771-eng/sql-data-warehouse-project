/*
===============================================================================
Database Initialization Script
===============================================================================
Purpose:
    This script initializes the Data Warehouse environment by creating a new
    database named 'DataWarehouse' and setting up the required schemas.

Schemas Created:
    bronze  - Raw data ingestion layer (stores data exactly as received)
    silver  - Cleaned and transformed data layer
    gold    - Business-ready data layer optimized for analytics

Execution Steps:
    1. Check if the 'DataWarehouse' database already exists.
    2. If it exists, switch it to SINGLE_USER mode and drop it.
    3. Create a fresh 'DataWarehouse' database.
    4. Create Medallion Architecture schemas (bronze, silver, gold).

Warning:
    Running this script will permanently delete the existing
    'DataWarehouse' database and all its contents.

    Ensure that backups are taken before executing in production.
===============================================================================
*/


/* ---------------------------------------------------------------------------
   Step 1: Switch context to the master database
   Required for creating or dropping databases
--------------------------------------------------------------------------- */
USE master;
GO


/* ---------------------------------------------------------------------------
   Step 2: Drop existing DataWarehouse database (if it exists)
--------------------------------------------------------------------------- */
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO


/* ---------------------------------------------------------------------------
   Step 3: Create a fresh DataWarehouse database
--------------------------------------------------------------------------- */
CREATE DATABASE DataWarehouse;
GO


/* ---------------------------------------------------------------------------
   Step 4: Switch context to the newly created database
--------------------------------------------------------------------------- */
USE DataWarehouse;
GO


/* ---------------------------------------------------------------------------
   Step 5: Create schemas for Medallion Architecture
--------------------------------------------------------------------------- */

-- Bronze Layer: Raw data ingestion from source systems
CREATE SCHEMA bronze;
GO

-- Silver Layer: Cleaned, validated, and transformed data
CREATE SCHEMA silver;
GO

-- Gold Layer: Aggregated and business-ready analytical datasets
CREATE SCHEMA gold;
GO
